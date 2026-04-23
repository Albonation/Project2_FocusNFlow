import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/progress_summary_widget.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/upcoming_study_sessions_widget.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/task_widget.dart';
import 'package:focus_n_flow/models/task_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboardScreen> {
  String fullName = "Student";

  List<Task> tasks = [
    Task(title: "Finish Flutter Assignment", deadline: DateTime.now(), effort: 5, courseWeight: 10),
    Task(title: "Review CyberSecurity Notes", deadline: DateTime(2026, 05, 23, 14, 50), effort: 3, courseWeight: 4),
    Task(title: "Attend Group Study Session", deadline: DateTime(2026, 04, 25, 4, 30), effort: 4, courseWeight: 15),
    Task(title: "Submit Weekly Planner", deadline: DateTime(2026, 04, 28, 16, 40), effort: 1, courseWeight: 1),
  ];

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance    
        .collection("users")
        .doc(user.uid)
        .get();

      if (doc.exists){
        setState((){
          fullName = doc["fullName"];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $fullName"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Today's Tasks
              Tasks(),

              const SizedBox(height: 20),

              // Upcoming Study Sessions
              const UpcomingStudySessions(),

              const SizedBox(height: 20),

              // Progress Summary
              ProgressSummary(tasks: tasks),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
