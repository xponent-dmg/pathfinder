import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final String _roleKey = 'user_role';

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Save role to secure storage
  Future<void> saveRole(String role) async {
    await _secureStorage.write(key: _roleKey, value: role);
  }

  // Get token from secure storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Get role from secure storage
  Future<String?> getRole() async {
    return await _secureStorage.read(key: _roleKey);
  }

  // Delete token and role
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _roleKey);
  }

  // Delete token only
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Delete role only
  Future<void> deleteRole() async {
    await _secureStorage.delete(key: _roleKey);
  }

  // Check if token exists
  Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
