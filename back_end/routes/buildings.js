const express = require('express');
const router = express.Router();
const Building = require('../models/BuildingModel');
const { auth } = require('../middleware/auth');

// Get all buildings
router.get('/', async (req, res) => {
  try {
    const buildings = await Building.find().select('name coordinates category');
    res.json(buildings);
  } catch (error) {
    console.error('Error fetching buildings:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Get building with events
router.get('/:name', async (req, res) => {
  try {
    const building = await Building.findOne({ name: req.params.name })
      .populate({
        path: 'events',
        match: { endTime: { $gt: new Date() } },
        populate: { path: 'createdBy', select: 'clubName -_id' }
      });
    
    if (!building) {
      return res.status(404).json({ error: 'Building not found' });
    }
    
    res.json(building);
  } catch (error) {
    console.error('Error fetching building details:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
// Get buildings by category
router.get('/category/:categoryName', async (req, res) => {
  try {
    const { categoryName } = req.params;
    const buildings = await Building.find({ category: categoryName })
      .select('name coordinates category');
    
    if (buildings.length === 0) {
      return res.status(404).json({ message: 'No buildings found in this category' });
    }
    
    res.json(buildings);
  } catch (error) {
    console.error('Error fetching buildings by category:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
module.exports = router;
