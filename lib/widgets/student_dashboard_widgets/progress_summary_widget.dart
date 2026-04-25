import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/student_dashbord_services.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';

class ProgressSummary extends StatelessWidget {
  final service = StudentDashbordServices();
  final repo = TaskRepository();

  ProgressSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("No user logged in. Progress unavailable."),
      );
    }

    return StreamBuilder<List<Task>>(
      stream: repo.getTasksForUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = snapshot.data!;

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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...tasks.map((task) {
                final progress =
                    (service.getProgress(task) * 100).toInt();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(task.title),
                        Text("$progress%"),
                      ],
                    ),

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