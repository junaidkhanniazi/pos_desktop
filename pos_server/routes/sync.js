import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

// ✅ PUSH (from Flutter → MySQL)
router.post("/:table", async (req, res) => {
  const { table } = req.params;
  const data = req.body;

  try {
    // convert object to key/value arrays
    const columns = Object.keys(data);
    const values = Object.values(data);

    // create placeholders (?, ?, ?)
    const placeholders = columns.map(() => "?").join(",");

    const sql = `INSERT INTO ${table} (${columns.join(
      ","
    )}) VALUES (${placeholders})
                 ON DUPLICATE KEY UPDATE ${columns
                   .map((c) => `${c}=VALUES(${c})`)
                   .join(",")}`;

    await pool.query(sql, values);

    res.json({ success: true, table, message: "Data synced successfully" });
  } catch (err) {
    console.error("❌ Sync insert error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ PULL (from MySQL → Flutter)
router.get("/:table", async (req, res) => {
  const { table } = req.params;

  try {
    const [rows] = await pool.query(`SELECT * FROM ${table}`);
    res.json(rows);
  } catch (err) {
    console.error("❌ Sync fetch error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
