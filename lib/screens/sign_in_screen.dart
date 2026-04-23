import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    debugPrint("Username: $username");
    debugPrint("Password: $password");

    // Add Firebase login here later
  }

}