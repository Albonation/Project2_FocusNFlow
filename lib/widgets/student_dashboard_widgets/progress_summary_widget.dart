import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/student_dashboard_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';

class ProgressSummary extends StatelessWidget {
  final Stream<List<Task>> stream;
  final StudentDashboardService service = StudentDashboardService();

  ProgressSummary({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
              child: Text('Unable to load task summary: ${snapshot.error}'),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Text('No tasks to summarize yet.'),
            ),
          );
        }

        final pendingCount = service.countPendingTasks(tasks);
        final inProgressCount = service.countInProgressTasks(tasks);
        final completedTodayCount = service.countCompletedToday(tasks);
        final overdueCount = service.countOverdueTasks(tasks);
        final topPriorityTasks = service.getTopPriorityTasks(tasks);

        return Card(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  const Divider(),
                  AppSpacing.gapSm,

                  const Text(
                    'Top Priority',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  AppSpacing.gapSm,
                  ...topPriorityTasks.map(
                    (task) => Padding(
                      padding: AppSpacing.rowPadding,
                      child: Row(
                        children: [
                          const Icon(Icons.priority_high, size: 18),
                          AppSpacing.horizontalGapSm,
                          Expanded(
                            child: Text(
                              task.title,
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
        );
      },
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
          Icon(icon, size: 20),
          AppSpacing.horizontalGapSm,
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

//saving for reference
/*@override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("No user logged in. Progress unavailable."),
      );
    }

    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        final now = DateTime.now();

        final completedTasks = tasks.where((task) {
          if (task.completedAt == null) return false;

          return task.completedAt!.year == now.year &&
              task.completedAt!.month == now.month &&
              task.completedAt!.day == now.day;
        }).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Progress Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final progressValue = service.getProgress(task);
                  final progressPercent = (progressValue * 100).toInt();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task.title),
                            Text("$progressPercent%"),
                          ],
                        ),

                        const SizedBox(height: 6),

                        LinearProgressIndicator(
                          value: progressValue,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                "Completed Today: ${completedTasks.length}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}*/
