import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { pool } from "../config/db.js";

const router = express.Router();

// =============================
// 📁 Configure Upload Directory
// =============================
const uploadDir = path.resolve("uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// =============================
// ⚙️ Multer Setup for Receipts
// =============================
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `receipt-${uniqueSuffix}${ext}`);
  },
});

// 🔴 IMPORTANT: field name must match Flutter
const upload = multer({ storage });

// =============================
// 🟢 Register Owner (with store data from client)
// =============================
router.post("/register", async (req, res) => {
  try {
    // ✅ accept both camelCase & snake_case
    const shopName = req.body.shopName || req.body.shop_name;
    const ownerName = req.body.ownerName || req.body.owner_name;
    const { email, password, contact } = req.body;

    // ✅ store info from Flutter
    const storeName = req.body.storeName || req.body.store_name;
    const folderPath = req.body.folderPath || req.body.folder_path;
    const dbPath = req.body.dbPath || req.body.db_path;

    // 🧩 Validate input
    if (
      !shopName ||
      !ownerName ||
      !email ||
      !password ||
      !contact ||
      !storeName ||
      !folderPath ||
      !dbPath
    ) {
      return res.status(400).json({
        error:
          "Missing required fields (shopName, ownerName, email, password, contact, storeName, folderPath, dbPath)",
      });
    }

    const conn = await pool.getConnection();
    await conn.beginTransaction();

    // 🔹 Check if owner already exists
    const [existing] = await conn.query(
      "SELECT id FROM owners WHERE email = ?",
      [email]
    );
    if (existing.length > 0) {
      await conn.release();
      return res.status(409).json({ error: "Email already registered" });
    }

    // 🔹 Insert new owner
    const [ownerResult] = await conn.query(
      `INSERT INTO owners 
         (shop_name, owner_name, email, password, contact, status, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 'pending', 0, NOW(), NOW())`,
      [shopName, ownerName, email, password, contact]
    );

    const ownerId = ownerResult.insertId;

    // 🔹 Insert store (values from Flutter)
    const [storeResult] = await conn.query(
      `INSERT INTO stores 
         (ownerId, storeName, folderPath, dbPath, createdAt, updatedAt)
       VALUES (?, ?, ?, ?, NOW(), NOW())`,
      [ownerId, storeName, folderPath, dbPath]
    );

    await conn.commit();
    conn.release();

    res.status(201).json({
      success: true,
      message: "Owner and store created successfully",
      ownerId,
      store: {
        id: storeResult.insertId,
        ownerId,
        storeName,
        folderPath,
        dbPath,
      },
    });
  } catch (err) {
    console.error("❌ Error in /register:", err);
    res.status(500).json({ error: "Server error during registration" });
  }
});

// =============================
// 🟡 Upload Subscription Receipt (Upgrade Plan)
// =============================
router.post(
  "/subscriptions",
  upload.single("receipt_image"),
  async (req, res) => {
    try {
      // Accept both naming styles
      const ownerIdRaw = req.body.ownerId || req.body.owner_id;
      const planName = req.body.subscriptionPlan || req.body.plan_name;
      const amountRaw = req.body.subscriptionAmount || req.body.amount;
      const receiptImage = req.file ? req.file.filename : null;

      if (!ownerIdRaw || !planName || !amountRaw || !receiptImage) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      // 🔹 Resolve owner ID (email → id)
      let ownerId = ownerIdRaw;
      if (ownerIdRaw.includes("@")) {
        const [rows] = await pool.query(
          "SELECT id FROM owners WHERE email = ? LIMIT 1",
          [ownerIdRaw]
        );
        if (!rows.length)
          return res.status(404).json({ error: "Owner not found" });
        ownerId = rows[0].id;
      }

      const amount = parseFloat(amountRaw);

      // 🔹 Find plan ID and duration
      const [planRows] = await pool.query(
        "SELECT id, duration_days FROM subscription_plans WHERE name = ? LIMIT 1",
        [planName]
      );
      if (!planRows.length)
        return res.status(404).json({ error: "Subscription plan not found" });

      const planId = planRows[0].id;
      const durationDays = planRows[0].duration_days || 30;

      const now = new Date();
      const endDate = new Date(now);
      endDate.setDate(now.getDate() + durationDays);

      // 🟡 1️⃣ Deactivate existing active subscription
      await pool.query(
        `UPDATE subscriptions 
         SET status = 'inactive', updated_at = NOW()
         WHERE owner_id = ? AND status = 'active'`,
        [ownerId]
      );

      // 🟢 2️⃣ Insert NEW subscription as ACTIVE
      await pool.query(
        `INSERT INTO subscriptions 
          (owner_id, subscription_plan_id, subscription_plan_name, status, receipt_image, 
           payment_date, subscription_amount, subscription_start_date, subscription_end_date, 
           created_at, updated_at)
         VALUES (?, ?, ?, 'active', ?, NOW(), ?, ?, ?, NOW(), NOW())`,
        [ownerId, planId, planName, receiptImage, amount, now, endDate]
      );

      res.json({
        success: true,
        message: "Subscription upgraded and activated successfully",
        planId,
        receiptImage,
      });
    } catch (err) {
      console.error("❌ Subscription upload failed:", err);
      res
        .status(500)
        .json({ error: "Server error during subscription upload" });
    }
  }
);

// =============================
// 🔵 Get All Owners (Admin use)
// =============================
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM owners ORDER BY id DESC");
    res.json(rows);
  } catch (err) {
    console.error("❌ Fetch owners error:", err);
    res.status(500).json({ error: "Server error fetching owners" });
  }
});

