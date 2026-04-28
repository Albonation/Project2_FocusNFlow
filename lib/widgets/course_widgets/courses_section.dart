import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/services/course_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/course_widgets/add_edit_course_dialog.dart';
import 'package:focus_n_flow/widgets/course_widgets/course_chip_card.dart';

class CoursesSection extends StatefulWidget {
  final String userId;

  const CoursesSection({
    super.key,
    required this.userId,
  });

  @override
  State<CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<CoursesSection> {
  final CourseRepository _courseRepository = CourseRepository();
  late final CourseService _courseService;

  @override
  void initState() {
    super.initState();
    _courseService = CourseService(courseRepository: _courseRepository);
  }

  Future<void> _showAddCourseDialog() async {
    await showDialog(
      context: context,
      builder: (_) {
        return AddEditCourseDialog(
          userId: widget.userId,
          onSave: _createCourse,
        );
      },
    );
  }

  Future<void> _showEditCourseDialog(Course course) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AddEditCourseDialog(
          userId: widget.userId,
          course: course,
          onSave: _saveCourseChanges,
        );
      },
    );
  }

  Future<void> _createCourse(Course course) async {
    try {
      final result = await _courseService.createCourse(course);

      if (!mounted) return;
      _showMessage(result.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to add course: $e');
    }
  }

  Future<void> _saveCourseChanges(Course course) async {
    try {
      final result = await _courseService.saveCourseChanges(course);

      if (!mounted) return;
      _showMessage(result.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to update course: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoursesHeader(
              onAddCourse: _showAddCourseDialog,
            ),

            AppSpacing.gapMd,

            StreamBuilder<List<Course>>(
              stream: _courseRepository.getCoursesForUser(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
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
                  return Text(
                    'No courses yet. Add courses here so tasks can be assigned to them.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  );
                }

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: courses.map((course) {
                    return CourseChipCard(
                      course: course,
                      onTap: () {
                        _showEditCourseDialog(course);
                      },
                      onDelete: () {
                        _showDeleteCourseDialog(course);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesHeader extends StatelessWidget {
  final VoidCallback onAddCourse;

  const _CoursesHeader({
    required this.onAddCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: onAddCourse,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}