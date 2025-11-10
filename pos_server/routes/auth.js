// routes/auth.js
import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

/**
 * POST /api/auth/login
 * Body: { email, password }
 * Response:
 *   success, role: 'super_admin' | 'owner' | 'staff'
 *   + related data to seed local DB (for owner/staff first login)
 */
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res
      .status(400)
      .json({ success: false, message: "Email & password required" });
  }

  const conn = await pool.getConnection();
  try {
    // 1️⃣ Super Admin check (online only)
    const [superAdminRows] = await conn.query(
      "SELECT id, name, email FROM super_admin WHERE email = ? AND password = ? LIMIT 1",
      [email, password] // TODO: yahan hash laga, same as client
    );

    if (superAdminRows.length) {
      return res.json({
        success: true,
        role: "super_admin",
        superAdmin: superAdminRows[0],
      });
    }

    // 2️⃣ Owner check + subscription + staff + stores
    const [ownerRows] = await conn.query(
      "SELECT * FROM owners WHERE email = ? AND password = ? LIMIT 1",
      [email, password]
    );

    if (ownerRows.length) {
      const owner = ownerRows[0];

      // subscription
      const [subRows] = await conn.query(
        "SELECT * FROM subscriptions WHERE owner_id = ? ORDER BY id DESC LIMIT 1",
        [owner.id]
      );

      // stores
      const [storeRows] = await conn.query(
        "SELECT * FROM stores WHERE ownerId = ?",
        [owner.id]
      );

      return res.json({
        success: true,
        role: "owner",
        owner,
        subscription: subRows[0] || null,
        stores: storeRows,
      });
    }

    // ❌ Nothing matched
    return res.status(401).json({
      success: false,
      message: "Invalid credentials",
    });
  } catch (err) {
    console.error("❌ /api/auth/login error:", err);
    return res.status(500).json({
      success: false,
      message: "Server error",
    });
  } finally {
    conn.release();
  }
});

export default router;
