import 'package:flutter/material.dart';
import 'package:path_finder/services/api_service.dart';
import 'package:path_finder/services/token_service.dart';

class UserProvider with ChangeNotifier {
  String name = '';
  String username = '';
  String email = '';
  String createdAt = '';
  bool status = false;
  String _role = '';
  String _token = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  ApiService _apiService = ApiService();
  TokenService _tokenService = TokenService();

  String get role => _role;
  String get token => _token;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  UserProvider() {
    // Try to load token when provider is created
    _loadTokenFromStorage();
  }

  // Load token from secure storage when app starts
  Future<void> _loadTokenFromStorage() async {
    final storedToken = await _tokenService.getToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      // Get user details if we have a token
      await getUserDet();
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
      _hasError = false;
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
