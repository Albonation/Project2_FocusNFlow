import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/screens/app_shell.dart';
import 'package:focus_n_flow/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //Adding loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //User is logged in
        if (snapshot.hasData) {
          return const AppShell();
        }

        //User is not logged in
        return const SignInScreen();
      },
    );
  }
}
