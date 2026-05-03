import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';
import 'package:focus_n_flow/widgets/profile_widgets/appearance_section.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeController themeController;

  const ProfileScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          AppearanceSection(
            themeController: widget.themeController,
          ),

          AppSpacing.gapMd,

          AnimatedBuilder(
            animation: widget.themeController,
            builder: (context, _) {
              return DropdownButtonFormField<ThemeMode>(
                initialValue: widget.themeController.themeMode,
                decoration: const InputDecoration(
                  labelText: 'Theme Mode',
                ),
                items: ThemeMode.values.map((mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(_themeModeLabel(mode)),
                  );
                }).toList(),
                onChanged: (mode) async {
                  if (mode == null) return;
                  await widget.themeController.setTheme(mode);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}