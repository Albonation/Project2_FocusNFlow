import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/courses_tasks_screen.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';

class AppShell extends StatefulWidget{
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState(){
    super.initState();

    _screens = [
      StudentDashboardScreen(),
      CoursesTasksScreen(),
      //GroupChatScreen(),
      //WeeklyPlannerScreen(),
    ];
  }

  @override
  
}