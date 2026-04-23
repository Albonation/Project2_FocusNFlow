import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/sign_up_screen.dart';

class RegistrationLoginService {

  void loginUser({
    required String username,
    required String password,
  }) {
    debugPrint("Username: $username");
    debugPrint("Password: $password");
  }

  String? validateRegistration({
    required String fullname,
    required String username,
    required String password,
    required String confirmPassword,
  }) { 
    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Please fill in both password fields";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    debugPrint("Full Name: $fullname");
    debugPrint("Username: $username");
    debugPrint("Password: $password");
    debugPrint("Confirm Password: $confirmPassword");

  return null;
  }
}