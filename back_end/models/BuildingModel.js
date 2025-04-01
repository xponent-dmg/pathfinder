//For the Buildings
const mongoose = require('mongoose');
const BuildingSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      enum: [
        "Main Gate",
        "Guest House",
        "MBA Amphitheater",
        "MG Auditorium",
        "Reception",
        "Admin Block",
        "AB1",
        "AB2",
        "AB3",
        "AB4",
        "Delta Block",
        "Sigma Block",
        "Library",
        "Clock Tower",
        "Gazebo",
        "North Square",
        "V Mart",
        "A Block",
        "B Block",
        "C Block",
        "D1 Block",
        "D2 Block",
        "Health Center",
        "Cricket Ground",
        "Football Ground",
        "Basketball Court",
        "Tennis Court",
        "Swimming Pool",
        "Dominoes",
        "Gym Khana",
        "Tea Tier",
      ],
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
    category: {
      type: String,
      required: true,
      enum: ["Others", "Academics", "Hostel", "Sports", "Eateries", "Shopping"],
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
