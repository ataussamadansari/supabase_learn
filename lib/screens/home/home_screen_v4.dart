import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  File? pickedFile;
  bool isLoading = false;

  uploadImage() async {
    try {
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      String ext = pickedFile!.path.split('.').last;
      setState(() {
        isLoading = true;
      });

      final result = await supabase.storage.from('bucket1').upload(
          'photos/$fileName.$ext',
          pickedFile!
      );
      String url = supabase.storage.from('bucket1').getPublicUrl(
        'photos/$fileName.$ext'
      );
      debugPrint("Result URL: $url");
      // debugPrint("Result: $result");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  getImages() async {
    final result = await supabase.storage.from('bucket1').list(path: 'photos');
    for(var img in result) {
      debugPrint(img.name);
      final url = supabase.storage
          .from('bucket1')
          .getPublicUrl('photos/${img.name}');

      debugPrint(url);
    }
  }

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.heightOf(context);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pickedFile == null
                ? SizedBox()
                : Image.file(pickedFile!, height: height * 0.4),
            ElevatedButton(
              onPressed: () async {
                final result = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (result != null) {
                  setState(() {
                    pickedFile = File(result.path);
                  });
                }
              },
              child: Text("Pick Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {
              uploadImage();
            }, child: Text("Upload Image")),
          ],
        ),
      ),
    );
  }
}
