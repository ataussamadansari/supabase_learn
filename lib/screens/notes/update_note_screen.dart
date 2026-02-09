import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  const UpdateNoteScreen({super.key, required this.note});

  @override
  State<UpdateNoteScreen> createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  final titleCtr = TextEditingController();
  final descriptionCtr = TextEditingController();
  bool isLoading = false;
  final supabase = Supabase.instance.client;

  updateNote() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.from('notes').update({
        'title': titleCtr.text.trim(),
        'description': descriptionCtr.text.trim(),
      }).eq('id', widget.note['id']);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    titleCtr.text = widget.note['title'];
    descriptionCtr.text = widget.note['description'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Note Screen")),
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
              updateNote();
            },
            child: Text("Update Note"),
          ),
        ],
      ),
    );
  }
}
