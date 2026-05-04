import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class CoursePickerScreen extends StatefulWidget {
  final String? selectedCourseId;

  const CoursePickerScreen({super.key, this.selectedCourseId});

  @override
  State<CoursePickerScreen> createState() => _CoursePickerScreenState();
}

class _CoursePickerScreenState extends State<CoursePickerScreen> {
  final CourseRepository _courseRepository = CourseRepository();

  late final Stream<List<Course>> _coursesStream;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    _coursesStream = user == null
        ? Stream.value([])
        : _courseRepository.getCoursesForUser(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Choose Course')),
        body: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: Text(
              'You must be signed in to choose a course.',
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
      appBar: AppBar(title: const Text('Choose Course')),
      body: StreamBuilder<List<Course>>(
        stream: _coursesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  'Unable to load courses: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            );
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  'No courses found. Add a course before assigning one to a study session.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screen,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final isSelected = course.id == widget.selectedCourseId;

              return Padding(
                padding: AppSpacing.rowPadding,
                child: _CoursePickerCard(
                  course: course,
                  isSelected: isSelected,
                  onTap: () {
                    Navigator.pop(context, course);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CoursePickerCard extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoursePickerCard({
    required this.course,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? context.appColors.brand
        : context.appColors.cardBorder;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(AppCorners.lg),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.appColors.task.withValues(alpha: 0.12),
                foregroundColor: context.appColors.task,
                child: const Icon(Icons.school_outlined),
              ),

              AppSpacing.horizontalGapMd,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.gapXs,

                    Text(
                      course.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),

                    AppSpacing.gapXs,

                    Row(
                      children: [
                        Icon(
                          Icons.balance,
                          size: 14,
                          color: context.appColors.planner,
                        ),
                        AppSpacing.horizontalGapXs,
                        Text(
                          'Weight ${course.courseWeight.toStringAsFixed(0)}',
                          style: context.text.labelSmall?.copyWith(
                            color: context.appColors.planner,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isSelected) ...[
                AppSpacing.horizontalGapSm,
                Icon(Icons.check_circle, color: context.appColors.brand),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
