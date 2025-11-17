// routes/auth.js
import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

/* ======================================================
   🔹 LOGIN - Super Admin & Owner
   ====================================================== */
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res
      .status(400)
      .json({ success: false, message: "Email & password required" });
  }

  const conn = await pool.getConnection();
  try {
    // 1️⃣ Super Admin check
    const [superAdminRows] = await conn.query(
      "SELECT id, name, email FROM super_admin WHERE email = ? AND password = ? LIMIT 1",
      [email, password]
    );

    if (superAdminRows.length) {
      return res.json({
        success: true,
        role: "super_admin",
        superAdmin: superAdminRows[0],
      });
    }

    // 2️⃣ Owner check + subscription + stores
    const [ownerRows] = await conn.query(
      "SELECT * FROM owners WHERE email = ? AND password = ? LIMIT 1",
      [email, password]
    );

    if (ownerRows.length) {
      const owner = ownerRows[0];

      // ✅ Latest subscription
      const [subRows] = await conn.query(
        "SELECT * FROM subscriptions WHERE owner_id = ? ORDER BY id DESC LIMIT 1",
        [owner.id]
      );

      // ✅ Related stores
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

    // ❌ Invalid credentials
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

/* ======================================================
   🔹 REGISTER - Owner only (no store insert yet)
   ====================================================== */
// routes/auth.js
router.post("/register", async (req, res) => {
  const conn = await pool.getConnection();
  try {
    const {
      ownerName,
      email,
      password,
      contact,
      subscriptionPlanId,
      subscriptionPlanName,
      subscriptionAmount,
      receiptImage, // base64 or path
    } = req.body;

    // ✅ Validate required fields
    if (
      !ownerName ||
      !email ||
      !password ||
      !contact ||
      !subscriptionPlanId ||
      !subscriptionPlanName ||
      !subscriptionAmount ||
      !receiptImage
    ) {
      return res.status(400).json({
        error: "Missing required fields for registration",
      });
    }

    await conn.beginTransaction();

    // 1️⃣ Create owner (no shop_name, no super_admin_id)
    const [ownerResult] = await conn.query(
      `INSERT INTO owners 
        (owner_name, email, password, contact, status, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, 'pending', 0, NOW(), NOW())`,
      [ownerName, email, password, contact]
    );

    const ownerId = ownerResult.insertId;

    // 2️⃣ Create initial subscription entry
    const [subResult] = await conn.query(
      `INSERT INTO subscriptions 
        (owner_id, subscription_plan_id, subscription_plan_name, subscription_amount, 
         receipt_image, status, payment_date, subscription_start_date, subscription_end_date, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 'pending', NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NOW())`,
      [
        ownerId,
        subscriptionPlanId,
        subscriptionPlanName,
        subscriptionAmount,
        receiptImage,
      ]
    );

    await conn.commit();
    conn.release();

    res.status(201).json({
      success: true,
      message: "Owner and subscription registered successfully",
      ownerId,
      subscriptionId: subResult.insertId,
    });
  } catch (err) {
    console.error("❌ Error in /register:", err);
    await conn.rollback();
    conn.release();
    res.status(500).json({ error: "Server error during registration" });
  }
});

export default router;
