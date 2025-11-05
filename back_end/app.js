const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("Connected to MongoDB Atlas"))
  .catch((err) => console.error("MongoDB connection error:", err));

const authRoutes = require("./routes/auth");
const eventRoutes = require("./routes/events");
const buildingRoutes = require("./routes/buildings");
const healthRoute = require("./routes/health");

app.use("/api/auth", authRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/buildings", buildingRoutes);
app.use("/health", healthRoute);

const client = require("prom-client");

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
});

app.get("/", (req, res) => {
  res.send("Prometheus set up :)");
});

// // Optional: schedule scraper if enabled via env flag
// if (process.env.ENABLE_EVENT_SCRAPER === "true") {
//   const cron = require("node-cron");
//   const { scrapeEvents } = require("./jobs/scrapeEvents");
//   const schedule = process.env.SCRAPER_CRON || "0 */6 * * *";
//   console.log(`[scraper] Scheduling with cron: ${schedule}`);
//   cron.schedule(schedule, () => {
//     console.log("[scraper] Running scheduled scrape...");
//     scrapeEvents();
//   });

//   // Optional immediate run at startup (comment out if not desired)
//   // scrapeEvents();
// }

const PORT = process.env.PORT || 5050;
app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
