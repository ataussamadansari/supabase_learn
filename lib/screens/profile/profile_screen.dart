import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  File? pickedFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
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
        future: supabase
            .from('users')
            .select('*, address:addresses(*)')
            .eq('id', supabase.auth.currentUser!.id).single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          }
          final user = snapshot.data!;
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
              RichText(text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(text: "Email: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: user['email'] ?? '')
                ]
              )),
              RichText(text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(text: "Phone: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: user['phone'] ?? '')
                ]
              )),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(text: "Address: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "${user['address'][0]['street']}, "),
                    TextSpan(text: "${user['address'][0]['city']}, "),
                    TextSpan(text: "${user['address'][0]['country']} - "),
                    TextSpan(
                      text: "${user['address'][0]['pin_code']}",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
