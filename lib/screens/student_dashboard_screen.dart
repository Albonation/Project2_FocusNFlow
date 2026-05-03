import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/progress_summary_widget.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/upcoming_study_sessions_widget.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/task_widget.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboardScreen> {
  final TaskRepository _taskRepository = TaskRepository();

  String? _userId;
  String fullName = "Student";
  Stream<List<Task>>? taskStream;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;

    if (_userId != null) {
      getUserData(_userId!);
    }
  }

  Future<void> getUserData(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    if (!mounted) return;

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;

      setState(() {
        fullName = (data["fullName"] as String?) ?? "Student";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    if (userId == null) {
      return const Center(child: Text("No user logged in"));
    }

    final taskStream = _taskRepository.getTasksForUser(userId);

    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.tile,
        child: Column(
          children: [
            Text(
              "Welcome, $fullName",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            AppSpacing.gapXl,
            ProgressSummary(stream: taskStream),
            AppSpacing.gapXl,
            UpcomingStudySessions(),
            AppSpacing.gapXl,
            Tasks(stream: taskStream),
          ],
        ),
      ),
    );
  }
}
