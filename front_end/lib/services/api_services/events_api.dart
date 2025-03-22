import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventsAPI {
  final String baseUrl = "http://192.168.90.53:3000";

  Future<List<Map<String, dynamic>>> todaysEvents() async {
    try {
      var url = Uri.parse("$baseUrl/api/events/today");
      var response = await http.get(
        url,
        headers: {"Content-type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to load events: ${response.statusCode}");
      }

      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> eventList = [];

      for (var elem in jsonData) {
        if (elem is Map<String, dynamic>) {
          // Create a new map for each event to avoid reference issues
          Map<String, dynamic> event = {};

          // Extract the required fields
          event["name"] = elem["name"] ?? "NaN";
          event["desc"] = elem["information"] ?? "No description available";
          event["clubName"] = elem["clubName"] ?? "NaN";

          // Use placeholder images if not available from API
          event["pic"] = "assets/event-pic.jpg";
          event["profile-pic"] = "assets/profile-pic.jpg";

          // Parse the date-time
          try {
            if (elem["startTime"] != null) {
              DateTime parsedDate = DateTime.parse(elem["startTime"]).toLocal();
              event["time"] = DateFormat("HH:mm").format(parsedDate);
              event["day"] = DateFormat("EEEE").format(parsedDate);
            } else {
              // Default values if startTime is missing
              event["time"] = "TBD";
              event["day"] = "Today";
            }
          } catch (e) {
            print("Error parsing date: $e");
            // Fallback values
            event["time"] = "TBD";
            event["day"] = "Today";
          }

          eventList.add(event);
        }
      }

      print("Processed ${eventList.length} events from API");
      return eventList;
    } catch (e) {
      print("API error: $e");
      // Return an empty list or some mock data as fallback
      return [
        {
          "name": "Mock Event (API Error)",
          "desc": "This is a mock event shown because there was an API error",
          "pic": "assets/event-pic.jpg",
          "profile-pic": "assets/profile-pic.jpg",
          "time": "18:30",
          "day": "Today"
        }
      ];
    }
  }
}
