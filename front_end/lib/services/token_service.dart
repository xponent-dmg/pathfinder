import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key constants
  static const String _username = 'username';
  static const String _name = 'name';
  static const String _email = 'email';
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

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Simple logout (just delete token)
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Save all user details at once
  Future<void> saveAllDetails({
    required String username,
    required String name,
    required String email,
    required String token,
    required String userRole,
  }) async {
    await _storage.write(key: _username, value: username);
    await _storage.write(key: _name, value: name);
    await _storage.write(key: _email, value: email);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userRoleKey, value: userRole);
  }

  // Get all user details at once
  Future<Map<String, dynamic>> getAllDetails() async {
    final username = await _storage.read(key: _username);
    final name = await _storage.read(key: _name);
    final email = await _storage.read(key: _email);
    final token = await _storage.read(key: _tokenKey);
    final userRole = await _storage.read(key: _userRoleKey);

    return {
      'username': username,
      'name': name,
      'email': email,
      'token': token,
      'userRole': userRole,
    };
  }
}
