import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/screens/add_edit_task_screen.dart';

class CoursesTasksScreen extends StatefulWidget {
  const CoursesTasksScreen({super.key});

  @override
  State<CoursesTasksScreen> createState() => _CoursesTasksScreenState();
}

class _CoursesTasksScreenState extends State<CoursesTasksScreen> {
  final repo = TaskRepository();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<Task>>(
        stream: repo.getTasksForUser(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(
              child: Text("No tasks yet"),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),

                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),

                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == "delete") {
                        repo.deleteTask(task.id!);
                      }

                      if (value == "edit") {
                        // open edit screen 
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTaskScreen(task: task),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // open add task screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}