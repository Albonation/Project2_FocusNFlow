import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';

class AddEditTaskScreen extends StatefulWidget{
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTasksScreenState extends State<AddEditTaskScreen>{
  final repo = TaskRepository();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final hoursController = TextEditingController();
}