// =============================
// 🔵 Get Pending Owners with Subscriptions
// =============================
router.get("/pending-with-subscriptions", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        o.id,
        o.shop_name,
        o.owner_name,
        o.email,
        o.contact,
        o.status,
        s.subscription_plan_name,
        s.subscription_amount,
        s.receipt_image,
        s.subscription_start_date,
        s.subscription_end_date,
        o.created_at
      FROM owners o
      LEFT JOIN subscriptions s ON s.owner_id = o.id
      WHERE o.status = 'pending'
      ORDER BY o.created_at DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching pending owners with subscriptions:", err);
    res.status(500).json({ error: "Server error fetching pending owners" });
  }
});

// =============================
// 🔵 Get latest subscription for a specific owner
// =============================
router.get("/subscriptions/owner/:ownerId", async (req, res) => {
  try {
    const { ownerId } = req.params;

    const [rows] = await pool.query(
      `SELECT * FROM subscriptions 
       WHERE owner_id = ?
       ORDER BY id DESC
       LIMIT 1`,
      [ownerId]
    );

    // Flutter side list expect kar raha hai, isliye array bhej rahe hain
    if (!rows.length) {
      return res.json([]);
    }

    res.json(rows); // [ { ...subscription row... } ]
  } catch (err) {
    console.error("❌ Error fetching subscription for owner:", err);
    res.status(500).json({ error: "Server error fetching owner subscription" });
  }
});

// =============================
// 🟢 Activate Owner Account (Simplified)
// =============================
router.post("/activate", async (req, res) => {
  try {
    const ownerId = req.body.ownerId || req.body.owner_id;
    const durationDays =
      parseInt(req.body.durationDays || req.body.duration_days) || 30;

    if (!ownerId) {
      return res.status(400).json({ error: "Missing owner_id" });
    }

    // 🔹 Fetch latest subscription
    const [subs] = await pool.query(
      `SELECT id, subscription_start_date 
       FROM subscriptions 
       WHERE owner_id = ? 
       ORDER BY id DESC 
       LIMIT 1`,
      [ownerId]
    );

    if (!subs.length) {
      return res
        .status(404)
        .json({ error: "No subscription found for this owner" });
    }

    const sub = subs[0];
    const startDate = new Date(sub.subscription_start_date || new Date());
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + durationDays);

    // ✅ Activate subscription
    await pool.query(
      `UPDATE subscriptions 
       SET status = 'active', subscription_end_date = ?, updated_at = NOW()
       WHERE id = ?`,
      [endDate, sub.id]
    );

    // ✅ Activate owner
    await pool.query(
      `UPDATE owners 
       SET status = 'active', is_active = 1, updated_at = NOW()
       WHERE id = ?`,
      [ownerId]
    );

    res.json({
      success: true,
      message: `Owner ${ownerId} activated successfully for ${durationDays} days.`,
    });
  } catch (err) {
    console.error("❌ Error activating owner:", err);
    res.status(500).json({ error: "Server error during owner activation" });
  }
});

// =============================
// 🔵 Get Approved Owners
// =============================
router.get("/approved", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        o.id,
        o.shop_name,
        o.owner_name,
        o.email,
        o.contact,
        o.status,
        o.is_active,
        s.subscription_plan_name,
        s.subscription_amount,
        s.subscription_end_date
      FROM owners o
      LEFT JOIN subscriptions s ON s.owner_id = o.id
      WHERE o.status = 'active'
      ORDER BY o.id DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching approved owners:", err);
    res.status(500).json({ error: "Server error fetching approved owners" });
  }
});

// =============================
// 🔵 Get Owner by Email (for login helper)
// =============================
router.post("/by-email", async (req, res) => {
  try {
    const email = req.body.email;
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // 🔹 Fetch owner info
    const [ownerRows] = await pool.query(
      "SELECT * FROM owners WHERE email = ? LIMIT 1",
      [email]
    );

    if (!ownerRows.length) {
      return res.status(404).json({ error: "Owner not found" });
    }

    const owner = ownerRows[0];

    // 🔹 Fetch latest subscription
    const [subRows] = await pool.query(
      `SELECT * FROM subscriptions 
       WHERE owner_id = ? 
       ORDER BY id DESC 
       LIMIT 1`,
      [owner.id]
    );

    // 🔹 Fetch all stores for that owner (optional)
    const [storeRows] = await pool.query(
      "SELECT * FROM stores WHERE ownerId = ?",
      [owner.id]
    );

    res.json({
      success: true,
      owner,
      subscription: subRows.length ? subRows[0] : null,
      stores: storeRows || [],
    });
  } catch (err) {
    console.error("❌ Error fetching owner by email:", err);
    res.status(500).json({ error: "Server error fetching owner by email" });
  }
});

// =============================
// 🔵 Get Active Plan Limit for Owner
// =============================
// ✅ Corrected version
router.get("/:ownerId/plan-limit", async (req, res) => {
  try {
    const { ownerId } = req.params;
    const [sub] = await pool.query(
      `SELECT sp.maxStores AS maxStores
       FROM subscriptions s
       JOIN subscription_plans sp ON sp.id = s.subscription_plan_id
       WHERE s.owner_id = ? AND s.status = 'active'
       ORDER BY s.id DESC LIMIT 1`,
      [ownerId]
    );

    res.json(sub[0] || { maxStores: 0 });
  } catch (err) {
    console.error("❌ Error getting plan limit:", err);
    res.status(500).json({ error: "Failed to fetch plan limit" });
  }
});

export default router;
