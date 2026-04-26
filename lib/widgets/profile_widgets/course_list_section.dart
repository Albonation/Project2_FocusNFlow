import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/services/profile_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class CourseListSection extends StatefulWidget {
  final String userId;
  final CourseRepository repository;
  final ProfileService profileService;

  const CourseListSection({
    super.key,
    required this.userId,
    required this.repository,
    required this.profileService,
  });

  @override
  State<CourseListSection> createState() => _CourseListSectionState();
}

class _CourseListSectionState extends State<CourseListSection> {
  Future<void> _showAddCourseDialog() async {
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
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9]'),
                      ),
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
                    final course = widget.profileService.buildCourse(
                      userId: widget.userId,
                      courseCode: courseCodeController.text,
                      courseName: courseNameController.text,
                      courseWeight: selectedWeight,
                    );

                    try {
                      final message = await widget.profileService
                          .createCourse(course);

                      if (!mounted) return;

                      Navigator.pop(dialogContext);
                      _showMessage(message);
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
      final message = await widget.profileService.deleteCourse(course);

      if (!mounted) return;

      _showMessage(message);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              icon: Icon(
                Icons.add,
                color: context.appColors.brand,
              ),
              onPressed: _showAddCourseDialog,
            ),
          ],
        ),

        AppSpacing.gapMd,

        StreamBuilder<List<Course>>(
          stream: widget.repository.getCoursesForUser(widget.userId),
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