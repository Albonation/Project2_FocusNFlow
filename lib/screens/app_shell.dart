import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/profile_screen.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';
import 'package:focus_n_flow/screens/groups_screen.dart';
import 'package:focus_n_flow/services/notification_service.dart';
import '../theme/theme_controller.dart';

class AppShell extends StatefulWidget {
  final ThemeController themeController;

  const AppShell({super.key, required this.themeController});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final NotificationService _notificationService = NotificationService();
  late final List<Widget> _screens;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

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
        return const GroupsScreen();

      case 3:
        return ProfileScreen(
          themeController: widget.themeController,
        );

      default:
        return const StudentDashboardScreen();
    }
    _notificationService.initialize();
    //Unfinished screens commented out for testing
    _screens = [
      StudentDashboardScreen(),
      CoursesTasksScreen(),
      ProfileScreen(themeController: widget.themeController),
      GroupsScreen(),
      //StudyRoomsScreen(),
      //WeeklyPlannerScreen(),
    ];
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
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
            icon: Icon(Icons.groups),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: _selectedIndex < _screens.length
          ? _screens[_selectedIndex]
          : const StudentDashboardScreen(),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) async {
            if (index == 4) {
              await _logout();
              return;
            }

            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_task),
                label: 'View Tasks',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Groups'),
            BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Logout'),
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
            /*BottomNavigationBarItem(
                icon: Icon(Icons.meeting_room),
                label: 'Spaces',
            ),*/
          ],
        ),
      ),
    );
  }
}
