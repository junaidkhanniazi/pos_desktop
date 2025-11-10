import express from "express";
import { pool } from "../config/db.js";

const router = express.Router();

// 🔹 Get all plans
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM subscription_plans");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch plans" });
  }
});

// 🔹 Create new plan
router.post("/", async (req, res) => {
  try {
    const {
      name,
      price,
      durationDays,
      features,
      maxStores,
      maxProducts,
      maxCategories,
    } = req.body;

    await pool.query(
      `INSERT INTO subscription_plans 
      (name, price, duration_days, features, maxStores, maxProducts, maxCategories)
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        name,
        price,
        durationDays,
        JSON.stringify(features ?? []),
        maxStores,
        maxProducts,
        maxCategories,
      ]
    );

    res.json({ success: true, message: "Plan created successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create plan" });
  }
});

// 🔹 Update plan
router.put("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      price,
      durationDays,
      features,
      maxStores,
      maxProducts,
      maxCategories,
    } = req.body;

    await pool.query(
      `UPDATE subscription_plans SET 
      name=?, price=?, duration_days=?, features=?, 
      maxStores=?, maxProducts=?, maxCategories=?
      WHERE id=?`,
      [
        name,
        price,
        durationDays,
        JSON.stringify(features ?? []),
        maxStores,
        maxProducts,
        maxCategories,
        id,
      ]
    );

    res.json({ success: true, message: "Plan updated successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update plan" });
  }
});

// 🔹 Delete plan
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query("DELETE FROM subscription_plans WHERE id=?", [id]);
    res.json({ success: true, message: "Plan deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete plan" });
  }
});

export default router;
