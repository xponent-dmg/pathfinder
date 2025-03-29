const express = require("express");
const router = express.Router();
const Event = require("../models/EventModel");
const Building = require("../models/BuildingModel");
const ClubLeader = require("../models/ClubLeaderModel");
const { auth } = require("../middleware/auth");

//Creating the event
router.post("/create", auth, async (req, res) => {
  console.log("Create event request received:", req.body);
  console.log("User info:", req.user);

  if (req.user.role !== "clubLeader") {
    console.log("Access denied: User role is", req.user.role);
    return res
      .status(403)
      .json({ error: "Access denied: Only club leaders can create events." });
  }
  try {
    // Find building by name
    let building;
    if (req.body.isOnline === false) {
      console.log("Looking for building:", req.body.building);
      building = await Building.findOne({ name: req.body.building });
      if (!building) {
        console.log("Building not found:", req.body.building);
        return res.status(400).send({
          error:
            "Invalid building name",
        });
      }
      console.log("Building found:", building.name, building._id);
    }

    const event = new Event({
      name: req.body.name,
      imageUrl: req.body.imageUrl,
      price: req.body.price,
      startTime: req.body.startTime,
      endTime: req.body.endTime,
      information: req.body.information,
      isOnline: req.body.isOnline,
      isMandatory: req.body.isMandatory,
      roomno: req.body.roomno,
      categories: req.body.categories,
      clubName: req.user.clubName,
      createdBy: req.user.id,
      ...(req.body.isOnline ? {} : { building: building?._id }),
    });
    console.log("Event object created:", event);

    // Save the event
    await event.save();
    console.log("Event saved successfully with ID:", event._id);

    // Update the building document to include this event
    if (!req.body.isOnline) {
      building.events.push(event._id);
      await building.save();
      console.log("Event added to building events array");
    }

    // Update the club leader document to include this event
    console.log("Looking for club leader with ID:", req.user.id);
    const clubLeader = await ClubLeader.findById(req.user.id);
    if (clubLeader) {
      clubLeader.events.push(event._id);
      await clubLeader.save();
      console.log("Event added to club leader's events array");
    } else {
      console.log("Club leader not found with ID:", req.user.id);
    }

    // Populate building name for response if not online
    if (req.body.isOnline === false) {
      console.log("trying to push event to location");
      await event.populate("building", "name");
    }
    console.log("Sending response with populated event:", event);
    res.status(201).send(event);
  } catch (error) {
    console.error("Error creating event:", error);
    res.status(400).send(error);
  }
});

router.get("/search", async (req, res) => {
  console.log("Search request received with query:", req.query);

  try {
    const now = new Date();
    const searchTerm = req.query.q || "";
    let filters = { endTime: { $gt: now } }; // Ensures only upcoming events

    // General search by name, category, or club name
    if (searchTerm) {
      filters.$or = [
        { name: { $regex: searchTerm, $options: "i" } },
        { categories: { $regex: searchTerm, $options: "i" } },
        { clubName: { $regex: searchTerm, $options: "i" } },
      ];
    }

    // Category filter
    if (req.query.category) {
      filters.categories = { $regex: req.query.category, $options: "i" };
    }

    // Club Name filter
    if (req.query.clubName) {
      filters.clubName = { $regex: req.query.clubName, $options: "i" };
    }

    // Building filter
    if (req.query.building) {
      const building = await Building.findOne({ name: req.query.building });
      if (!building) {
        console.log("Building not found:", req.query.building);
        return res.status(404).json({ error: "Building not found" });
      }
      filters.building = building._id;
    }

    // Price Range Filter
    if (req.query.minPrice || req.query.maxPrice) {
      filters.price = {};
      if (req.query.minPrice)
        filters.price.$gte = parseFloat(req.query.minPrice);
      if (req.query.maxPrice)
        filters.price.$lte = parseFloat(req.query.maxPrice);
    }

    // Date Range Filter
    if (req.query.startDate || req.query.endDate) {
      filters.startTime = {};
      if (req.query.startDate)
        filters.startTime.$gte = new Date(req.query.startDate);
      if (req.query.endDate)
        filters.startTime.$lte = new Date(req.query.endDate);
    }

    console.log("Applying filters:", filters);

    const events = await Event.find(filters)
      .populate("building", "name")
      .populate("createdBy", "clubName -_id")
      .sort("startTime");

    if (events.length === 0) {
      return res
        .status(404)
        .json({ message: "No events found matching the criteria." });
    }

    console.log(`Found ${events.length} matching events`);
    res.json(events);
  } catch (error) {
    console.error("Error searching events:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

//Get today's events
router.get("/today", async (req, res) => {
  console.log("GET today's events request received");
  try {
    const now = new Date();
    console.log(now.toLocaleDateString(), now.toLocaleTimeString());
    const endOfDay = new Date();
    endOfDay.setUTCHours(23, 59, 59, 999);

    console.log("Searching for events between:", now, "and", endOfDay);

    const events = await Event.find({
      startTime: { $gte: now, $lte: endOfDay },
    })
      .populate("building", "name")
      .populate("createdBy", "clubName -_id")
      .sort("startTime");

    console.log(`Found ${events.length} events for today`);
    res.json(events);
  } catch (error) {
    console.error("Error fetching today's events:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

module.exports = router;
