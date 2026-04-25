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

class _AddEditTaskScreenState extends State<AddEditTaskScreen>{
  final repo = TaskRepository();

  final titleController = TextEditingController();
  final courseIDController = TextEditingController();
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
      courseIDController.text = task.courseId;
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
        courseId: courseIDController.text,
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
        courseId: courseIDController.text,
        description: descController.text,
        deadline: selectedDate!,
        estimatedHours: double.tryParse(hoursController.text) ?? 0,
      );

      await repo.addTask(newTask);
    }

    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Task" : "Add Task"),
        centerTitle: true,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                      ? "No date selected"
                      : "Deadline: ${selectedDate!.toLocal()}".split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTask,
                child: Text(isEditMode ? "Update Task" : "Add Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}