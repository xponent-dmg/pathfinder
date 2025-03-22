const express = require("express");
const router = express.Router();
const Event = require("../models/EventModel");
const Building = require("../models/BuildingModel");
const ClubLeader = require("../models/ClubLeaderModel");
const { auth } = require("../middleware/auth"); // Update to use the auth object

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
    console.log("Looking for building:", req.body.building);
    const building = await Building.findOne({ name: req.body.building });
    if (!building) {
      console.log("Building not found:", req.body.building);
      return res.status(400).send({
        error:
          "Invalid building name. Must be one of: AB1, AB2, AB3, Clock_Tower, MG",
      });
    }
    console.log("Building found:", building.name, building._id);

    const event = new Event({
      name: req.body.name,
      building: building._id,
      startTime: req.body.startTime,
      endTime: req.body.endTime,
      information: req.body.information,
      roomno: req.body.roomno,
      categories: req.body.categories,
      clubName: req.user.clubName,
      createdBy: req.user.id,
    });
    console.log("Event object created:", event);

    // Save the event
    await event.save();
    console.log("Event saved successfully with ID:", event._id);

    // Update the building document to include this event
    building.events.push(event._id);
    await building.save();
    console.log("Event added to building events array");

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

    // Populate building name for response
    await event.populate("building", "name");
    console.log("Sending response with populated event:", event);
    res.status(201).send(event);
  } catch (error) {
    console.error("Error creating event:", error);
    res.status(400).send(error);
  }
});

//Getting the event
router.get("/", async (req, res) => {
  console.log("GET all events request received");
  try {
    const now = new Date();
    console.log("Current time:", now);
    const events = await Event.find({ endTime: { $gt: now } })
      .populate("building", "name") // Fetch building name
      .populate("createdBy", "clubName -_id") // Fetch clubName, hide _id
      .sort("startTime");
    console.log(`Found ${events.length} future events`);
    res.json(events);
  } catch (error) {
    console.error("Error fetching events:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

//Get details wrt building name
router.get("/building/:buildingName", async (req, res) => {
  console.log("GET events by building:", req.params.buildingName);
  try {
    const now = new Date();
    const building = await Building.findOne({ name: req.params.buildingName });
    if (!building) {
      console.log("Building not found:", req.params.buildingName);
      return res.status(404).json({ error: "Building not found" });
    }
    console.log("Building found with ID:", building._id);
    const events = await Event.find({
      building: building._id,
      endTime: { $gt: now },
    })
      .populate("building", "name")
      .sort("startTime");
    console.log(
      `Found ${events.length} future events for building ${req.params.buildingName}`
    );
    res.json(events);
  } catch (error) {
    console.error("Error fetching events by building:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

//Get details wrt category
router.get("/category/:category", async (req, res) => {
  console.log("GET events by category:", req.params.category);
  try {
    const now = new Date();
    const events = await Event.find({
      categories: req.params.category,
      endTime: { $gt: now },
    })
      .populate("building", "name")
      .sort("startTime");
    console.log(
      `Found ${events.length} future events for category ${req.params.category}`
    );
    res.json(events);
  } catch (error) {
    console.error("Error fetching events by category:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

//To search for elements
router.get("/search", async (req, res) => {
  console.log("Search request received with query:", req.query.q);
  try {
    const now = new Date();
    const searchTerm = req.query.q || "";
    console.log("Searching for term:", searchTerm);
    const events = await Event.find({
      //Any and all of the following
      $or: [
        { name: { $regex: searchTerm, $options: "i" } }, //search wrt building name
        { categories: { $regex: searchTerm, $options: "i" } }, //search wrt categories
        { clubName: { $regex: searchTerm, $options: "i" } }, //search wrt clubName
      ],
      endTime: { $gt: now },
    })
      .populate("building", "name")
      .sort("startTime");
    console.log(
      `Found ${events.length} matching events for search term "${searchTerm}"`
    );
    res.send(events);
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
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(today);
    endOfDay.setHours(23, 59, 59, 999);

    console.log("Searching for events between:", today, "and", endOfDay);

    const events = await Event.find({
      startTime: { $gte: today, $lte: endOfDay },
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
