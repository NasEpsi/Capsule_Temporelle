const express = require("express");
const crypto = require("crypto");
const { pool } = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();

const SKY_ALLOWED = new Set(["SUNNY", "CLOUDY", "RAINY", "SNOWY"]);
const ROLE_ALLOWED = new Set(["OWNER", "BENEFICIARY", "CONTRIBUTOR"]);

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(email ?? "").trim());
}

async function getMyRole(capsuleId, userId) {
  const r = await pool.query(
    `SELECT role FROM capsule_members WHERE capsule_id=$1 AND user_id=$2`,
    [capsuleId, userId]
  );
  return r.rows[0]?.role ?? null;
}

async function requireOwner(capsuleId, userId) {
  return (await getMyRole(capsuleId, userId)) === "OWNER";
}

// POST /capsules (create)

router.post("/", authRequired, async (req, res) => {
  try {
    const userId = req.user.userId;

    const title = String(req.body?.title ?? "").trim();
    const description = req.body?.description ?? null;
    const requiredSky = String(req.body?.requiredSky ?? "").trim().toUpperCase();
    const unlockAt = req.body?.unlockAt;

    if (!title) return res.status(400).json({ error: "title is required" });
    if (!SKY_ALLOWED.has(requiredSky)) {
      return res.status(400).json({ error: "requiredSky invalid" });
    }

    const unlockDate = new Date(unlockAt);
    if (!unlockAt || Number.isNaN(unlockDate.getTime())) {
      return res.status(400).json({ error: "unlockAt must be a valid ISO date" });
    }
    if (unlockDate <= new Date()) {
      return res.status(400).json({ error: "unlockAt must be in the future" });
    }

    const insert = await pool.query(
      `INSERT INTO capsules
        (creator_user_id, title, description, unlock_at, required_sky, created_at)
       VALUES ($1,$2,$3,$4,$5,NOW())
       RETURNING id, creator_user_id, title, description, unlock_at, required_sky, created_at`,
      [userId, title, description, unlockDate.toISOString(), requiredSky]
    );

    const capsule = insert.rows[0];

    // owner auto
    await pool.query(
      `INSERT INTO capsule_members (capsule_id, user_id, role, created_at)
       VALUES ($1,$2,'OWNER',NOW())
       ON CONFLICT (capsule_id, user_id) DO NOTHING`,
      [capsule.id, userId]
    );

    res.status(201).json({
      id: capsule.id,
      creator_user_id: capsule.creator_user_id,
      title: capsule.title,
      description: capsule.description,
      unlock_at: capsule.unlock_at,
      required_sky: capsule.required_sky,
      created_at: capsule.created_at,
      member_role: "OWNER",
    });
  } catch (err) {
    console.error("POST /capsules error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /capsules/:id/invites

router.post("/:id/invites", authRequired, async (req, res) => {
  try {
    const capsuleId = Number(req.params.id);
    if (!capsuleId) return res.status(400).json({ error: "Invalid capsule id" });

    const me = req.user.userId;
    if (!(await requireOwner(capsuleId, me))) {
      return res.status(403).json({ error: "Forbidden (owner only)" });
    }

    const beneficiaryEmailRaw = req.body?.beneficiaryEmail ?? null;
    const contributorEmailsRaw = req.body?.contributorEmails ?? [];

    const invitesToCreate = [];

    // beneficiary optional
    if (beneficiaryEmailRaw && String(beneficiaryEmailRaw).trim() !== "") {
      const email = String(beneficiaryEmailRaw).trim().toLowerCase();
      if (!isValidEmail(email)) return res.status(400).json({ error: "Invalid beneficiaryEmail" });
      invitesToCreate.push({ email, role: "BENEFICIARY" });
    }

    // contributors optional
    const list = Array.isArray(contributorEmailsRaw) ? contributorEmailsRaw : [];
    for (const raw of list) {
      if (!raw || String(raw).trim() === "") continue;
      const email = String(raw).trim().toLowerCase();
      if (!isValidEmail(email)) {
        return res.status(400).json({ error: `Invalid contributor email: ${raw}` });
      }
      invitesToCreate.push({ email, role: "CONTRIBUTOR" });
    }

    if (invitesToCreate.length === 0) {
      return res.status(200).json({ invites: [] });
    }

    const created = [];
    for (const inv of invitesToCreate) {
      const token = crypto.randomBytes(24).toString("hex");

      const r = await pool.query(
        `INSERT INTO capsule_invites
          (capsule_id, email, role, status, token, invited_by_user_id, created_at)
         VALUES ($1,$2,$3,'PENDING',$4,$5,NOW())
         ON CONFLICT (capsule_id, email, role)
         DO UPDATE SET status='PENDING'
         RETURNING id, capsule_id, email, role, status, token, created_at`,
        [capsuleId, inv.email, inv.role, token, me]
      );

      created.push(r.rows[0]);
    }

    res.status(201).json({ invites: created });
  } catch (err) {
    console.error("POST /capsules/:id/invites error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /capsules/:id/members
router.post("/:id/members", authRequired, async (req, res) => {
  try {
    const capsuleId = Number(req.params.id);
    if (!capsuleId) return res.status(400).json({ error: "Invalid capsule id" });

    const me = req.user.userId;
    if (!(await requireOwner(capsuleId, me))) {
      return res.status(403).json({ error: "Forbidden (owner only)" });
    }

    const userId = Number(req.body?.userId);
    const role = String(req.body?.role ?? "").trim().toUpperCase();

    if (!userId) return res.status(400).json({ error: "userId is required (number)" });
    if (!ROLE_ALLOWED.has(role)) return res.status(400).json({ error: "Invalid role" });

    await pool.query(
      `INSERT INTO capsule_members (capsule_id, user_id, role, created_at)
       VALUES ($1,$2,$3,NOW())
       ON CONFLICT (capsule_id, user_id)
       DO UPDATE SET role=EXCLUDED.role`,
      [capsuleId, userId, role]
    );

    res.status(201).json({ ok: true });
  } catch (err) {
    console.error("POST /capsules/:id/members error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /capsules/:id/messages (OWNER/CONTRIBUTOR only)

router.post("/:id/messages", authRequired, async (req, res) => {
  try {
    const capsuleId = Number(req.params.id);
    if (!capsuleId) return res.status(400).json({ error: "Invalid capsule id" });

    const me = req.user.userId;
    const role = await getMyRole(capsuleId, me);
    if (!role) return res.status(403).json({ error: "Not a member" });
    if (role === "BENEFICIARY") return res.status(403).json({ error: "Beneficiary cannot post" });

    const content = String(req.body?.content ?? "").trim();
    if (!content) return res.status(400).json({ error: "content is required" });

    const r = await pool.query(
      `INSERT INTO message (capsule_id, user_id, content, created_at)
       VALUES ($1,$2,$3,NOW())
       RETURNING id, capsule_id, user_id, content, created_at`,
      [capsuleId, me, content]
    );

    res.status(201).json(r.rows[0]);
  } catch (err) {
    console.error("POST /capsules/:id/messages error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /capsules/:id (debug)
router.get("/:id", authRequired, async (req, res) => {
  try {
    const capsuleId = Number(req.params.id);
    if (!capsuleId) return res.status(400).json({ error: "Invalid capsule id" });

    const r = await pool.query(
      `SELECT id, creator_user_id, title, description, unlock_at, required_sky, created_at
       FROM capsules WHERE id=$1`,
      [capsuleId]
    );
    if (r.rowCount === 0) return res.status(404).json({ error: "Capsule not found" });

    res.json(r.rows[0]);
  } catch (err) {
    console.error("GET /capsules/:id error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /capsules/:id/messages
router.get("/:id/messages", authRequired, async (req, res) => {
  try {
    const capsuleId = Number(req.params.id);
    if (!capsuleId) return res.status(400).json({ error: "Invalid capsule id" });

    const me = req.user.userId;
    const role = await getMyRole(capsuleId, me);
    if (!role) return res.status(403).json({ error: "Not a member" });

    const r = await pool.query(
      `SELECT id, capsule_id, user_id, content, created_at
       FROM message
       WHERE capsule_id=$1
       ORDER BY created_at ASC`,
      [capsuleId]
    );

    res.json(r.rows);
  } catch (err) {
    console.error("GET /capsules/:id/messages error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;