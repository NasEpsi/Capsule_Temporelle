require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { pool } = require("./db");

const authRoutes = require("./routes/auth.routes");
const usersRoutes = require("./routes/users.routes");
const capsulesRoutes = require("./routes/capsules.routes");

const app = express();

app.use(cors());
app.use(express.json());

// sanity check DB
app.get("/health", async (_, res) => {
  const r = await pool.query("SELECT NOW() as now");
  res.json({ ok: true, dbTime: r.rows[0].now });
});

app.use("/auth", authRoutes);
app.use("/users", usersRoutes);
app.use("/capsules", capsulesRoutes);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`API running on http://localhost:${port}`));