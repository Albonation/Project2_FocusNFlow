import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/screens/add_edit_task_screen.dart';
import 'package:focus_n_flow/services/course_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/course_widgets/courses_section.dart';
import 'package:focus_n_flow/widgets/task_add_edit_widgets/tasks_section.dart';

class CoursesTasksScreen extends StatelessWidget {
  const CoursesTasksScreen({super.key});

  void _openAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _openEditTaskScreen(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
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
              'No user logged in',
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
      appBar: AppBar(title: const Text('Courses & Tasks'), centerTitle: true),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          CoursesSection(
            userId: user.uid,
            courseService: CourseService(repository: CourseRepository()),
          ),

          AppSpacing.gapXxl,

          TasksSection(
            userId: user.uid,
            onAddTask: () {
              _openAddTaskScreen(context);
            },
            onEditTask: (task) {
              _openEditTaskScreen(context, task);
            },
            onTaskCompleted: () {
              //##TODO trigger confetti here from this screen
              //or move the confetti controller into this screen.
            },
          ),
        ],
      ),
    );
  }
}