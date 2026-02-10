import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'course_details_screen.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final supabase = Supabase.instance.client;
  final courseName = TextEditingController();
  bool loading = false;

  createCourse(String courseTitle) async {
    setState(() {
      loading = true;
    });

    try {
      await supabase.from('courses').insert({'title': courseTitle});
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Course'),
        content: TextField(
          controller: courseName,
          decoration: InputDecoration(hintText: 'Course Title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              createCourse(courseName.text.trim());
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Courses")),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => showAddCourseDialog(),
            icon: Icon(Icons.add),
            label: Text("Add Course"),
          ),
          Expanded(
            child: FutureBuilder(
              future: supabase.from('courses').select(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final courses = snapshot.data as List;
                if(courses.isEmpty) {
                  return Center(child: Text("No Courses"));
                }
                return ListView(
                  children: [
                    for (var course in courses)
                      ListTile(
                        onTap: (){
                          Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => CourseDetailsScreen(course: course)
                            ),
                          );
                        },
                        title: Text(course['title']),
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
