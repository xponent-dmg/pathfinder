import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_finder/providers/user_provider.dart';
import 'package:provider/provider.dart';
import './auth_det.dart';
import 'dart:math';
import '../supabase_service.dart';

class EventsService {
  final String baseUrl = AuthDet().baseUrl;

//fetching today's events
  Future<List<Map<String, dynamic>>> todaysEvents() async {
    try {
      var url = Uri.parse("$baseUrl/api/events/today");
      print("Fetching today's events from: $url");

      var response = await http.get(
        url,
        headers: {"Content-type": "application/json"},
      );

      print("Response status: ${response.statusCode}");
      print(
          "Response body: ${response.body.substring(0, min(100, response.body.length))}...");

      if (response.statusCode != 200) {
        throw Exception("Failed to load events: ${response.statusCode}");
      }

      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> eventList = [];

      for (var elem in jsonData) {
        if (elem is Map<String, dynamic>) {
          // Create a new map for each event to avoid reference issues
          Map<String, dynamic> event = {};

          // Extract the required fields from MongoDB
          event["name"] = elem["name"] ?? "NaN";
          event["desc"] = elem["information"] ?? "No description available";
          event["clubName"] = elem["clubName"] ?? "NaN";

          // DEBUG: Image URL from Supabase
          print(
              "DEBUG: Processing image URL from Supabase: ${elem['imageUrl']}");
          // Image data comes from Supabase
          event["pic"] = elem['imageUrl']; // This URL is from Supabase
          event["profile-pic"] = "assets/profile_pics/profile-pic.jpg";

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
      // For debugging, return a more descriptive mock event
      return [
        {
          "name": "API Error Event",
          "desc": "Error: $e",
          "pic": "assets/event-pic.jpg",
          "profile-pic": "assets/profile_pics/profile-pic.jpg",
          "time": "18:30",
          "day": "Today"
        }
      ];
    }
  }

  // Creating events
  Future<Map<String, dynamic>> createEvent({
    required String name,
    required String details,
    required String location,
    required String roomNo,
    required DateTime eventDate,
    required String startTime,
    required String endTime,
    File? imageFile, // Keep this parameter but don't use it in the request
    BuildContext? context,
  }) async {
    final userProvider = context!.read<UserProvider>();
    final supaBaseServ = SupabaseService();
    String? imageUrl;
    try {
      // DEBUG: Image upload to Supabase section
      print("DEBUG: Starting image upload to Supabase");
      if (imageFile != null) {
        // SUPABASE: This is where we upload and get image from Supabase
        imageUrl = await supaBaseServ.uploadEventPicture(imageFile, name);
        print("DEBUG: Successfully uploaded image to Supabase: $imageUrl");

        if (imageUrl == null) {
          throw Exception("couldn't upload picture to supabase");
        }
      } else {
        throw Exception("No image was provided");
      }

      // MONGODB: The rest of the data is sent to MongoDB Atlas
      print("DEBUG: Preparing to send event data to MongoDB Atlas");
      var url = Uri.parse("$baseUrl/api/events/create");

      // Format date for API
      String formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);

      // Combine date and time for startTime and endTime
      String startDateTime = "$formattedDate $startTime:00";
      String endDateTime = "$formattedDate $endTime:00";

      // Create JSON payload
      Map<String, dynamic> payload = {
        'name': name,
        'information': details,
        'building': location,
        'imageUrl': imageUrl, // This is the Supabase URL being sent to MongoDB
        'roomno': roomNo,
        'startTime': startDateTime,
        'endTime': endDateTime,
      };

      print("DEBUG: Sending event data with Supabase imageUrl: $imageUrl");

      // Make POST request with JSON data
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userProvider.token}"
        },
        body: json.encode(payload),
      );

      // Check response status
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Event created successfully
        Map<String, dynamic> responseData = json.decode(response.body);
        print("Event created successfully: ${responseData['name']}");
        return {
          'success': true,
          'message': 'Event created successfully',
          'data': responseData
        };
      } else {
        // Error creating event
        print("Error creating event: ${response.statusCode}");
        print("Response body: ${response.body}");

        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Error creating event',
            'error': errorData
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error creating event',
            'error': response.body
          };
        }
      }
    } catch (e) {
      print("Exception during event creation: $e");
      return {
        'success': false,
        'message': 'Exception occurred during event creation',
        'error': e.toString()
      };
    }
  }

//fetching all events
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      var url = Uri.parse("$baseUrl/api/events/");
      print("Fetching all events from: $url");

      var response = await http.get(
        url,
        headers: {"Content-type": "application/json"},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}...");

      if (response.statusCode != 200) {
        throw Exception("Failed to load events: ${response.statusCode}");
      }

      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> eventList = [];

      for (var elem in jsonData) {
        if (elem is Map<String, dynamic>) {
          // Create a new map for each event to avoid reference issues
          Map<String, dynamic> event = {};

          // Extract the required fields from MongoDB
          event["name"] = elem["name"] ?? "NaN";
          event["desc"] = elem["information"] ?? "No description available";
          event["clubName"] = elem["clubName"] ?? "NaN";

          // DEBUG: Image URL should be from Supabase but is missing here
          print("DEBUG: Image URL from event data: ${elem['imageUrl']} and");
          // Image data should come from Supabase via MongoDB
          event["pic"] = elem['imageUrl'] ??
              "assets/event-pic.jpg"; // Should be Supabase URL
          event["profile-pic"] = "assets/profile_pics/profile-pic.jpg";
          event["location"] = elem['building']?['name'] ?? "Unknown";

          // Parse the date-time
          try {
            if (elem["startTime"] != null) {
              DateTime parsedDate = DateTime.parse(elem["startTime"]).toLocal();
              event["time"] = DateFormat("HH:mm").format(parsedDate);
              event["date"] = DateFormat("MMMM d").format(parsedDate);
              event["day"] = DateFormat("EEEE").format(parsedDate);
            } else {
              // Default values if startTime is missing
              event["time"] = "TBD";
              event["date"] = "Today";
              event["day"] = "Today";
            }
          } catch (e) {
            print("Error parsing date: $e");
            // Fallback values
            event["time"] = "TBD";
            event["date"] = "Today";

            event["day"] = "Today";
          }

          eventList.add(event);
        }
      }

      print("Processed ${eventList.length} events from API");
      return eventList;
    } catch (e) {
      print("API error: $e");
      // For debugging, return a more descriptive mock event
      return [
        {
          "name": "API Error Event",
          "desc": "Error: $e",
          "pic": "assets/event-pic.jpg",
          "profile-pic": "assets/profile_pics/profile-pic.jpg",
          "time": "18:30",
          "day": "Today"
        }
      ];
    }
  }
}
