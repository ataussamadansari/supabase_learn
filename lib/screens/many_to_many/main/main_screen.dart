import 'package:flutter/material.dart';
import 'package:supabase_learn/screens/many_to_many/my_course/my_course_screen.dart';

import '../course/course_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens ki list
  final List<Widget> _screens = [
    const MyCourseScreen(),
    const CourseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "My Course"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Courses"),
        ],
      ),
    );
  }
}