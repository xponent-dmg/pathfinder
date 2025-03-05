require('dotenv').config();
const mongoose = require('mongoose');
const Building = require('../models/BuildingModel');

const buildings = [
    { name: 'AB1' },
    { name: 'AB2' },
    { name: 'AB3' },
    { name: 'Clock_Tower' },
    { name: 'MG' }
];

async function seedBuildings() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Clear existing buildings
        await Building.deleteMany({});
        console.log('Cleared existing buildings');

        // Insert new buildings
        const result = await Building.insertMany(buildings);
        console.log('Buildings added:', result);

        await mongoose.connection.close();
    } catch (error) {
        console.error('Error seeding buildings:', error);
        process.exit(1);
    }
}

seedBuildings();