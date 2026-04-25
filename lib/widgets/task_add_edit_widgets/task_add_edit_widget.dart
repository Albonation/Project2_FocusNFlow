import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/task_service.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';

class AddEditTask extends StatefulWidget {
  final Task? task;

  const AddEditTask({
    super.key,
    this.task,
  });

  @override
  State<AddEditTask> createState() => _AddEditTaskFormState();
}

class _AddEditTaskFormState extends State<AddEditTask> {
  final service = TaskService(
    taskRepository: TaskRepository(),
  );

  final titleController = TextEditingController();
  final courseIDController = TextEditingController();
  final descController = TextEditingController();
  final hoursController = TextEditingController();

  DateTime? selectedDate;

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
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
    if (user == null || selectedDate == null) return;

    final task = Task(
      id: widget.task?.id,
      userId: user.uid,
      title: titleController.text,
      courseId: courseIDController.text,
      description: descController.text,
      deadline: selectedDate!,
      estimatedHours: double.tryParse(hoursController.text) ?? 0,
    );

    final result = isEditMode
        ? await service.saveTaskChanges(task)
        : await service.createTask(task);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: courseIDController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value){
              courseIDController.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: value.toUpperCase().length),
              );
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: const InputDecoration(
              labelText: "Course ID (e.g. ECON2002)",
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: "Description"),
          ),

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          TextField(
            controller: hoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Estimated Hours",
              hintText: "Enter number of hours",
            ),
          ),

          GestureDetector(
            onTap: pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedDate == null
                    ? "Select Deadline"
                    : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}",
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate == null
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
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
    );
  }
}