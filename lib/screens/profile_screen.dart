import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/services/course_service.dart';
import 'package:focus_n_flow/services/profile_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';
import 'package:focus_n_flow/widgets/profile_widgets/appearance_section.dart';
import 'package:focus_n_flow/widgets/profile_widgets/course_list_section.dart';
import 'package:focus_n_flow/widgets/profile_widgets/logout_widget.dart';

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
  final CourseRepository _courseRepository = CourseRepository();
  late final CourseService _courseService;
  late final ProfileService _profileService;

  @override
  void initState() {
    super.initState();

    _courseService = CourseService(
      courseRepository: _courseRepository,
    );

    _profileService = ProfileService(
      courseService: _courseService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: Text(
              'No user logged in.',
              style: context.text.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          AppearanceSection(
            themeController: widget.themeController,
          ),

          AppSpacing.gapXxl,

          CourseListSection(
            userId: user.uid,
            repository: _courseRepository,
            profileService: _profileService,
          ),

          AppSpacing.gapXxl,

          const LogoutButton(),
        ],
      ),
    );
  }
}
