import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/upcoming_study_sessions_widget.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/task_widget.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboardScreen> {
  String fullName = "Student";

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
      body: Column(
        children: [
          // Top 1/3 → Today's Tasks
          Tasks(),
          // Middle Section
          UpcomingStudySessions(),
          //not using const in preparation 
          //for firebase integration
          const SizedBox(height: 25),

          // Bottom Section
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("Section 3"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}