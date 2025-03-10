import 'package:flutter/material.dart';
import 'package:path_finder/services/api_service.dart';

class UserProvider with ChangeNotifier {
  String name = '';
  String username = '';
  String email = '';
  String createdAt = '';
  bool status = false;

  void getUserDet() async {
    Map<String, dynamic> user =
        await ApiService().authenticatedGet('/api/auth/user');
    name = user['name'];
    username = user['username'];
    email = 'sample.mail@gmail.com';
    createdAt = user['createdAt'];
    status = user['status'];
    notifyListeners();
  }
}
