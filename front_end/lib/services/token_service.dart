import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Create storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key constants
  static const String _tokenKey = 'jwt_token';

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
}
