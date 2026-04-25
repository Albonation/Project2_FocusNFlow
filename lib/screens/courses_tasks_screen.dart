import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/models/task_model.dart';

class CoursesTasksScreen extends StatefulWidget{
  const CoursesTasksScreen({super.key});

  @override
  State<CoursesTasksScreen> createState() => _CoursesTasksScreenState();
}

class _CoursesTasksScreenState extends State<CoursesTasksScreen>{
  final repo = TaskRepository();

  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    
  }

}