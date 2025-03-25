require("dotenv").config();
const mongoose = require("mongoose");
const Building = require("../models/BuildingModel");

require("dotenv").config({ path: "./.env" });

const buildings = [
  {
    name: "Main Gate",
    coordinates: {
      lat: 12.840630916128942, // Replace with actual latitude
      lng: 80.15319115308219, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "Guest House",
    coordinates: {
      lat: 12.842496567431807, // Replace with actual latitude
      lng: 80.15251149810855, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "MBA amphitheater",
    coordinates: {
      lat: 12.841341209440696, // Replace with actual latitude
      lng: 80.15406539621543, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "MG Auditorium",
    coordinates: {
      lat: 12.839565958941003, // Replace with actual latitude
      lng: 80.15518063861319, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "Reception",
    coordinates: {
      lat: 12.840911626920219, // Replace with actual latitude
      lng: 80.15322008987862, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "AB1",
    coordinates: {
      lat: 12.84401131611071, // Replace with actual latitude
      lng: 80.15341209566053, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "AB2",
    coordinates: {
      lat: 12.843038235689043, // Replace with actual latitude
      lng: 80.15647208216727, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "AB3",
    coordinates: {
      lat: 12.84371017910154, // Replace with actual latitude
      lng: 80.15453231974783, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "AB4",
    coordinates: {
      lat: 12.842929834430855, // Replace with actual latitude
      lng: 80.15512406146863, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "Delta Block",
    coordinates: {
      lat: 12.841431045996114, // Replace with actual latitude
      lng: 80.1559475146434, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "Sigma Block",
    coordinates: {
      lat: 12.844802181047536, // Replace with actual latitude
      lng: 80.15365092921988, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "Library",
    coordinates: {
      lat: 12.841171014110966, // Replace with actual latitude
      lng: 80.15400682271522, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "Admin Block",
    coordinates: {
      lat: 12.840766823358376, // Replace with actual latitude
      lng: 80.15392608105442, // Replace with actual longitude
    },
    category: "Academics",
  },
  {
    name: "Clock Tower",
    coordinates: {
      lat: 12.841134642922944, // Replace with actual latitude
      lng: 80.154621450455, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "Gazebo",
    coordinates: {
      lat: 12.841580673596193, // Replace with actual latitude
      lng: 80.1548410961776, // Replace with actual longitude
    },
    category: "Eateries",
  },
  {
    name: "North Square",
    coordinates: {
      lat: 12.84422518636874, // Replace with actual latitude
      lng: 80.15408997521628, // Replace with actual longitude
    },
    category: "Eateries",
  },
  {
    name: "V Mart",
    coordinates: {
      lat: 12.844630150189253, // Replace with actual latitude
      lng: 80.15373720608439, // Replace with actual longitude
    },
    category: "Shopping",
  },
  {
    name: "A Block",
    coordinates: {
      lat: 12.8444851819038, // Replace with actual latitude
      lng: 80.1525297339472, // Replace with actual longitude
    },
    category: "Hostel",
  },
  {
    name: "B Block",
    coordinates: {
      lat: 12.842119405874701, // Replace with actual latitude
      lng: 80.15695833661778, // Replace with actual longitude
    },
    category: "Hostel",
  },
  {
    name: "C Block",
    coordinates: {
      lat: 12.842852995637703, // Replace with actual latitude
      lng: 80.15732590645396, // Replace with actual longitude
    },
    category: "Hostel",
  },
  {
    name: "D1 Block",
    coordinates: {
      lat: 12.841177561644203, // Replace with actual latitude
      lng: 80.15397562200542, // Replace with actual longitude
    },
    category: "Hostel",
  },
  {
    name: "D2 Block",
    coordinates: {
      lat: 12.843857814920996, // Replace with actual latitude
      lng: 80.15165292715831, // Replace with actual longitude
    },
    category: "Hostel",
  },
  {
    name: "Health Center",
    coordinates: {
      lat: 12.841617517708704, // Replace with actual latitude
      lng: 80.15659009217033, // Replace with actual longitude
    },
    category: "Others",
  },
  {
    name: "Cricket Ground",
    coordinates: {
      lat: 12.84227621188421, // Replace with actual latitude
      lng: 80.15490666409566, // Replace with actual longitude
    },
    category: "Sports",
  },
  {
    name: "Football Ground",
    coordinates: {
      lat: 12.842590913801274, // Replace with actual latitude
      lng: 80.15301068313566, // Replace with actual longitude
    },
    category: "Sports",
  },
  {
    name: "Basketball Court",
    coordinates: {
      lat: 12.84251270844881, // Replace with actual latitude
      lng: 80.15327314163967, // Replace with actual longitude
    },
    category: "Sports",
  },
  {
    name: "Tennis Court",
    coordinates: {
      lat: 12.843004101139742, // Replace with actual latitude
      lng: 80.15308578498474, // Replace with actual longitude
    },
    category: "Sports",
  },
  {
    name: "Swimming Pool",
    coordinates: {
      lat: 12.840995114992017, // Replace with actual latitude
      lng: 80.15636607862227, // Replace with actual longitude
    },
    category: "Sports",
  },
  {
    name: "Dominoes",
    coordinates: {
      lat: 12.843802373692364, // Replace with actual latitude
      lng: 80.15269160707984, // Replace with actual longitude
    },
    category: "Eateries",
  },
  {
    name: "Gym Khana",
    coordinates: {
      lat: 12.843442260798893, // Replace with actual latitude
      lng: 80.15259829580846, // Replace with actual longitude
    },
    category: "Eateries",
  },
  {
    name: "Tea Tier",
    coordinates: {
      lat: 12.843835161840287, // Replace with actual latitude
      lng: 80.15253327401875, // Replace with actual longitude
    },
    category: "Eateries",
  },
];

async function seedBuildings() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB");

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
