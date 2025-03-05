//For the Events
const mongoose = require('mongoose');
const EventSchema = new mongoose.Schema({
    name: { type: String, required: true },
    building: { type: mongoose.Schema.Types.ObjectId, ref: 'Building', required: true },
    startTime: { type: Date, required: true },
    endTime: { type: Date, required: true },
    information: { type: String },
    roomno: { type: String, required: true},
    categories: [{ type: String }],
    clubName: { type: String, required: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'ClubLeader', required: true }
  }, {
    timestamps: true 
  });

  // Ensure startTime is before endTime
  EventSchema.pre('save', function(next) {
    if (this.startTime >= this.endTime) {
      return next(new Error('Start time must be before end time'));
    }
    next();
  });

  EventSchema.index({ categories: 1 }); //Categories in ascending order
  EventSchema.index({ startTime: 1, endTime: 1 }); //Dates in ascending order
  module.exports = mongoose.model('Event', EventSchema);