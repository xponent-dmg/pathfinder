require('dotenv').config();
const mongoose = require('mongoose');
const Location = require('../models/LocationModel');

// Sample location data - replace with your actual coordinates and building names
const locationsData = [
  {
    name: "AB1",
    description: "Main administrative building with offices and classrooms",
    coordinates: {
      lat: 12.84401131611071, // Replace with actual latitude
      lng: 80.15341209566053, // Replace with actual longitude
    },
    category: "building",
  },
  {
    name: "Library",
    description: "Central library with study spaces and resources",
    coordinates: {
      lat: 12.841177561644203, // Replace with actual latitude
      lng: 80.15397562200542, // Replace with actual longitude
    },
    category: "building",
  },
  {
    name: "AB2",
    description: "Hub for student activities and dining options",
    coordinates: {
      lat: 12.843038235689043, // Replace with actual latitude
      lng: 80.15647208216727, // Replace with actual longitude
    },
    category: "building",
  },
  // Add more locations as needed
];

async function seedLocations() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    await Location.deleteMany({});
    console.log('Cleared existing locations');

    await Location.insertMany(locationsData);
    console.log('Locations seeded successfully');
  } catch (error) {
    console.error('Error seeding locations:', error);
  } finally {
    await mongoose.connection.close();
    console.log('MongoDB connection closed');
    process.exit(0);
  }
}

seedLocations();
