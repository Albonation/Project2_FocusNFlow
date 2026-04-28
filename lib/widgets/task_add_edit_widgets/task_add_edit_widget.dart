import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/course_repository.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/task_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class AddEditTask extends StatefulWidget {
  final Task? task;

  const AddEditTask({super.key, this.task});

  @override
  State<AddEditTask> createState() => _AddEditTaskFormState();
}

class _AddEditTaskFormState extends State<AddEditTask> {
  final TaskService _taskService = TaskService(
    taskRepository: TaskRepository(),
  );

  final CourseRepository _courseRepository = CourseRepository();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final hoursController = TextEditingController();
  final deadlineController = TextEditingController();

  DateTime? selectedDate;
  String? selectedCourseId;

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final task = widget.task!;

      titleController.text = task.title;
      descController.text = task.description;
      hoursController.text = task.estimatedHours.toString();
      selectedDate = task.deadline;
      selectedCourseId = task.courseId;
      deadlineController.text = _formatDate(task.deadline);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    hoursController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        deadlineController.text = _formatDate(picked);
      });
    }
  }

  Future<void> saveTask() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('No user logged in.');
      return;
    }

    if (selectedCourseId == null || selectedCourseId!.trim().isEmpty) {
      _showMessage('Please select a course.');
      return;
    }

    if (selectedDate == null) {
      _showMessage('Please select a deadline.');
      return;
    }

    final task = Task(
      id: widget.task?.id,
      userId: user.uid,
      courseId: selectedCourseId!,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      deadline: selectedDate!,
      estimatedHours: double.tryParse(hoursController.text.trim()) ?? 0,
      status: widget.task?.status ?? TaskStatus.pending,
      manualImportance: widget.task?.manualImportance ?? ImportanceLevel.normal,
      completedAt: widget.task?.completedAt,
      createdAt: widget.task?.createdAt,
    );

    try {
      final result = isEditMode
          ? await _taskService.saveTaskChanges(task)
          : await _taskService.createTask(task);

      if (!mounted) return;

      _showMessage(result.message);

      if (result.success) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to save task: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
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
      );
    }

    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),

          AppSpacing.gapLg,

          StreamBuilder<List<Course>>(
            stream: _courseRepository.getCoursesForUser(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              if (snapshot.hasError) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Unable to load courses: ${snapshot.error}',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                );
              }

              final courses = snapshot.data ?? [];

              if (courses.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No courses found. Add a course from your profile before creating tasks.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: selectedCourseId,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course.id,
                      child: Text(
                        course.displayName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourseId = value;
                    });
                  },
                ),
              );
            },
          ),

          AppSpacing.gapLg,

          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Optional',
            ),
          ),

          AppSpacing.gapLg,

          TextField(
            controller: hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Estimated Hours',
              hintText: 'Enter number of hours',
            ),
          ),

          AppSpacing.gapLg,

          TextField(
            controller: deadlineController,
            readOnly: true,
            onTap: pickDate,
            decoration: const InputDecoration(
              labelText: 'Deadline',
              hintText: 'Select Deadline',
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveTask,
              child: Text(isEditMode ? 'Update Task' : 'Add Task'),
            ),
          ),
        ],
      ),
    );
  }
}
