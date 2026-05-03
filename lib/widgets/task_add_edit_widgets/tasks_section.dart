import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/task_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/task_add_edit_widgets/task_card.dart';

class TasksSection extends StatefulWidget {
  final String userId;
  final VoidCallback onAddTask;
  final void Function(Task task) onEditTask;
  final VoidCallback? onTaskCompleted;

  const TasksSection({
    super.key,
    required this.userId,
    required this.onAddTask,
    required this.onEditTask,
    this.onTaskCompleted,
  });

  @override
  State<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends State<TasksSection> {
  final TaskRepository _taskRepository = TaskRepository();
  late final TaskService _taskService;
  final PlannerFirestoreRepository _plannerRepository = PlannerFirestoreRepository();

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(
      taskRepository: _taskRepository,
      plannerRepository: _plannerRepository
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final result = await _taskService.deleteTask(task);

      if (!mounted) return;
      _showMessage(result.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to delete task: $e');
    }
  }

  Future<bool> _confirmDeleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
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
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
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

    return shouldDelete ?? false;
  }

  Future<bool> _confirmReopenToPending(Task task) async {
    final shouldReopen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Reopen Task?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to reopen "${task.title}" and set it back to pending?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Yes',
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

    return shouldReopen ?? false;
  }

  Future<bool> _confirmReopenToInProgress(Task task) async {
    final shouldReopen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Reopen Task?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to reopen "${task.title}" and mark it as in progress?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Yes',
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

    return shouldReopen ?? false;
  }

  Future<void> _handleStatusButtonPressed(Task task) async {
    if (task.status == TaskStatus.completed) {
      final shouldReopen = await _confirmReopenToPending(task);

      if (!shouldReopen) return;

      await _updateTaskStatus(task, TaskStatus.pending);
      return;
    }

    await _updateTaskStatus(task, TaskStatus.completed);
    widget.onTaskCompleted?.call();
  }

  Future<void> _handleTaskLongPress(Task task) async {
    switch (task.status) {
      case TaskStatus.pending:
        await _updateTaskStatus(task, TaskStatus.inProgress);
        break;

      case TaskStatus.inProgress:
        _showMessage('Task is already in progress.');
        break;

      case TaskStatus.completed:
        final shouldReopen = await _confirmReopenToInProgress(task);

        if (!shouldReopen) return;

        await _updateTaskStatus(task, TaskStatus.inProgress);
        break;
    }
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus status) async {
    try {
      final updatedTask = _copyTaskWithStatus(task, status);
      final result = await _taskService.saveTaskChanges(updatedTask);

      if (!mounted) return;
      _showMessage(result.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to update task: $e');
    }
  }

  Task _copyTaskWithStatus(Task task, TaskStatus status) {
    return Task(
      id: task.id,
      userId: task.userId,
      courseId: task.courseId,
      title: task.title,
      description: task.description,
      deadline: task.deadline,
      estimatedHours: task.estimatedHours,
      status: status,
      manualImportance: task.manualImportance,
      completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      createdAt: task.createdAt,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TasksHeader(onAddTask: widget.onAddTask),

        AppSpacing.gapSm,

        const Divider(),

        AppSpacing.gapSm,

        StreamBuilder<List<Task>>(
          stream: _taskRepository.getTasksForUser(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Failed to load tasks: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              );
            }

            final tasks = snapshot.data ?? [];

            if (tasks.isEmpty) {
              return Text(
                'No tasks yet. Tap + to add your first task.',
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              );
            }

            return Column(
              children: tasks.map((task) {
                return Padding(
                  padding: AppSpacing.rowPadding,
                  child: Dismissible(
                    key: ValueKey(task.id ?? task.title),
                    direction: DismissDirection.endToStart,
                    background: _DeleteSwipeBackground(),
                    secondaryBackground: _DeleteSwipeBackground(),
                    confirmDismiss: (_) async {
                      final shouldDelete = await _confirmDeleteTask(task);

                      if (shouldDelete) {
                        await _deleteTask(task);
                      }

                      return false;
                    },
                    child: TaskCard(
                      task: task,
                      onTap: () {
                        widget.onEditTask(task);
                      },
                      onLongPress: () {
                        _handleTaskLongPress(task);
                      },
                      onStatusButtonPressed: () {
                        _handleStatusButtonPressed(task);
                      },
                    ),
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

class _TasksHeader extends StatelessWidget {
  final VoidCallback onAddTask;

  const _TasksHeader({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Tasks',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: 'Add task',
          color: context.appColors.brand,
          onPressed: onAddTask,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _DeleteSwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: AppSpacing.horizontalLg,
      decoration: BoxDecoration(
        color: context.appColors.danger,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}
