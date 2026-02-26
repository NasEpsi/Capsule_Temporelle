const express = require("express");
const { pool } = require("../db");

const router = express.Router();

// POST /capsules/:id/members
router.post("/:id/members", async (req, res) => {
  const capsuleId = Number(req.params.id);
  const { user_id, role } = req.body || {};
  if (!user_id || !role) return res.status(400).json({ error: "Missing fields" });

  const allowed = ["BENEFICIARY", "CONTRIBUTOR", "OWNER"];
  if (!allowed.includes(role)) return res.status(400).json({ error: "Invalid role" });

  await pool.query(
    `INSERT INTO capsule_member(capsule_id, user_id, role)
     VALUES ($1, $2, $3)
     ON CONFLICT (capsule_id, user_id) DO UPDATE SET role = EXCLUDED.role`,
    [capsuleId, user_id, role]
  );

  res.status(201).json({ ok: true });
});

// POST /capsules/:id/messages
router.post("/:id/messages", async (req, res) => {
  const capsuleId = Number(req.params.id);
  const { user_id, content } = req.body || {};
  if (!user_id || !content) return res.status(400).json({ error: "Missing fields" });

  const roleRes = await pool.query(
    `SELECT role FROM capsule_member WHERE capsule_id=$1 AND user_id=$2`,
    [capsuleId, user_id]
  );

  const membership = roleRes.rows[0];
  if (!membership) return res.status(403).json({ error: "Not a member of this capsule" });

  if (membership.role === "BENEFICIARY") {
    return res.status(403).json({ error: "Beneficiary cannot post messages" });
  }

  const result = await pool.query(
    `INSERT INTO message(capsule_id, user_id, content)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [capsuleId, user_id, content]
  );

  res.status(201).json(result.rows[0]);
});

module.exports = router;