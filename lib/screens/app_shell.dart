import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/screens/courses_tasks_screen.dart';
import 'package:focus_n_flow/screens/profile_screen.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';
import 'package:focus_n_flow/screens/study_rooms_screen.dart';
import 'package:focus_n_flow/screens/groups_screen.dart';
import '../theme/theme_controller.dart';


class AppShell extends StatefulWidget{
  final ThemeController themeController;
  const AppShell({super.key, required this.themeController});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState(){
    super.initState();
  //Unfinished screens commented out for testing
    _screens = [
      StudentDashboardScreen(),
      CoursesTasksScreen(),
      ProfileScreen(themeController: widget.themeController),
      StudyRoomsScreen(),
      GroupsScreen(),
      //WeeklyPlannerScreen(),
    ];
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _selectedIndex < _screens.length
          ? _screens[_selectedIndex]
          : const StudentDashboardScreen(),
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
            /*
            if (index == 4){
              await _logout();
              return;
            }
            */

            setState((){
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
            BottomNavigationBarItem(
                icon: Icon(Icons.meeting_room),
                label: 'Spaces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Groups',
            ),
            /*
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
            */

      ]))
    );
  }
}