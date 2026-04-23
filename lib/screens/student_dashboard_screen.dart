import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/widgets/student_dashboard_widgets/upcoming_study_sessions.dart';

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
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Section title
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  //Debug List
                  Expanded(
                    child: ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tasks = [
                          'Finish Flutter Assignment',
                          'Review CyberSecurity Notes',
                          'Attend Group Study Session',
                          'Submit Weekly Planner'
                        ];

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Boder.all(color/l Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              //Checkbox Icon
                              const Icon(Icons.check_circle_outline),

                              const SizedBox(height: 12),

                              //Task name
                              Expanded(
                                child: Text(
                                  tasks[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              //Debug Priority Label
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              )
                            ],)
                        )
                      }, ,))
                ],)
              ),
            ),
          ),

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