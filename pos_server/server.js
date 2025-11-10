// server.js
import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import { pool } from "./config/db.js";
import productsRouter from "./routes/products.js";
import ownersRouter from "./routes/owners.js";
import storesRouter from "./routes/stores.js";
import syncRoutes from "./routes/sync.js";
import authRouter from "./routes/auth.js"; // 🆕 ADD
import subscriptionPlansRouter from "./routes/subscriptionPlans.js";

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.use("/api/sync", syncRoutes);
app.use("/api/auth", authRouter); // 🆕 AUTH ROUTES

app.get("/", (req, res) => res.send("✅ POS API is running!"));

app.use("/api/products", productsRouter);
app.use("/api/owners", ownersRouter);
app.use("/api/stores", storesRouter);
app.use("/api/subscription-plans", subscriptionPlansRouter);

const PORT = 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
