import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleCtr = TextEditingController();
  final descriptionCtr = TextEditingController();
  bool isLoading = false;
  final supabase = Supabase.instance.client;

  addNote() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('notes').insert({
        'title': titleCtr.text.trim(),
        'description': descriptionCtr.text.trim(),
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note Screen")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: titleCtr,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: descriptionCtr,
            decoration: InputDecoration(hintText: "Description"),
          ),
          SizedBox(height: 15),

          isLoading ? Center(child: CircularProgressIndicator()) :
          ElevatedButton(
            onPressed: () {
              addNote();
            },
            child: Text("Add Note"),
          ),
        ],
      ),
    );
  }
}
