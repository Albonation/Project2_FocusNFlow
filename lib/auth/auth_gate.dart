import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';


class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return ; //logged in
    } else {
      return const SignInScreen(); //not logged in
    }
  }
}