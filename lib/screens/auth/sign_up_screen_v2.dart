import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_learn/screens/main/main_screen.dart';

import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final countryCtr = TextEditingController();
  final cityCtr = TextEditingController();
  final streetCtr = TextEditingController();
  final pinCodeCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  bool loading = false;
  File? profilePic;
  final supabase = Supabase.instance.client;

  register() async {
    try {
      setState(() {
        loading = true;
      });

      final result = await supabase.auth.signUp(
        email: emailCtr.text.trim(),
        password: passwordCtr.text.trim(),
      );

      if (result.user != null && result.session != null) {
        await supabase.storage
            .from('bucket1')
            .upload('users/${result.user!.id}', profilePic!);

        String url = supabase.storage
            .from('bucket1')
            .getPublicUrl('users/${result.user!.id}');
        /*String url1 = await supabase.storage
            .from('bucket1')
            .createSignedUrl('users/${result.user!.id}', 60);*/
        debugPrint("URL: $url");

        await supabase.from('users').insert({
          'name': nameCtr.text.trim(),
          'email': emailCtr.text.trim().toLowerCase(),
          'phone': phoneCtr.text.trim(),
          'profile_pic': url,
        });

        await supabase.from('addresses').insert({
          'country': countryCtr.text.trim(),
          'city': cityCtr.text.trim(),
          'street': streetCtr.text.trim(),
          'pin_code': pinCodeCtr.text.trim(),
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (context) => false,
        );
      }
    } on PostgrestException catch (e) {
      debugPrint(e.message);
    } catch (e) {
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
      appBar: AppBar(title: const Text("Register Screen")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profilePic == null
                      ? AssetImage('assets/images/user.png') as ImageProvider
                      : FileImage(profilePic!),
                ),
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: IconButton(
                    onPressed: () async {
                      final result = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (result != null) {
                        setState(() {
                          profilePic = File(result.path);
                        });
                      }
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: nameCtr,
            decoration: InputDecoration(hintText: "Name"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: emailCtr,
            decoration: InputDecoration(hintText: "Email"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: countryCtr,
            decoration: InputDecoration(hintText: "Country"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: cityCtr,
            decoration: InputDecoration(hintText: "City"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: streetCtr,
            decoration: InputDecoration(hintText: "Street"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: pinCodeCtr,
            maxLength: 6,
            decoration: InputDecoration(hintText: "Pin Code"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: phoneCtr,
            decoration: InputDecoration(hintText: "Phone"),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: passwordCtr,
            decoration: InputDecoration(hintText: "Password"),
          ),
          SizedBox(height: 15),
          loading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () {
                    register();
                  },
                  child: Text("SignUp"),
                ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Already have an account? SignUp"),
          ),
        ],
      ),
    );
  }
}
