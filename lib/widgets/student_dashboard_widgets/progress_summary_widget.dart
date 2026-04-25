import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/student_dashbord_services.dart';

class ProgressSummary extends StatelessWidget {
  final Stream<List<Task>> stream;
  final StudentDashbordServices service = StudentDashbordServices();

  ProgressSummary({super.key, required this.stream});

  @override
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
}