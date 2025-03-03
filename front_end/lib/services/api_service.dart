import "package:http/http.dart" as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000";

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

  Future<http.Response> userLogin(String username, String password) async {
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
    return response;
  }

  Future<http.Response> clubLeaderLogin(
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
    return response;
  }
}
