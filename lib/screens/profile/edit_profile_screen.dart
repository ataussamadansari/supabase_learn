import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final Map userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameCtr;
  late TextEditingController addressCtr;
  late TextEditingController phoneCtr;

  File? pickedFile;
  String? currentImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtr = TextEditingController(text: widget.userData['name']);
    addressCtr = TextEditingController(text: widget.userData['address']);
    phoneCtr = TextEditingController(text: widget.userData['phone']);
    currentImageUrl = widget.userData['profile_pic'];
  }

  // --- Image Pick Function ---
  Future<void> pickImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        pickedFile = File(result.path);
      });
    }
  }

  // --- Image Delete Function ---
  Future<void> removePhoto() async {
    final userId = supabase.auth.currentUser!.id;
    try {
      setState(() => isLoading = true);

      // 1. Storage se delete karein
      await supabase.storage.from('bucket1').remove(['users/$userId']);

      // 2. Database update karein (URL null set kar dein)
      await supabase.from('users').update({
        'profile_pic': null,
      }).eq('id', userId);

      setState(() {
        currentImageUrl = null;
        pickedFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo Removed")));
    } catch (e) {
      debugPrint("Error removing photo: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- Main Update Function ---
  Future<void> updateProfile() async {
    try {
      setState(() => isLoading = true);
      final userId = supabase.auth.currentUser!.id;
      String? finalUrl = currentImageUrl;

      if (pickedFile != null) {
        // Nayi image upload (upsert: true purani file replace kar dega)
        await supabase.storage.from('bucket1').upload(
          'users/$userId',
          pickedFile!,
          fileOptions: const FileOptions(upsert: true),
        );
        finalUrl = supabase.storage.from('bucket1').getPublicUrl('users/$userId');
      }

      await supabase.from('users').update({
        'name': nameCtr.text.trim(),
        'address': addressCtr.text.trim(),
        'phone': phoneCtr.text.trim(),
        'profile_pic': finalUrl,
      }).eq('id', userId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }on PostgrestException catch (e) {
      debugPrint("❌ Postgrest Error: ${e.message}");
      debugPrint("❌ Postgrest Detail: ${e.details}");
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: pickedFile != null
                          ? FileImage(pickedFile!)
                          : (currentImageUrl != null
                          ? NetworkImage(currentImageUrl!)
                          : const AssetImage('assets/images/user.png')) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                if (currentImageUrl != null || pickedFile != null)
                  TextButton.icon(
                    onPressed: removePhoto,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: nameCtr,
            decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: addressCtr,
            decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: phoneCtr,
            decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: updateProfile,
              child: const Text("UPDATE PROFILE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}