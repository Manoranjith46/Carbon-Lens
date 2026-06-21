import express from "express";
import cors from "cors";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

// Firebase is initialized on import
import "./config/firebase.js";

// Route imports
import activityRoutes from "./Routes/activityRoutes.js";
import profileRoutes from "./Routes/profileRoutes.js";
import goalRoutes from "./Routes/goalRoutes.js";
import routineRoutes from "./Routes/routineRoutes.js";
import recommendationRoutes from "./Routes/recommendationRoutes.js";

const app = express();
const PORT = process.env.PORT || 5000;

// ─── Middleware ─────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// Request logger (dev)
app.use((req, _res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// ─── API Routes ─────────────────────────────────────────────────────
app.use("/api/activities", activityRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/goals", goalRoutes);
app.use("/api/routines", routineRoutes);
app.use("/api/recommendations", recommendationRoutes);

// ─── Health Check ───────────────────────────────────────────────────
app.get("/api/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
    service: "CarbonLens API",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
  });
});

// ─── Emission Factors Reference (public) ────────────────────────────
app.get("/api/emission-factors", (_req, res) => {
  import("./config/emissionFactors.js").then((factors) => {
    res.status(200).json({
      success: true,
      data: {
        transport: factors.transportFactors,
        food: factors.foodFactors,
        homeEnergy: factors.homeEnergyFactors,
        purchases: factors.purchaseFactors,
        waste: factors.wasteFactors,
      },
    });
  });
});

// ─── 404 Handler ────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({
    success: false,
    error: "Route not found",
  });
});

// ─── Global Error Handler ───────────────────────────────────────────
app.use(
  (
    err: Error,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction
  ) => {
    console.error("Unhandled error:", err);
    res.status(500).json({
      success: false,
      error: "Internal server error",
    });
  }
);

// ─── Start Server ───────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`
  🌿 CarbonLens API Server
  ────────────────────────
  📡 Running on:    http://localhost:${PORT}
  🔥 Database:      Firebase Firestore
  🏥 Health check:  http://localhost:${PORT}/api/health
  
  Available endpoints:
    GET/POST       /api/activities
    GET/POST       /api/profile
    GET/POST       /api/goals
    GET/POST       /api/routines
    GET            /api/recommendations/:userId
    GET            /api/emission-factors
  `);
});

export default app;
