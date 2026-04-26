import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/services/course_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _courseService = CourseService(courseRepository: _courseRepository);
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
    );

    courseCodeController.dispose();
    courseNameController.dispose();
  }

  Future<void> _deleteCourse(Course course) async {
    try {
      final result = await _courseService.deleteCourse(course);

      if (!mounted) return;

      _showMessage(result.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to delete course: $e');
    }
  }

  void _showDeleteCourseDialog(Course course) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Course?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${course.displayName}?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteCourse(course);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: context.appColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
      return Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: Text(
              'No user logged in.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Text(
            'Appearance',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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

          AppSpacing.gapXxl,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Courses',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                tooltip: 'Add course',
                color: context.appColors.brand,
                onPressed: () {
                  _showAddCourseDialog(user.uid);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          AppSpacing.gapMd,

          StreamBuilder<List<Course>>(
            stream: _courseRepository.getCoursesForUser(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Unable to load courses: ${snapshot.error}',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.error,
                  ),
                );
              }

              final courses = snapshot.data ?? [];

              if (courses.isEmpty) {
                return Card(
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Text(
                      'No courses yet. Add courses here so tasks can be assigned to them.',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: courses.map((course) {
                  return Padding(
                    padding: AppSpacing.rowPadding,
                    child: _CourseCard(
                      course: course,
                      onDelete: () {
                        _showDeleteCourseDialog(course);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: AppSpacing.listTilePadding,
        leading: Icon(
          Icons.school_outlined,
          color: context.appColors.studyRoom,
        ),
        title: Text(
          course.displayName,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Weight: ${course.courseWeight.toStringAsFixed(0)}',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Delete course',
          icon: Icon(
            Icons.delete_outline,
            color: context.appColors.danger,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}