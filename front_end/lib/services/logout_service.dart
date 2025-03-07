import 'package:path_finder/services/token_service.dart';
import 'package:flutter/material.dart';

class LogoutService {
  final TokenService _tokenService = TokenService();

  Future<void> logout(BuildContext context) async {
    await _tokenService.deleteToken();
    await _tokenService.saveUserRole('');

    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/signin',
      (route) => false,
    );
  }
}
