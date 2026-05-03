import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/screens/add_edit_task_screen.dart';
import 'package:focus_n_flow/services/task_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class CoursesTasksScreen extends StatefulWidget {
  const CoursesTasksScreen({super.key});

  @override
  State<CoursesTasksScreen> createState() => _CoursesTasksScreenState();
}

class _CoursesTasksScreenState extends State<CoursesTasksScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  late final TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(
      taskRepository: _taskRepository,
      plannerRepository: PlannerFirestoreRepository(),
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final result = await _taskService.deleteTask(task);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    }
  }

  Future<void> _toggleTask(Task task) async {
  try {
    if (task.status == TaskStatus.completed) {
      final result = await _taskService.reopenTask(task);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
    } else {
      final result = await _taskService.completeTask(task);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed: $e')));
  }
}

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Task?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
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
                _deleteTask(task);
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

  void _openAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _openEditTaskScreen(Task task) {
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
          child: Text('No user logged in', style: context.text.bodyLarge),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      body: StreamBuilder<List<Task>>(
        stream: _taskRepository.getTasksForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  'Failed to load tasks: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Text(
                  'No tasks yet',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screen,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Padding(
                padding: AppSpacing.rowPadding,
                child: _TaskListCard(
                  task: task,
                  onToggleComplete: () => _toggleTask(task),
                  onEdit: () => _openEditTaskScreen(task),
                  onDelete: () => _showDeleteDialog(task),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const _TaskListCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final hasDescription = task.description.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: AppSpacing.listTilePadding,

        leading: IconButton(
          icon: Icon(
            isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: isCompleted
                ? context.appColors.success
                : context.colors.onSurfaceVariant,
          ),
          onPressed: onToggleComplete,
        ),

        title: Text(
          task.title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isCompleted
                ? context.colors.onSurfaceVariant
                : context.colors.onSurface,
          ),
        ),

        subtitle: Text(
          hasDescription
              ? task.description
              : 'Due: ${task.deadline.toLocal()}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        trailing: PopupMenuButton<String>(
          iconColor: context.colors.onSurfaceVariant,
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            }

            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: context.appColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}