import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  File? pickedFile;
  bool isLoading = false;

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
        stream: supabase
            .from('users')
            .stream(primaryKey: ['id'])
            .eq('id', supabase.auth.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          }
          final user = snapshot.data!.first;
          final String? profilePicUrl = user['profile_pic'];

          return Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                      ? NetworkImage(profilePicUrl,)
                      : const AssetImage('assets/images/user.png') as ImageProvider,
                ),
              ),
              Text(
                user['name'] ?? '',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(user['email'] ?? ''),
              Text(user['phone'] ?? ''),
            ],
          );
        },
      ),
    );
  }
}
