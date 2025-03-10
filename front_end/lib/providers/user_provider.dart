import 'package:flutter/material.dart';
import 'package:path_finder/services/api_service.dart';

class UserProvider with ChangeNotifier {
  String name = '';
  String username = '';
  String email = '';
  String createdAt = '';
  bool status = false;
  String _role = '';
  String _token = '';
  String get role => _role;
  String get token => _token;

  void setRole(String t) {
    _role = t;
  }

  void setToken(String t) {
    _token = t;
  }

  void deleteRole() {
    _role = '';
  }

  void deleteToken() {
    _token = '';
  }

  void getUserDet() async {
    Map<String, dynamic> user =
        await ApiService().authenticatedGet('/api/auth/user');
    name = user['name'];
    username = user['username'];
    email = user['email'];
    createdAt = user['createdAt'];
    status = user['status'];
    notifyListeners();
  }
}
