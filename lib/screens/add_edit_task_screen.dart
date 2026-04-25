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