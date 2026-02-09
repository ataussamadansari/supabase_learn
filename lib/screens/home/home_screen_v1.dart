import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_learn/screens/notes/add_note_screen.dart';
import 'package:supabase_learn/screens/notes/update_note_screen.dart';

import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
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
      body: StreamBuilder(
        stream: supabase.from('notes').stream(primaryKey: ['id']),
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final notes = asyncSnapshot.data ?? [];
          return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    for (var note in notes)
                      ListTile(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateNoteScreen(note: note)),
                          );
                        },
                        title: Text(note['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['description']),
                            SizedBox(height: 4),
                            Text(
                              note['created_at'],
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            await supabase.from('notes').delete().eq('id', note['id']);
                          },
                          icon: Icon(CupertinoIcons.delete, color: Colors.red),
                        ),
                      ),
                  ],
                );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
