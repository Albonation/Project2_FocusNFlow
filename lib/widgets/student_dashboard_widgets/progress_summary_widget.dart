import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/student_dashbord_services.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';

class ProgressSummary extends StatelessWidget {
  final service = StudentDashbordServices();
  final repo = TaskRepository();

  ProgressSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: repo.getTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;

        final completedTasks =
            tasks.where((t) => t.isCompleted).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Progress Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...tasks.map((task) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title),

                    const SizedBox(height: 6),

                    LinearProgressIndicator(
                      value: service.getProgress(task),
                    ),

                    const SizedBox(height: 12),
                  ],
                );
              }),

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
}