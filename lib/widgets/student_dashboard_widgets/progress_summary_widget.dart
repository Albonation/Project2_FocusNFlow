import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/screens/courses_tasks_screen.dart';
import 'package:focus_n_flow/services/student_dashboard_service.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class ProgressSummary extends StatelessWidget {
  final Stream<List<Task>> stream;
  final StudentDashboardService service = StudentDashboardService();

  ProgressSummary({super.key, required this.stream});

  void _openCoursesTasksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CoursesTasksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Text(
                'Unable to load task summary: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _EmptyProgressSummaryCard(
            onOpenCoursesTasks: () {
              _openCoursesTasksScreen(context);
            },
          );
        }

        final pendingCount = service.countPendingTasks(tasks);
        final inProgressCount = service.countInProgressTasks(tasks);
        final completedTodayCount = service.countCompletedToday(tasks);
        final overdueCount = service.countOverdueTasks(tasks);
        final topPriorityTasks = service.getTopPriorityTasks(tasks);

        return InkWell(
          borderRadius: BorderRadius.circular(AppCorners.lg),
          onTap: () {
            _openCoursesTasksScreen(context);
          },
          child: Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Summary',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  AppSpacing.gapMd,

                  _SummaryRow(
                    label: 'Pending',
                    value: pendingCount.toString(),
                    icon: Icons.radio_button_unchecked,
                  ),
                  _SummaryRow(
                    label: 'In Progress',
                    value: inProgressCount.toString(),
                    icon: Icons.timelapse,
                  ),
                  _SummaryRow(
                    label: 'Completed Today',
                    value: completedTodayCount.toString(),
                    icon: Icons.check_circle_outline,
                  ),
                  _SummaryRow(
                    label: 'Overdue',
                    value: overdueCount.toString(),
                    icon: Icons.warning_amber,
                  ),

                  if (topPriorityTasks.isNotEmpty) ...[
                    AppSpacing.gapLg,

                    Text(
                      'Top Priority Tasks',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.gapSm,

                    ...topPriorityTasks.map(
                      (task) => Padding(
                        padding: AppSpacing.rowPadding,
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: context.appColors.planner,
                            ),
                            AppSpacing.horizontalGapSm,
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyProgressSummaryCard extends StatelessWidget {
  final VoidCallback onOpenCoursesTasks;

  const _EmptyProgressSummaryCard({required this.onOpenCoursesTasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Summary',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapMd,

            Text(
              'No tasks to summarize yet',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            AppSpacing.gapMd,

            Text(
              'Add your courses and tasks to unlock the dashboard summary',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            AppSpacing.gapLg,

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenCoursesTasks,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add Courses & Tasks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.rowPadding,
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
          AppSpacing.horizontalGapSm,
          Expanded(child: Text(label, style: context.text.bodyMedium)),
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
