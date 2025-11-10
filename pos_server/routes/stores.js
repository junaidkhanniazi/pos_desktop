// // routes/stores.js
// import express from "express";
// import { pool } from "../config/db.js";

// const router = express.Router();

// /**
//  * 🟢 Get all stores for an owner
//  */
// router.get("/owner/:ownerId", async (req, res) => {
//   try {
//     const { ownerId } = req.params;

//     const [rows] = await pool.query(
//       `SELECT id, storeName, folderPath, dbPath, createdAt
//        FROM stores
//        WHERE ownerId = ?
//        ORDER BY id DESC`,
//       [ownerId]
//     );

//     res.json(rows);
//   } catch (err) {
//     console.error("❌ Error fetching stores:", err);
//     res.status(500).json({ error: "Server error fetching stores" });
//   }
// });

// /**
//  * 🟢 Add new store (checks subscription limit)
//  */
// router.post("/", async (req, res) => {
//   try {
//     const { ownerId, ownerName, storeName, folderPath, dbPath } = req.body;

//     if (!ownerId || !storeName || !folderPath || !dbPath) {
//       return res.status(400).json({
//         error:
//           "Missing required fields (ownerId, storeName, folderPath, dbPath)",
//       });
//     }

//     // 🔹 Get active subscription for owner
//     const [subs] = await pool.query(
//       `SELECT subscription_plan_id, subscription_plan_name
//        FROM subscriptions
//        WHERE owner_id = ? AND status = 'active'
//        ORDER BY id DESC LIMIT 1`,
//       [ownerId]
//     );

//     if (!subs.length) {
//       return res.status(403).json({
//         error: "No active subscription found. Please activate a plan first.",
//       });
//     }

//     // 🔹 Get plan limits
//     const [plan] = await pool.query(
//       "SELECT max_stores FROM subscription_plans WHERE id = ? LIMIT 1",
//       [subs[0].subscription_plan_id]
//     );

//     const maxStores = plan[0]?.max_stores || 0;

//     // 🔹 Count current stores
//     const [countRows] = await pool.query(
//       "SELECT COUNT(*) AS count FROM stores WHERE ownerId = ?",
//       [ownerId]
//     );

//     const currentCount = countRows[0].count;

//     if (currentCount >= maxStores) {
//       return res.status(403).json({
//         error: `Store limit reached (${maxStores}). Upgrade your plan to add more.`,
//       });
//     }

//     // If ID is provided (from offline store), use it, else auto increment
//     const [result] = await pool.query(
//       `INSERT INTO stores (id, ownerId, storeName, folderPath, dbPath, createdAt, updatedAt)
//    VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
//       [id || null, ownerId, storeName, folderPath, dbPath]
//     );

//     res.json({
//       success: true,
//       message: "Store added successfully",
//       store: {
//         id: result.insertId,
//         storeName,
//         folderPath,
//         dbPath,
//       },
//     });
//   } catch (err) {
//     console.error("❌ Error adding store:", err);
//     res.status(500).json({ error: "Server error adding store" });
//   }
// });

// /**
//  * 🔴 Delete store
//  */
// router.delete("/:id", async (req, res) => {
//   try {
//     const { id } = req.params;

//     const [result] = await pool.query("DELETE FROM stores WHERE id = ?", [id]);

//     if (result.affectedRows === 0) {
//       return res.status(404).json({ error: "Store not found" });
//     }

//     res.json({ success: true, message: "Store deleted successfully" });
//   } catch (err) {
//     console.error("❌ Error deleting store:", err);
//     res.status(500).json({ error: "Server error deleting store" });
//   }
// });

// export default router;

// routes/stores.js
import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

/**
 * 🟢 Get all stores for an owner
 */
router.get("/owner/:ownerId", async (req, res) => {
  try {
    const { ownerId } = req.params;
    const [rows] = await pool.query(
      `SELECT id, storeName, folderPath, dbPath, createdAt 
       FROM stores 
       WHERE ownerId = ? 
       ORDER BY id DESC`,
      [ownerId]
    );
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching stores:", err);
    res.status(500).json({ error: "Server error fetching stores" });
  }
});

/**
 * 🟢 Add new store (checks subscription limit)
 */
router.post("/", async (req, res) => {
  try {
    const { id, ownerId, ownerName, storeName, folderPath, dbPath } = req.body;

    if (!ownerId || !storeName || !folderPath || !dbPath) {
      return res.status(400).json({
        error:
          "Missing required fields (ownerId, storeName, folderPath, dbPath)",
      });
    }

    // 🔹 Get active subscription for owner
    const [subs] = await pool.query(
      `SELECT subscription_plan_id 
       FROM subscriptions 
       WHERE owner_id = ? AND status = 'active' 
       ORDER BY id DESC LIMIT 1`,
      [ownerId]
    );

    if (!subs.length) {
      return res.status(403).json({
        error: "No active subscription found. Please activate a plan first.",
      });
    }

    // 🔹 Get plan limits (correct column: maxStores)
    const [plan] = await pool.query(
      "SELECT maxStores FROM subscription_plans WHERE id = ? LIMIT 1",
      [subs[0].subscription_plan_id]
    );

    const maxStores = plan[0]?.maxStores || 0;

    // 🔹 Count current stores
    const [countRows] = await pool.query(
      "SELECT COUNT(*) AS count FROM stores WHERE ownerId = ?",
      [ownerId]
    );
    const currentCount = countRows[0].count;

    if (maxStores > 0 && currentCount >= maxStores) {
      return res.status(403).json({
        error: `Store limit reached (${maxStores}). Upgrade your plan to add more.`,
      });
    }

    // ✅ Insert new store (use provided id if exists)
    const [result] = await pool.query(
      `INSERT INTO stores (id, ownerId, storeName, folderPath, dbPath, createdAt, updatedAt)
       VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
      [id || null, ownerId, storeName, folderPath, dbPath]
    );

    res.json({
      success: true,
      message: "Store added successfully",
      store: {
        id: id || result.insertId,
        storeName,
        folderPath,
        dbPath,
      },
    });
  } catch (err) {
    console.error("❌ Error adding store:", err);
    res.status(500).json({ error: "Server error adding store" });
  }
});

/**
 * 🔴 Delete store
 */
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query("DELETE FROM stores WHERE id = ?", [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Store not found" });
    }
    res.json({ success: true, message: "Store deleted successfully" });
  } catch (err) {
    console.error("❌ Error deleting store:", err);
    res.status(500).json({ error: "Server error deleting store" });
  }
});

export default router;
