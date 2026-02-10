import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/login_screen.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  final supabase = Supabase.instance.client;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (context) => false,
                  );
                },
                child: Text("Logout"),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
          future: supabase.from('students')
          .select('''
          name, email, students_courses(
            courses(
              title
            )
          )
          ''')
          .eq('id', supabase.auth.currentUser!.id).single(), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? {};
            if (data['students_courses'].isEmpty) {
              return Center(child: Text("No Courses joined"));
            }
            return ListView(
              children: [
                for (var course in data['students_courses'])
                  ListTile(
                    leading: Icon(Icons.join_full),
                    title: Text(course['courses']['title']),
                  )
              ],
            );
          }),
    );
  }
}
