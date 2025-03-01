const mongoose = require('mongoose');
const bcrypt = require('bcrypt'); //For password Hashing

const ClubLeaderSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  clubName: { type: String, required: true },
  events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }]
}, {
  timestamps: true
});

// Replacing all the non-encrypted passwords with encrypted ones
ClubLeaderSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 5);
  }
  next();
});

module.exports = mongoose.model('ClubLeader', ClubLeaderSchema);
