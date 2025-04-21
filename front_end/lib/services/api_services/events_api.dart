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
          event["roomno"] = elem["roomno"] ?? "000";

          // DEBUG: Image URL from Supabase
          print(
              "DEBUG: Processing image URL from Supabase: ${elem['imageUrl']}");
          // Image data comes from Supabase
          event["pic"] = elem['imageUrl']; // This URL is from Supabase
          event["profile-pic"] = "assets/profile_pics/profile-pic.jpg";
          event['isMandatory'] = elem['isMandatory'] ?? false;
          event['isOnline'] = elem['isOnline'] ?? false;
          event['price'] = elem['price'] ?? 0;
          event['category'] = elem['category'];

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
    File? imageFile,
    BuildContext? context,
    bool isFree = true,
    bool isMandatory = false,
    bool isOnline = false,
    double price = 0,
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

      // Create JSON payload with new fields
      Map<String, dynamic> payload = {
        'name': name,
        'information': details,
        'building': location,
        'imageUrl': imageUrl, // This is the Supabase URL being sent to MongoDB
        'roomno': roomNo,
        'startTime': startDateTime,
        'endTime': endDateTime,
        'isMandatory': isMandatory,
        'isOnline': isOnline,
        'price': price,
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

//fetching all events with filtering capabilities
  Future<List<Map<String, dynamic>>> getAllEvents({
    String? query,
    String? category,
    String? clubName,
    String? location,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMandatory,
    bool? isOnline,
  }) async {
    try {
      // Create query parameters map
      Map<String, String> queryParams = {};

      print('DEBUG: API: Building query parameters for getAllEvents');

      // Add filter parameters if they exist
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
        print('DEBUG: API: Adding query param: q=$query');
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
        print('DEBUG: API: Adding query param: category=$category');
      }

      if (clubName != null && clubName.isNotEmpty) {
        queryParams['clubName'] = clubName;
        print('DEBUG: API: Adding query param: clubName=$clubName');
      }

      if (location != null && location.isNotEmpty) {
        queryParams['building'] = location;
        print('DEBUG: API: Adding query param: location=$location');
      }

      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
        print('DEBUG: API: Adding query param: minPrice=$minPrice');
      }

      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
        print('DEBUG: API: Adding query param: maxPrice=$maxPrice');
      }

      if (isMandatory != null) {
        queryParams['isMandatory'] = isMandatory.toString();
        print('DEBUG: API: Adding query param: isMandatory=$isMandatory');
      }

      if (isOnline != null) {
        queryParams['isOnline'] = isOnline.toString();
        print('DEBUG: API: Adding query param: isOnline=$isOnline');
      }

      // Format dates for API if present
      if (startDate != null) {
        final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
        queryParams['startDate'] = formattedStartDate;
        print('DEBUG: API: Adding query param: startDate=$formattedStartDate');
      }

      if (endDate != null) {
        final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
        queryParams['endDate'] = formattedEndDate;
        print('DEBUG: API: Adding query param: endDate=$formattedEndDate');
      }

      // Build URL with query parameters
      var uri = Uri.parse("$baseUrl/api/events/search").replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      print("DEBUG: API: Fetching events with filters from: $uri");

      var response = await http.get(
        uri,
        headers: {"Content-type": "application/json"},
      );

      print("DEBUG: API: Response status: ${response.statusCode}");

      // Print truncated response body for debugging
      if (response.body.length > 200) {
        print(
            "DEBUG: API: Response body preview: ${response.body.substring(0, 200)}...");
      } else {
        print("DEBUG: API: Response body: ${response.body}");
      }

      if (response.statusCode != 200) {
        print(
            "DEBUG: API: Error response: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load events: ${response.statusCode}");
      }

      List<dynamic> jsonData = jsonDecode(response.body);
      print("DEBUG: API: Parsed ${jsonData.length} events from JSON response");

      List<Map<String, dynamic>> eventList = [];

      for (var elem in jsonData) {
        if (elem is Map<String, dynamic>) {
          try {
            print("DEBUG: API: Processing event: ${elem['name']}");

            // Create a new map for each event to avoid reference issues
            Map<String, dynamic> event = {};

            // Extract the required fields from MongoDB
            event["name"] = elem["name"] ?? "NaN";
            event["desc"] = elem["information"] ?? "No description available";
            event["clubName"] = elem["clubName"] ?? "NaN";

            // Image data should come from Supabase via MongoDB
            event["pic"] = elem['imageUrl'];
            event["profile-pic"] = "assets/profile_pics/profile-pic.jpg";

            // Location info
            if (elem['building'] is Map) {
              event["location"] = elem['building']['name'];
              print("DEBUG: API: Event location: ${event['location']}");
            } else {
              event["location"] = "Online";
              print("DEBUG: API: Event has no building information");
            }

            event['roomno'] = elem['roomno'] ?? "";
            print("DEBUG: API: Event roomno: ${event['roomno']}");

            // Add additional filter-related fields
            event['isMandatory'] = elem['isMandatory'] ?? false;
            event['isOnline'] = elem['isOnline'] ?? false;
            event['price'] = elem['price'] ?? 0;
            event['category'] = elem['category'];

            print(
                "DEBUG: API: Event attributes - mandatory: ${event['isMandatory']}, online: ${event['isOnline']}, price: ${event['price']}, category: ${event['category']}");

            // Parse the date-time
            try {
              if (elem["startTime"] != null) {
                DateTime parsedDate =
                    DateTime.parse(elem["startTime"]).toLocal();
                event["time"] = DateFormat("HH:mm").format(parsedDate);
                event["date"] = DateFormat("MMMM d").format(parsedDate);
                event["day"] = DateFormat("EEEE").format(parsedDate);
                // Store original date for filtering
                event["event_date"] = elem["startTime"];

                print(
                    "DEBUG: API: Event date parsed - date: ${event['date']}, time: ${event['time']}, day: ${event['day']}");
              } else {
                // Default values if startTime is missing
                event["time"] = "TBD";
                event["date"] = "Today";
                event["day"] = "Today";
                print("DEBUG: API: Event has no start time, using defaults");
              }
            } catch (e) {
              print("DEBUG: API: Error parsing date: $e");
              // Fallback values
              event["time"] = "TBD";
              event["date"] = "Today";
              event["day"] = "Today";
            }

            eventList.add(event);
          } catch (e) {
            print("DEBUG: API: Error processing event: $e");
          }
        }
      }

      print("DEBUG: API: Processed ${eventList.length} events from API");
      return eventList;
    } catch (e) {
      print("DEBUG: API: Error in getAllEvents: $e");
      // For debugging, return a more descriptive mock event
      return [
        {
          "name": "API Error Event",
          "desc": "Error: $e",
          "pic": null,
          "profile-pic": "assets/profile_pics/profile-pic.jpg",
          "time": "18:30",
          "day": "Today"
        }
      ];
    }
  }
}
