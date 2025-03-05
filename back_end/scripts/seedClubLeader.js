require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const ClubLeader = require('../models/ClubLeaderModel'); 

const clubLeadersData = [
    { name: "John Doe",username: 'johndoe', password: '123', clubName: 'Coding Club' },
    { name: 'Jane Smith',username: 'janesmith', password: '456', clubName: 'Robotics Club' },
    { name: 'Alice Johnson',username: 'alicejohnson', password: '789', clubName: 'Math Club' },
];

async function seedClubLeader() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        await ClubLeader.deleteMany({});
        console.log('Cleared existing club leaders');

        // Hashing password
        for (let leader of clubLeadersData) {
            leader.password = await bcrypt.hash(leader.password, 10);
        }

        await ClubLeader.insertMany(clubLeadersData);
        console.log('Club leaders seeded successfully with hashed passwords');
    } catch (error) {
        console.error('Error seeding club leaders:', error);
    } finally {
        await mongoose.connection.close();
        console.log('MongoDB connection closed');
        process.exit(0);
    }
}

seedClubLeader();