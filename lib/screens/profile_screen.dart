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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return ListView(
      padding: AppSpacing.screen,
      children: [
        AppearanceSection(
          themeController: widget.themeController,
        ),

        AppSpacing.gapLg,

        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Log Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}