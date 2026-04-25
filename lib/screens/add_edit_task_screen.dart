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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null){
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveTask() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (titleController.text.isEmpty || selectedDate == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (isEditMode){
      final updatedTask = widget.task!.copyWith(
        title: titleController.text,
        description: descController.text,
        deadline: selectedDate,
        estimatedHours: double.tryParse(hoursController.text) ?? 0,
        updatedAt: DateTime.now(),
      );

      await repo.updateTask(updatedTask);
    } else {
      final newTask = Task(
        userId: user.uid,
        title: titleController.text,
        description: descController.text,
        deadline: selectedDate!,
        estimatedHours: double.tryParse(hoursController.text) ?? 0,
      );

      await repo.addTask(newTask);
    }

    if(mounted) Navigator.pop(context);
  }

}