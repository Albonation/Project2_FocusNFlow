import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/app_theme.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';
import 'auth/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeController = ThemeController();
  await themeController.loadTheme();

  runApp(
    MyApp(themeController: themeController),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Focus N Flow',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          home: AuthGate(themeController: themeController),
        );
      },
    );
  }
}