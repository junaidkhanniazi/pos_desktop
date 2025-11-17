// import express from "express";
// import { pool } from "../config/db.js";

// const router = express.Router();

// // ✅ PUSH (from Flutter → MySQL)
// router.post("/:table", async (req, res) => {
//   const { table } = req.params;
//   const data = req.body;

//   try {
//     // convert object to key/value arrays
//     const columns = Object.keys(data);
//     const values = Object.values(data);

//     // create placeholders (?, ?, ?)
//     const placeholders = columns.map(() => "?").join(",");

//     const sql = `INSERT INTO ${table} (${columns.join(
//       ","
//     )}) VALUES (${placeholders})
//                  ON DUPLICATE KEY UPDATE ${columns
//                    .map((c) => `${c}=VALUES(${c})`)
//                    .join(",")}`;

//     await pool.query(sql, values);

//     res.json({ success: true, table, message: "Data synced successfully" });
//   } catch (err) {
//     console.error("❌ Sync insert error:", err);
//     res.status(500).json({ error: err.message });
//   }
// });

// // ✅ PULL (from MySQL → Flutter)
// router.get("/:table", async (req, res) => {
//   const { table } = req.params;

//   try {
//     const [rows] = await pool.query(`SELECT * FROM ${table}`);
//     res.json(rows);
//   } catch (err) {
//     console.error("❌ Sync fetch error:", err);
//     res.status(500).json({ error: err.message });
//   }
// });

// export default router;


import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

// 🔒 Tables that are owner-specific (safe to sync)
const ALLOWED_TABLES = [
  "stores",
  "products",
  "brands",
  "categories",
  "customers",
  "expenses",
  "sales",
  "sale_items",
  "suppliers",
];

// ❌ Tables that should never sync directly (server-managed)
const BLOCKED_TABLES = [
  "owners",
  "subscriptions",
  "subscription_plans",
  "super_admin",
  "sync_metadata",
];

// ===============================================================
// ✅ PUSH (Flutter → MySQL)
// ===============================================================
router.post("/:table", async (req, res) => {
  const { table } = req.params;
  const data = req.body;

  try {
    // 1️⃣ Validate table
    if (!ALLOWED_TABLES.includes(table)) {
      return res.status(403).json({
        error: `Table '${table}' is restricted or not allowed for sync.`,
      });
    }

    // 2️⃣ Ensure ownerId present
    if (!data.ownerId) {
      return res.status(400).json({
        error: "Missing ownerId in payload — cannot sync without owner context.",
      });
    }

    // 3️⃣ Build dynamic SQL
    const columns = Object.keys(data);
    const values = Object.values(data);
    const placeholders = columns.map(() => "?").join(",");

    const sql = `
      INSERT INTO ${table} (${columns.join(",")})
      VALUES (${placeholders})
      ON DUPLICATE KEY UPDATE ${columns
        .map((c) => `${c}=VALUES(${c})`)
        .join(",")}
    `;

    await pool.query(sql, values);

    res.json({ success: true, table, message: "Data synced successfully" });
  } catch (err) {
    console.error("❌ Sync insert error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ===============================================================
// ✅ PULL (MySQL → Flutter)
// Only owner-specific tables and filtered by ?ownerId=
// ===============================================================
router.get("/:table", async (req, res) => {
  const { table } = req.params;
  const ownerId = parseInt(req.query.ownerId, 10);

  try {
    // 1️⃣ Block restricted tables
    if (BLOCKED_TABLES.includes(table)) {
      return res.status(403).json({
        error: `Table '${table}' is restricted from sync.`,
      });
    }

    // 2️⃣ Only allow whitelisted tables
    if (!ALLOWED_TABLES.includes(table)) {
      return res.status(403).json({
        error: `Table '${table}' not allowed for sync.`,
      });
    }

    // 3️⃣ If ownerId missing, block the request
    if (!ownerId) {
      return res.status(400).json({
        error: "Missing ownerId in query. Example: /sync/stores?ownerId=2",
      });
    }

    // 4️⃣ Only pull rows that belong to this owner
    const [rows] = await pool.query(
      `SELECT * FROM ${table} WHERE ownerId = ? ORDER BY id DESC`,
      [ownerId]
    );

    res.json(rows);
  } catch (err) {
    console.error("❌ Sync fetch error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
