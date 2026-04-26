import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/screens/courses_tasks_screen.dart';
import 'package:focus_n_flow/screens/profile_screen.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';
import '../theme/theme_controller.dart';

class AppShell extends StatefulWidget{
  final ThemeController themeController;
  const AppShell({super.key, required this.themeController});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState(){
    super.initState();
  }
  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return const StudentDashboardScreen();

      case 1:
        return const CoursesTasksScreen();

      case 2:
        return ProfileScreen(
          themeController: widget.themeController,
        );

      default:
        return const StudentDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _buildScreen(),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey, width: 1
            )
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) async {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task),
              label: 'View Tasks',
            ),
            //Placeholder for unfinished screens. 
            //Commented out for testing
            //BottomNavigationBarItem(
            //  icon: Icon(Icons.group),
            //  label: 'Group Chat',
            //),
            //BottomNavigationBarItem(
            //  icon: Icon(Icons.checklist),
            //  label: 'Weekly Planner',
            //),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}