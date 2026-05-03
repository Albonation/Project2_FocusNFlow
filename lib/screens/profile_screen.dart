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

<<<<<<< HEAD
    _courseService = CourseService(
      courseRepository: _courseRepository,
=======
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
              title: Text(
                'Add Course',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: courseCodeController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      final upper = value.toUpperCase();

                      courseCodeController.value = TextEditingValue(
                        text: upper,
                        selection: TextSelection.collapsed(
                          offset: upper.length,
                        ),
                      );
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Course Code',
                      hintText: 'ECON2002',
                    ),
                  ),

                  AppSpacing.gapMd,

                  TextField(
                    controller: courseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'Economics',
                    ),
                  ),

                  AppSpacing.gapMd,

                  DropdownButtonFormField<double>(
                    initialValue: selectedWeight,
                    decoration: const InputDecoration(
                      labelText: 'Course Weight',
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 - Low')),
                      DropdownMenuItem(value: 2, child: Text('2')),
                      DropdownMenuItem(value: 3, child: Text('3 - Normal')),
                      DropdownMenuItem(value: 4, child: Text('4')),
                      DropdownMenuItem(value: 5, child: Text('5 - High')),
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
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
                      final result = await _courseService.createCourse(course);

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      _showMessage(result.message);
                    } catch (e) {
                      if (!mounted) return;
                      _showMessage('Failed to add course: $e');
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: context.appColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
>>>>>>> 395a2b3895544a3c6f29a3e6fa309187f6e97e12
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
