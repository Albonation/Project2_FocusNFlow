import 'package:flutter/material.dart';

class RegistrationLoginService {

  void loginUser({
    required String email,
    required String password,
  }) {
    debugPrint("Username: $email");
    debugPrint("Password: $password");
  }

  String? validateRegistration({
    required String fullname,
    required String email,
    required String password,
    required String confirmPassword,
  }) { 
    //Check for correct field entries
    if (fullname.isEmpty){
      return "Please enter your full name";
    }

    if (email.isEmpty){
      return "Please enter your email";
    }

    if (!email.trim().toLowerCase().endsWith("@student.gsu.edu")){
      return "Please use your GSU student email";
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Please fill in both password fields";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    debugPrint("Full Name: $fullname");
    debugPrint("Username: $email");
    debugPrint("Password: $password");
    debugPrint("Confirm Password: $confirmPassword");

  return null;
  }
}