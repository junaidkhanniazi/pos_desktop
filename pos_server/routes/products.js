import express from "express";
const router = express.Router();
router.get("/", (req, res) => res.send("Products route OK"));
export default router;
