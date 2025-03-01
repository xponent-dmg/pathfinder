//For the Buildings
const mongoose = require('mongoose');
const BuildingSchema = new mongoose.Schema({
    name: { type: String, required: true, 
      enum: ['AB1', 'AB2', 'AB3', 'Clock_Tower', 'MG']
    },
    events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }]
  }, {
    timestamps: true
  });

  // Name is indexed  in ascending order
  BuildingSchema.index({ name: 1 });
  
  module.exports = mongoose.model('Building', BuildingSchema);
