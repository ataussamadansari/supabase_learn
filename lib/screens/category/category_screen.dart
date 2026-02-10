import 'package:flutter/cupertino.dart'; // Cupertino widgets ke liye zaroori h
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final supabase = Supabase.instance.client;
  final categoryName = TextEditingController();

  // Function: Category Create karne ke liye
  Future<void> createCategory() async {
    if (categoryName.text.isEmpty) return;

    try {
      await supabase.from('categories').insert({
        'name': categoryName.text.trim(),
      });
      categoryName.clear();
      if (mounted) Navigator.pop(context); // Dialog band karne ke liye
    } catch (e) {
      debugPrint("Error: $e");
    }
  }


  void showAddCategoryDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Add New Category"),
        content: Padding(
          // Keyboard ke saath adjust karne ke liye scroll view
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            mainAxisSize: MainAxisSize.max, // Jitna content utni height
            children: [
              const Text(
                "Enter the name of your new category below.",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 15),
              CupertinoTextField(
                controller: categoryName,
                placeholder: "Category Name",
                padding: const EdgeInsets.all(12),
                autofocus: true, // Dialog khulte hi keyboard aa jayega
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  border: Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Thodi extra height add karne ke liye
              const SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              categoryName.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: createCategory,
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Category")),
      body: StreamBuilder(
        stream: supabase.from('categories').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(categories[index]['name']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}