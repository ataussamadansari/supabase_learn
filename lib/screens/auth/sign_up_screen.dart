import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_learn/screens/many_to_many/main/main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  bool loading = false;
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

        await supabase.from('students').insert({
          'name': nameCtr.text.trim(),
          'email': emailCtr.text.trim().toLowerCase(),
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
