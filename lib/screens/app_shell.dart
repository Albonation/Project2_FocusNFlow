import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  //Unfinished screens commented out for testing
    const _screens = [
      StudentDashboardScreen(),
      CoursesTasksScreen(),
      //GroupChatScreen(),
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
            if (index == 2){
              await _logout();
              return;
            }

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
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),

      ]))
    );
  }
}