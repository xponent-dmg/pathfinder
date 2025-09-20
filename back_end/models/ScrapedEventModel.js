const mongoose = require("mongoose");

const ScrapedEventSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    dateText: { type: String },
    venue: { type: String },
    description: { type: String },
    link: { type: String },
    source: { type: String },
    // Optional normalized dates if you map dateText => Date later
    startTime: { type: Date },
    endTime: { type: Date },
    // A deterministic hash to dedupe events from the same source
    hash: { type: String, required: true, index: true, unique: true },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("ScrapedEvent", ScrapedEventSchema);
