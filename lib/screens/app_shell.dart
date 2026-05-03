import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/profile_screen.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';
import 'package:focus_n_flow/screens/weekly_planner_screen.dart';
import 'package:focus_n_flow/screens/study_rooms_screen.dart';
import '../theme/theme_controller.dart';

class AppShell extends StatefulWidget{
  final ThemeController themeController;
  const AppShell({super.key, required this.themeController});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return const StudentDashboardScreen();

      case 1:
        return const WeeklyPlanScreen();

      case 2:
        return const StudyRoomsScreen();

      case 3:
        return ProfileScreen(themeController: widget.themeController);

      default:
        return const StudentDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusNFlow'),
        centerTitle: true,
      ),
      body: _buildScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Weekly Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Study Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}