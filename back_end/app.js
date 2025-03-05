const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
app.use(express.json());

// Updated MongoDB connection without deprecated options
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

const authRoutes = require('./routes/auth');
const eventRoutes = require('./routes/events');
const buildingRoutes = require('./routes/buildings');

app.use('/api/auth', authRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/buildings', buildingRoutes);


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
