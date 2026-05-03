import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/services/course_service.dart';
import 'package:focus_n_flow/services/profile_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
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
      repository: _courseRepository,
    );

    _profileService = ProfileService(
      courseService: _courseService);
  }

  Future<void> _showAddCourseDialog(String userId) async {
    final courseCodeController = TextEditingController();
    final courseNameController = TextEditingController();
    double selectedWeight = 3;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Course'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: courseCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Course Code',
                    ),
                  ),
                  AppSpacing.gapMd,
                  TextField(
                    controller: courseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                    ),
                  ),
                  AppSpacing.gapMd,
                  DropdownButtonFormField<double>(
                    initialValue: selectedWeight,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1')),
                      DropdownMenuItem(value: 2, child: Text('2')),
                      DropdownMenuItem(value: 3, child: Text('3')),
                      DropdownMenuItem(value: 4, child: Text('4')),
                      DropdownMenuItem(value: 5, child: Text('5')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedWeight = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final course = Course(
                      userId: userId,
                      courseCode: courseCodeController.text,
                      courseName: courseNameController.text,
                      courseWeight: selectedWeight,
                    );

                    try {
                      final result =
                          await _courseService.createCourse(course);

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);
                      _showMessage(result.message);
                    } catch (e) {
                      _showMessage('Failed: $e');
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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