const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { pool } = require("../db");
const { authRequired } = require("../middleware/auth");

const router = express.Router();

function signToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d",
  });
}

// POST /auth/register
router.post("/register", async (req, res) => {
  const { name, email, password } = req.body || {};
  if (!name || !email || !password) return res.status(400).json({ error: "Missing fields" });

  const passwordHash = await bcrypt.hash(password, 10);

  try {
    const result = await pool.query(
      `INSERT INTO app_user(name, email, password)
       VALUES ($1, $2, $3)
       RETURNING id, name, email, status`,
      [name, email, password]
    );

    const user = result.rows[0];
    const token = signToken(user.id);
    return res.json({ token, user });
  } catch (e) {
    return res.status(400).json({ error: "User already exists or invalid data" });
  }
});

// POST /auth/login
router.post("/login", async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: "Missing fields" });

  const result = await pool.query(
    `SELECT id, name, email, status, password FROM app_user WHERE email=$1`,
    [email]
  );
  const row = result.rows[0];
  if (!row) return res.status(401).json({ error: "Invalid credentials" });

  const ok = await bcrypt.compare(password, row.password || "");
  if (!ok) return res.status(401).json({ error: "Invalid credentials" });

  const token = signToken(row.id);
  const user = { id: row.id, name: row.name, email: row.email, status: row.status };
  return res.json({ token, user });
});

// GET /auth/me
router.get("/me", authRequired, async (req, res) => {
  const userId = req.user.userId;

  const result = await pool.query(
    `SELECT id, name, email, status FROM app_user WHERE id=$1`,
    [userId]
  );
  const user = result.rows[0];
  if (!user) return res.status(404).json({ error: "User not found" });

  return res.json({ user });
});

module.exports = router;