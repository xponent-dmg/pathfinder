import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/user_provider.dart';
import 'package:path_finder/services/token_service.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;
  final TokenService _tokenService = TokenService();

  Future<String?> uploadEventPicture(File imageFile, String eventName) async {
    final String fileName = '$eventName-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = 'event-pics/$fileName';

    try {
      print('Uploading file to Supabase storage: $filePath');
      await _supabase.storage.from('pathfinder').upload(filePath, imageFile);
      final String publicUrl = _supabase.storage.from('pathfinder').getPublicUrl(filePath);
      print('File uploaded successfully. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  // --- Auth Methods ---

  Future<Map<String, dynamic>> registerUser(String name, String username, String email, String password) async {
    try {
      final response = await _supabase.rpc('register_user', params: {
        'p_name': name,
        'p_username': username,
        'p_email': email,
        'p_password': password,
      });
      return {
        'success': response['success'],
        'message': response['message'] ?? 'Successfully registered',
        'statusCode': response['success'] ? 200 : 400
      };
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>> userLogin(String username, String password, bool rememberMe, [BuildContext? context]) async {
    Map<String, dynamic> result = {'success': false, 'message': 'An error occurred', 'statusCode': 500};
    try {
      final response = await _supabase.rpc('login_user', params: {
        'p_username': username,
        'p_password': password,
      });
      if (response['success'] == true) {
        final token = response['token'];
        
        if (context != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setToken(token);
          userProvider.setRole('student');
          await userProvider.getUserDet();
        }

        if (rememberMe) {
          await _tokenService.saveToken(token);
          await _tokenService.saveRole('student');
        }
        
        result = {'success': true, 'message': 'Login successful', 'statusCode': 200, 'token': token};
      } else {
        result['message'] = response['message'] ?? 'Invalid username or password';
        result['statusCode'] = 401;
      }
    } catch (e) {
      result['message'] = 'Network error: $e';
    }
    return result;
  }

  Future<Map<String, dynamic>> clubLeaderLogin(String username, String password, bool rememberMe, [BuildContext? context]) async {
    Map<String, dynamic> result = {'success': false, 'message': 'An error occurred', 'statusCode': 500};
    try {
      final response = await _supabase.rpc('login_clubleader', params: {
        'p_username': username,
        'p_password': password,
      });
      if (response['success'] == true) {
        final token = response['token'];
        
        if (context != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setToken(token);
          userProvider.setRole('clubleader');
          await userProvider.getUserDet();
        }

        if (rememberMe) {
          await _tokenService.saveToken(token);
          await _tokenService.saveRole('clubleader');
        }
        
        result = {'success': true, 'message': 'Login successful', 'statusCode': 200, 'token': token};
      } else {
        result['message'] = response['message'] ?? 'Invalid username or password';
        result['statusCode'] = 401;
      }
    } catch (e) {
      result['message'] = 'Network error: $e';
    }
    return result;
  }

  Future<Map<String, dynamic>> getUserDetails(String token, String role) async {
    Map<String, dynamic> user = {
      "status": false,
      "name": "",
      "username": "",
      "email": "",
      "message": "Error",
      "createdAt": "",
      "role": role,
    };
    try {
      if (role == 'clubleader') {
        final data = await _supabase.from('club_leaders').select().eq('id', token).single();
        user['status'] = true;
        user['name'] = data['name'];
        user['username'] = data['username'];
        if (data['created_at'] != null) {
          user['createdAt'] = DateFormat("MMMM yyyy").format(DateTime.parse(data['created_at']));
        }
      } else {
        final data = await _supabase.from('users').select().eq('id', token).single();
        user['status'] = true;
        user['name'] = data['name'];
        user['username'] = data['username'];
        user['email'] = data['email'];
        if (data['created_at'] != null) {
          user['createdAt'] = DateFormat("MMMM yyyy").format(DateTime.parse(data['created_at']));
        }
      }
    } catch (e) {
      print('Error getting user detail: $e');
    }
    return user;
  }

  // --- Events Methods ---

  Future<List<Map<String, dynamic>>> todaysEvents() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc().toIso8601String();

      final data = await _supabase
          .from('events')
          .select('*, buildings(name)')
          .gte('start_time', startOfDay)
          .lte('start_time', endOfDay);

      return _mapEventsList(data);
    } catch (e) {
      print("API error: $e");
      return [];
    }
  }

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
      var queryBuilder = _supabase.from('events').select('*, buildings!inner(name)');

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('name', '%$query%');
      }
      if (category != null && category.isNotEmpty) {
        queryBuilder = queryBuilder.contains('categories', [category]);
      }
      if (clubName != null && clubName.isNotEmpty) {
        queryBuilder = queryBuilder.eq('club_name', clubName);
      }
      if (location != null && location.isNotEmpty) {
        queryBuilder = queryBuilder.eq('buildings.name', location);
      }
      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }
      if (isMandatory != null) {
        queryBuilder = queryBuilder.eq('is_mandatory', isMandatory);
      }
      if (isOnline != null) {
        queryBuilder = queryBuilder.eq('is_online', isOnline);
      }
      if (startDate != null) {
        queryBuilder = queryBuilder.gte('start_time', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        queryBuilder = queryBuilder.lte('start_time', endDate.toUtc().toIso8601String());
      }

      final data = await queryBuilder;
      return _mapEventsList(data);
    } catch (e) {
      print("Error in getAllEvents: $e");
      return [];
    }
  }

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
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadEventPicture(imageFile, name);
      } else {
        imageUrl = 'https://via.placeholder.com/150'; // standard fallback
      }

      final userProvider = context!.read<UserProvider>();
      
      // We need building ID for the location
      final buildingData = await _supabase.from('buildings').select('id').eq('name', location).maybeSingle();
      String? buildingId;
      if (buildingData != null) {
        buildingId = buildingData['id'];
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);
      DateTime parsedStart = DateTime.parse("$formattedDate $startTime:00");
      DateTime parsedEnd = DateTime.parse("$formattedDate $endTime:00");

      final insertData = {
        'name': name,
        'information': details,
        'building_id': buildingId,
        'image_url': imageUrl,
        'roomno': roomNo,
        'start_time': parsedStart.toUtc().toIso8601String(),
        'end_time': parsedEnd.toUtc().toIso8601String(),
        'is_mandatory': isMandatory,
        'is_online': isOnline,
        'price': price,
        'club_name': 'Unknown Club', // In a real app we'd get this from user profile if they are a club leader
        'created_by': userProvider.role == 'clubleader' ? userProvider.token : null,
      };

      await _supabase.from('events').insert(insertData);

      return {'success': true, 'message': 'Event created successfully'};
    } catch (e) {
      print("Exception during event creation: $e");
      return {'success': false, 'message': 'Exception occurred', 'error': e.toString()};
    }
  }

  List<Map<String, dynamic>> _mapEventsList(List<dynamic> data) {
    List<Map<String, dynamic>> eventList = [];
    for (var elem in data) {
      try {
        Map<String, dynamic> event = {};
        event["name"] = elem["name"] ?? "NaN";
        event["desc"] = elem["information"] ?? "No description available";
        event["clubName"] = elem["club_name"] ?? "NaN";
        event["pic"] = elem['image_url'];
        event["profile-pic"] = "assets/profile_pics/profile-pic.jpg";

        if (elem['buildings'] != null && elem['buildings']['name'] != null) {
          event["location"] = elem['buildings']['name'];
        } else {
          event["location"] = "Online";
        }

        event['roomno'] = elem['roomno'] ?? "";
        event['isMandatory'] = elem['is_mandatory'] ?? false;
        event['isOnline'] = elem['is_online'] ?? false;
        event['price'] = elem['price'] ?? 0;
        event['category'] = (elem['categories'] != null && elem['categories'].isNotEmpty) ? elem['categories'][0] : null;

        if (elem["start_time"] != null) {
          DateTime parsedDate = DateTime.parse(elem["start_time"]).toLocal();
          event["time"] = DateFormat("HH:mm").format(parsedDate);
          event["date"] = DateFormat("MMMM d").format(parsedDate);
          event["day"] = DateFormat("EEEE").format(parsedDate);
          event["event_date"] = elem["start_time"];
        } else {
          event["time"] = "TBD";
          event["date"] = "Today";
          event["day"] = "Today";
        }
        eventList.add(event);
      } catch (e) {
        print("Error processing event: $e");
      }
    }
    return eventList;
  }
}
