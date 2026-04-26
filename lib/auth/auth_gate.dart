import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/screens/app_shell.dart';
import 'package:focus_n_flow/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';

class AuthGate extends StatefulWidget {
  final ThemeController themeController;

  const AuthGate({super.key, required this.themeController});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
   late final Stream<User?> _authStateChanges;

   @override
   void initState() {
     super.initState();
      _authStateChanges = FirebaseAuth.instance.authStateChanges();
   }


   @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChanges,
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        //Adding loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //User is logged in
        if (snapshot.hasData) {
          return AppShell(themeController: widget.themeController);
        }

        //User is not logged in
        return const SignInScreen();
      },
    );
  }
}
