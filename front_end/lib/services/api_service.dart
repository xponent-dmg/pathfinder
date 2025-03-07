import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:path_finder/services/token_service.dart';

class ApiService {
  final String baseUrl = "http://192.168.90.53:3000";
  final TokenService _tokenService = TokenService();

  Future<http.Response> registerUser(
      String name, String username, String password) async {
    var url = Uri.parse("$baseUrl/api/auth/register-user");
    var response = await http.post(
      url,
      headers: {
        "Content-type": "application/json",
      },
      body: json.encode({
        "name": name,
        "username": username,
        "password": password,
      }),
    );
    return response;
  }

  Future<Map<String, dynamic>> userLogin(
      String username, String password) async {
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
        await _tokenService.saveToken(responseData['token']);
        await _tokenService.saveUserRole('student');

        result = {
          'success': true,
          'message': 'Login successful',
          'statusCode': response.statusCode
        };
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        result['message'] = errorData['error'] ?? 'Network error';
      } catch (e) {
        // If response body isn't valid JSON
        result['message'] = 'Body isnt JSON';
      }
    }

    return result;
  }

  Future<Map<String, dynamic>> clubLeaderLogin(
      String username, String password) async {
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
        await _tokenService.saveToken(responseData['token']);
        await _tokenService.saveUserRole('clubLeader');

        result = {
          'success': true,
          'message': 'Login successful',
          'statusCode': response.statusCode
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
  Future<http.Response> authenticatedGet(String endpoint) async {
    final token = await _tokenService.getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
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
