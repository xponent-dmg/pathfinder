const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// Updated MongoDB connection without deprecated options
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("Connected to Atlas"))
  .catch((err) => console.error("MongoDB connection error:", err));

const authRoutes = require("./routes/auth");
const eventRoutes = require("./routes/events");
const buildingRoutes = require("./routes/buildings");

app.use("/api/auth", authRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/buildings", buildingRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`Server running on port ${PORT}`)
);
