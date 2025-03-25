require("dotenv").config();
const mongoose = require("mongoose");
const Building = require("../models/BuildingModel");

require("dotenv").config({ path: "./.env" });

const buildings = [
  {
    name: "AB1",
    coordinates: {
      lat: 12.84401131611071, // Replace with actual latitude
      lng: 80.15341209566053, // Replace with actual longitude
    },
  },
  {
    name: "AB2",
    coordinates: {
      lat: 12.843038235689043, // Replace with actual latitude
      lng: 80.15647208216727, // Replace with actual longitude
    },
  },
  {
    name: "Library",
    coordinates: {
      lat: 12.841177561644203, // Replace with actual latitude
      lng: 80.15397562200542, // Replace with actual longitude
    },
  },
];

async function seedBuildings() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB\n", process.env.MONGODB_URI);

    // Clear existing buildings
    await Building.deleteMany({});
    console.log("Cleared existing buildings");

    // Insert new buildings
    const result = await Building.insertMany(buildings);
    console.log("Buildings added:", result);

    await mongoose.connection.close();
  } catch (error) {
    console.error("Error seeding buildings:", error);
    process.exit(1);
  }
}

seedBuildings();
