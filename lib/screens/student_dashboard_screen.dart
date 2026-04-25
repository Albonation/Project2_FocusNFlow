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
    Task(
      userId: "demoUser",
      courseId: "course1",
      title: "Finish Flutter Assignment",
      description: "Complete dashboard UI",
      deadline: DateTime.now(),
      estimatedHours: 5,
    ),

    Task(
      userId: "demoUser",
      courseId: "course2",
      title: "Review CyberSecurity Notes",
      description: "Study firewall concepts",
      deadline: DateTime(2026, 5, 23, 14, 50),
      estimatedHours: 3,
    ),

    Task(
      userId: "demoUser",
      courseId: "course3",
      title: "Attend Group Study Session",
      description: "Meet with study group",
      deadline: DateTime(2026, 4, 25, 4, 30),
      estimatedHours: 4,
    ),

    Task(
      userId: "demoUser",
      courseId: "course4",
      title: "Submit Weekly Planner",
      description: "Upload planner to app",
      deadline: DateTime(2026, 4, 28, 16, 40),
      estimatedHours: 1,
    ),
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
