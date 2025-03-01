//Contains authMiddleware which moakes sure the token is valid and sends the auth for others to use
//Handles routes and authentication of the JWT
const express = require('express');
const router = express.Router();
require('dotenv').config();
const ClubLeader = require('../models/ClubLeaderModel');
const User = require('../models/NormalUserModel');
const jwt = require('jsonwebtoken');
const SECRET_KEY = process.env.JWT_SECRET || "777";
const bcrypt = require('bcrypt');

router.post('/register-user', async (req, res) => {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        return res.status(400).json({ error: 'Please provide username and password' });
      }
  
      // Check if the user already exists in normal user model
      const existingUser = await User.findOne({ username });
      if (existingUser) {
        return res.status(400).json({ error: 'User already exists' });
      }
  
      // Create a new normal user
      const newUser = new User({ username, password });
      await newUser.save();
  
      res.status(201).json({ message: 'User registration successful' });
    } catch (error) {
      console.error("Registration error:", error);
      res.status(500).json({ error: "Server error" });
    }
  });

router.post('/login-clubleader', async (req, res) => {
    try {
        const { username, password } = req.body;
        console.log("Login request received:", req.body);

        // Check if username exists
        const clubLeader = await ClubLeader.findOne({ username });
        if (!clubLeader) {
          return res.status(400).json({ error: "User not found" });
        }

        console.log("User found:", clubLeader);

        // Compare hashed password using bcrypt
        const isMatch = await bcrypt.compare(password, clubLeader.password);

        console.log("Password Match:", isMatch);

        if (!isMatch) {
            return res.status(400).json({ error: "Incorrect Password" });
        }

        // Generate JWT token
        const token = jwt.sign(
          { id: clubLeader._id, username: clubLeader.username, role: "clubLeader", clubName: clubLeader.clubName },
          SECRET_KEY,
          { expiresIn: "30d" }
        );
        console.log("Generated Token:", token);
        res.status(200).json({ token });
    } catch (error) {
        console.error("Login Error:", error);
        res.status(500).json({ error: "Server error" });
    }
});

router.post('/login-user', async (req, res) => {
    try {
        const { username, password } = req.body;
        console.log("Login request received:", req.body);

        // Check for username
        const user = await User.findOne({ username });

        if (!user) {
            return res.status(400).json({ error: "User not found" });
        }

        console.log("User found:", user);

        // Compare hashed password using bcrypt
        const isMatch = await bcrypt.compare(password, user.password);

        console.log("Password Match:", isMatch);

        if (!isMatch) {
            return res.status(400).json({ error: "Incorrect Password" });
        }

        // Generate JWT token
        const token = jwt.sign(
            { id: user._id, username: user.username, clubName: user.clubName},
            SECRET_KEY,
            { expiresIn: "30d" } 
        );

        console.log("Generated Token:", token);
        res.status(200).json({ token });

    } catch (error) {
        console.error("Login Error:", error);
        res.status(500).json({ error: "Server error" });
    }
});

// Auth middleware - export as a separate object
const authMiddleware = (req, res, next) => {
  const token = req.header("Authorization");
  if (!token) {
    return res.status(401).json({ error: "Access Denied. No Token Provided." });
  }

  try {
    // Checks token value by remove "Bearer " prefix (first 7 letters)
    const tokenValue = token.startsWith('Bearer ') ? token.slice(7) : token;
    // Verifies that the token is genuine using the secret key    
    const decoded = jwt.verify(tokenValue, SECRET_KEY);
    req.user = decoded;
    // Middleware has finished its work
    next();
  } catch (error) {
    console.error("Token verification error:", error);
    res.status(400).json({ error: "Invalid Token" });
  }
};

// Export both the router and the auth middleware
module.exports = {
  router,
  // AuthMiddleware can be called auth
  auth: authMiddleware
};
