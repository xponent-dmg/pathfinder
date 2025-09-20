const axios = require("axios");
const cheerio = require("cheerio");
const crypto = require("crypto");
const mongoose = require("mongoose");
const https = require("https");
const fs = require("fs");
require("dotenv").config();

const ScrapedEvent = require("../models/ScrapedEventModel");
const Event = require("../models/EventModel");

function computeDeterministicHash(input) {
  return crypto.createHash("sha256").update(input).digest("hex");
}

function buildEventHash(e) {
  const key = [e.title || "", e.date || "", e.venue || "", e.eventId || ""].join("::");
  return computeDeterministicHash(key);
}

async function ensureDbConnection() {
  if (mongoose.connection.readyState === 1) return; // connected
  if (mongoose.connection.readyState === 2) return; // connecting
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    // Fill this: set MONGODB_URI in your .env
    // throw new Error("Missing MONGODB_URI env var");
    console.warn("[scraper] MONGODB_URI missing. Set it in .env");
    return;
  }
  await mongoose.connect(uri);
}

async function parseHtmlToEvents(html) {
  const $ = cheerio.load(html);

  const events = [];
  $(".card-body").each((i, el) => {
    const detailsContainers = $(el).find("#detailsContainer");
    const title = $(el).find(".card-title span").text().trim();

    if (!title) return; // Skip if no title

    events.push({
      title: title,
      people: $(el).find(".fa-people-carry-box").parent().find("span").text().trim(),
      category: $(el).find("div").eq(1).find("span").text().trim(),
      date: detailsContainers.first().find("span").text().trim(),
      venue: detailsContainers.first().next().find("span").text().trim(),
      price: detailsContainers.eq(1).find("span").text().trim(),
      slots: $(el).find(".fa-street-view").parent().find("span").text().trim(),
      eventId: $(el).find("button[name='eid']").attr("value"),
    });
  });

  return events;
}

async function upsertScraped(events, sourceUrl) {
  let upserted = 0;
  for (const e of events) {
    const hash = buildEventHash(e);
    await ScrapedEvent.updateOne({ hash }, { ...e, hash, source: sourceUrl }, { upsert: true });
    upserted += 1;
  }
  return upserted;
}

async function maybeProjectIntoMainEvents(events) {
  // OPTIONAL: Map scraped events into your main Event model.
  // Commented by default. Uncomment and adapt mapping once fields are known.
  // for (const s of events) {
  //   const start = /* parse s.date to Date */ null; // TODO
  //   const end = /* parse s.date to Date */ null; // TODO
  //   if (!start || !end) continue;
  //   const doc = {
  //     name: s.title,
  //     imageUrl: "", // TODO: if available
  //     price: parseFloat(s.price.replace(/[^\d.]/g, '')) || 0,
  //     startTime: start,
  //     endTime: end,
  //     information: s.category,
  //     isOnline: false, // or infer from venue
  //     isMandatory: false,
  //     roomno: s.venue,
  //     categories: [s.category],
  //     clubName: "", // TODO: map if known
  //     createdBy: /* some ClubLeader id? */ undefined,
  //   };
  //   await Event.updateOne(
  //     { name: doc.name, startTime: doc.startTime },
  //     doc,
  //     { upsert: true }
  //   );
  // }
}

async function scrapeEvents() {
  const sourceUrl = process.env.SCRAPER_SOURCE_URL || "https://eventhubcc.vit.ac.in/EventHub/";
  try {
    await ensureDbConnection();
    if (mongoose.connection.readyState !== 1) {
      console.warn("[scraper] DB not connected; skipping scrape");
      return;
    }

    // Create HTTPS agent with CA bundle if available
    let httpsAgent;
    try {
      if (fs.existsSync("./ca_bundle.pem")) {
        httpsAgent = new https.Agent({
          ca: fs.readFileSync("./ca_bundle.pem"),
        });
      }
    } catch (err) {
      console.warn("[scraper] CA bundle not found, proceeding without custom CA");
    }

    const axiosConfig = {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      },
    };

    if (httpsAgent) {
      axiosConfig.httpsAgent = httpsAgent;
    }

    const { data } = await axios.get(sourceUrl, axiosConfig);

    const events = await parseHtmlToEvents(data);
    const upsertedCount = await upsertScraped(events, sourceUrl);

    // Optional projection into main events
    // await maybeProjectIntoMainEvents(events);

    console.log(`✅ Scraped ${events.length} events; upserted ${upsertedCount}`);
    if (events.length > 0) {
      console.log("First event:", events[0]);
    }
    return { total: events.length, upserted: upsertedCount };
  } catch (err) {
    console.error("❌ Scraping failed:", err.message);
  }
}

module.exports = { scrapeEvents };
