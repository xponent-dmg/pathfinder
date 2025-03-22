//For the Buildings
const mongoose = require('mongoose');
const BuildingSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      enum: ["AB1", "AB2", "AB3", "Library", "MG"],
    },
    coordinates: {
      lat: {
        type: Number,
        required: true,
      },
      lng: {
        type: Number,
        required: true,
      },
    },
    events: [{ type: mongoose.Schema.Types.ObjectId, ref: "Event" }],
  },
  {
    timestamps: true,
  }
);

  // Name is indexed  in ascending order
  BuildingSchema.index({ name: 1 });
  
  module.exports = mongoose.model('Building', BuildingSchema);
