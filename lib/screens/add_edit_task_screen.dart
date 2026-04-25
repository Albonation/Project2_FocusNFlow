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

  DateTime? selectedDate;

  bool get isEditMode => widget.task != null;

  @override
  void initState(){
    super.initState();

    if (isEditMode){
      final task = widget.task!;
      titleController.text = task.title;
      descController.text = task.description;
      hoursController.text = task.estimatedHours.toString();
      selectedDate = task.deadline;
    }
  }
}