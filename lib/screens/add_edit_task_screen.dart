import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/widgets/task_add_edit_widgets/task_add_edit_widget.dart';

class AddEditTaskScreen extends StatelessWidget {
  final Task? task;

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isEditMode = task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Task" : "Add Task",
        ),
        centerTitle: true,
      ),
      body: AddEditTask(
        task: task,
      ),
    );
  }
}