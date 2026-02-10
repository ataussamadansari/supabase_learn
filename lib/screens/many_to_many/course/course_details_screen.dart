import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final supabase = Supabase.instance.client;
  bool loading = false;

  joinCourse() async {
    try {
      setState(() {
        loading = true;
      });
      await supabase.from('students_courses').insert({
        'student_id': supabase.auth.currentUser!.id,
        'course_id': widget.course['id'],
      });
    } on PostgrestException catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details Courses")),
      body: Column(
        children: [
          ListTile(
            title: Text('Course title'),
            subtitle: Text(widget.course['title']),
            trailing: loading
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () => joinCourse(),
                    child: Text('Join Now'),
                  ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder(
              future: supabase
                  .from('courses')
                  .select('''
                      id, title, students_courses(
                        students(
                          name, email
                        )
                      )
                      ''')
                  .eq('id', widget.course['id'])
                  .single(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data ?? {};
                if (data['students_courses'].isEmpty) {
                  return Center(child: Text("No Students"));
                }
                return ListView(
                  children: [
                    for (var student in data['students_courses'])
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(student['students']['name']),
                        subtitle: Text(student['students']['email']),
                      ),
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
