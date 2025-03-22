const mongoose = require('mongoose');

const LocationSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true,
    trim: true
  },
  description: { 
    type: String,
    default: ''
  },
  coordinates: {
    lat: { 
      type: Number, 
      required: true 
    },
    lng: { 
      type: Number, 
      required: true 
    }
  },
  category: { 
    type: String,
    enum: ['building', 'landmark', 'facility', 'other'],
    default: 'building'
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Location', LocationSchema);
