import 'package:flutter/material.dart';
import 'package:path_finder/services/api_service.dart';
import 'package:path_finder/services/token_service.dart';

class UserProvider with ChangeNotifier {
  String name = 'new user';
  String username = 'unregistered';
  String email = 'sample@gmail.com';
  String createdAt = '';
  bool status = false;
  String _role = '';
  String _token = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  String get role => _role;
  String get token => _token;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Load token and get user details in one function
  Future<bool> setTokenAndGetUserDetails(String token) async {
    _token = token;
    notifyListeners();

    try {
      await getUserDet();
      return true;
    } catch (e) {
      print("Error getting user details after setting token: $e");
      return false;
    }
  }

  // Load token from secure storage when needed
  Future<bool> loadTokenFromStorage() async {
    try {
      final storedToken = await _tokenService.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        notifyListeners();
        // Get user details if we have a token
        await getUserDet();
        return true;
      }
      return false;
    } catch (e) {
      print("Error loading token from storage: $e");
      return false;
    }
  }

  void setRole(String t) {
    _role = t;
    notifyListeners();
  }

  void setToken(String t) {
    _token = t;
    notifyListeners();
  }

  void deleteRole() {
    _role = '';
    notifyListeners();
  }

  void deleteToken() {
    _token = '';
    notifyListeners();
  }

  Future<void> getUserDet() async {
    // Don't try to get user details if no token
    if (_token.isEmpty) return;

    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      Map<String, dynamic> user =
          await _apiService.authenticatedGet('/api/auth/user', _token);

      // Update user details
      name = user['name'] ?? '';
      username = user['username'] ?? '';
      email = user['email'] ?? '';
      createdAt = user['createdAt'] ?? '';
      status = user['status'] ?? false;
      if (user['role'] != null && user['role'].isNotEmpty) {
        _role = user['role'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
      print("Error fetching user data: $e");
    }
  }

  // Reset user data when logging out
  void clearUserData() {
    name = '';
    username = '';
    email = '';
    createdAt = '';
    status = false;
    _role = '';
    _token = '';
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
