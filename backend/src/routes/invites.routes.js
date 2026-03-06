const express = require("express");
const router = express.Router();

const { pool } = require("../db");
const { authRequired } = require("../middleware/auth");


// POST /invites/:token/accept
router.post("/:token/accept", authRequired, async (req, res) => {
  try {
    const token = String(req.params.token || "").trim();
    if (!token) {
      return res.status(400).json({ error: "Missing invite token" });
    }

    const userId = req.user.userId;
    // get user by id

    const userRes = await pool.query(
      `SELECT id, email FROM app_user WHERE id=$1`,
      [userId]
    );

    if (userRes.rowCount === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userRes.rows[0];
    const userEmail = user.email.toLowerCase();

    // get invite
    const inviteRes = await pool.query(
      `
      SELECT *
      FROM capsule_invites
      WHERE token=$1
      `,
      [token]
    );

    if (inviteRes.rowCount === 0) {
      return res.status(404).json({ error: "Invite not found" });
    }

    const invite = inviteRes.rows[0];

    if (invite.status === "ACCEPTED") {
      return res.status(200).json({
        message: "Invite already accepted",
      });
    }

    // vérify email
    if (invite.email.toLowerCase() !== userEmail) {
      return res.status(403).json({
        error: "This invite is not for your email",
      });
    }

    // create member in capsule
    await pool.query(
      `
      INSERT INTO capsule_members
        (capsule_id, user_id, role, created_at)
      VALUES ($1,$2,$3,NOW())
      ON CONFLICT (capsule_id, user_id)
      DO NOTHING
      `,
      [
        invite.capsule_id,
        userId,
        invite.role, // BENEFICIARY ou CONTRIBUTOR
      ]
    );
    // status accepted
    await pool.query(
      `
      UPDATE capsule_invites
      SET status='ACCEPTED',
          accepted_at=NOW()
      WHERE id=$1
      `,
      [invite.id]
    );

    res.status(200).json({
      message: "Invite accepted",
      capsuleId: invite.capsule_id,
      role: invite.role,
    });

  } catch (err) {
    console.error("POST /invites/:token/accept error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// POST /invites/sync 
router.post("/sync", authRequired, async (req, res) => {
  const userId = req.user.userId;
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const userRes = await client.query(
      `SELECT id, email FROM app_user WHERE id=$1`,
      [userId]
    );
    if (userRes.rowCount === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ error: "User not found" });
    }
    const email = String(userRes.rows[0].email || "").toLowerCase();

    const invRes = await client.query(
      `
      SELECT id, token, capsule_id, role
      FROM capsule_invites
      WHERE lower(email)= $1
        AND status = 'PENDING'`,
      [email]
    );

    let created = 0;

    for (const inv of invRes.rows) {
      await client.query(
        `
        INSERT INTO capsule_members (capsule_id, user_id, role, created_at)
        VALUES ($1,$2,$3,NOW())
        ON CONFLICT (capsule_id, user_id) DO NOTHING
        `,
        [inv.capsule_id, userId, inv.role]
      );

      await client.query(
        `
        UPDATE capsule_invites
        SET status='ACCEPTED',
            accepted_at=NOW()
        WHERE id=$1
        `,
        [inv.id]
      );

      created += 1;
    }

    await client.query("COMMIT");
    res.json({ message: "Invites synced", synced: created });
  } catch (e) {
    await client.query("ROLLBACK");
    console.error("POST /invites/sync error:", e);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    client.release();
  }
});

module.exports = router;