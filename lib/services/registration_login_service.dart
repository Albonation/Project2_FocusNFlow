import 'package:flutter/material.dart';

class RegistrationLoginService {

  void loginUser({
    required String username,
    required String password,
  }) {
    debugPrint("Username: $username");
    debugPrint("Password: $password");
  }
}