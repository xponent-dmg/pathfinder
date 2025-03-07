import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key constants
  static const String _tokenKey = 'jwt_token';
  static const String _userRoleKey = 'user_role';

  // Save JWT token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete JWT token (for logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Save user role (student or club leader)
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  // Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
