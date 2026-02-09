import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_learn/screens/auth/sign_up_screen.dart';

import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool loading = false;
  final supabase = Supabase.instance.client;

  login() async {
    try {
      setState(() {
        loading = true;
      });

      final result = await supabase.auth.signInWithPassword(
        email: _emailCtr.text.trim(),
        password: _passwordCtr.text.trim(),
      );

      if (result.user != null && result.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
      appBar: AppBar(title: const Text("Login Screen")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _emailCtr,
            decoration: InputDecoration(hintText: "Email"),
          ),
          TextFormField(
            controller: _passwordCtr,
            decoration: InputDecoration(hintText: "Password"),
          ),
          SizedBox(height: 15),
          loading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text("Login"),
                ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            child: Text("Don't have an account? SignUp"),
          ),
        ],
      ),
    );
  }
}
