const express = require("express");
const { pool } = require("../db");

const router = express.Router();

// GET /users/:id
router.get("/:id", async (req, res) => {
  const id = Number(req.params.id);
  const result = await pool.query(
    `SELECT id, name, email, status FROM app_user WHERE id=$1`,
    [id]
  );
  const user = result.rows[0];
  if (!user) return res.status(404).json({ error: "User not found" });
  res.json(user);
});

// GET /users/:id/capsules  (avec rôle)
router.get("/:id/capsules", async (req, res) => {
  const userId = Number(req.params.id);

  const result = await pool.query(
    `SELECT c.*, m.role AS member_role
     FROM capsule c
     JOIN capsule_member m ON m.capsule_id = c.id
     WHERE m.user_id = $1
     ORDER BY c.created_at DESC`,
    [userId]
  );

  res.json(result.rows);
});

module.exports = router;