import "package:http/http.dart" as http;
import 'package:path_finder/providers/user_provider.dart';
import 'dart:convert';
import 'package:path_finder/services/token_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ApiService {
  final String baseUrl =
      "https://pathfinder-production-aa04.up.railway.app"; //server on railway
  final TokenService _tokenService = TokenService();

//register user
  Future<http.Response> registerUser(
      String name, String username, String email, String password) async {
    var url = Uri.parse("$baseUrl/api/auth/register-user");
    var response = await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: json.encode({
        "name": name,
        "username": username,
        "email": email,
        "password": password,
      }),
    );
    return response;
  }

//user login
  Future<Map<String, dynamic>> userLogin(
      String username, String password, bool rememberMe,
      [BuildContext? context]) async {
    var url = Uri.parse("$baseUrl/api/auth/login-user");
    var response = await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: json.encode({
        "username": username,
        "password": password,
      }),
    );

    // Parse the response
    Map<String, dynamic> result = {
      'success': false,
      'message': 'An error occurred',
      'statusCode': response.statusCode
    };

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        // Save token to secure storage if remember me is checked
        if (rememberMe) {
          await TokenService().saveToken(responseData['token']);
        }

        // Store token in provider if context is available
        if (context != null) {
          // Use the provider through the context
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.setToken(responseData['token']);
          userProvider.setRole("student");

          // Fetch user details right away
          await userProvider.getUserDet();
        }

        result = {
          'success': true,
          'message': 'Login successful',
          'statusCode': response.statusCode,
          'token': responseData['token']
        };
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        result['message'] = errorData['error'] ?? 'Network error';
      } catch (e) {
        // If response body isn't valid JSON
        result['message'] = 'Network error';
      }
    }

    return result;
  }

//clubLeader login
  Future<Map<String, dynamic>> clubLeaderLogin(
      String username, String password, bool rememberMe,
      [BuildContext? context]) async {
    var url = Uri.parse("$baseUrl/api/auth/login-clubleader");
    var response = await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: json.encode({
        "username": username,
        "password": password,
      }),
    );

    // Parse the response
    Map<String, dynamic> result = {
      'success': false,
      'message': 'An error occurred',
      'statusCode': response.statusCode
    };

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        // Store token and role
        if (rememberMe) {
          await _tokenService.saveToken(responseData['token']);
        }

        // Store in provider if context is available
        if (context != null) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.setToken(responseData['token']);
          userProvider.setRole("clubleader");

          // Fetch user details right away
          await userProvider.getUserDet();
        }

        result = {
          'success': true,
          'message': 'Login successful',
          'statusCode': response.statusCode,
          'token': responseData['token']
        };
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        result['message'] = errorData['error'] ?? 'Network error';
      } catch (e) {
        // If response body isn't valid JSON
        result['message'] = 'Network error';
      }
    }

    return result;
  }

  // Method to make authenticated requests
  Future<Map<String, dynamic>> authenticatedGet(String endpoint,
      [String? token]) async {
    final url = Uri.parse('$baseUrl$endpoint');

    // If no token provided, try to get from secure storage
    if (token == null || token.isEmpty) {
      token = await _tokenService.getToken();
    }

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> user = {
      "status": false,
      "name": "",
      "username": "",
      "email": "",
      "message": "Error",
      "createdAt": "",
      "role": "",
    };

    if (res.statusCode == 200) {
      final responseData = json.decode(res.body);
      user['status'] = true;
      user["name"] = responseData["name"] ?? "";
      user["username"] = responseData["username"] ?? "";
      user["email"] = responseData["email"] ?? "";
      user["role"] = responseData["role"] ?? "";

      if (responseData["createdAt"] != null) {
        DateTime parsedDate = DateTime.parse(responseData["createdAt"]);
        user["createdAt"] = DateFormat("MMMM yyyy").format(parsedDate);
      }
    }

    return user;
  }

  // Method to make authenticated POST requests
  Future<http.Response> authenticatedPost(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _tokenService.getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
  }
}
