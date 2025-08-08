import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/pages/setting_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool ishidden = true;
  String errorMessage = '';

  // toggle password visibility
  void toggleVisibility() {
    setState(() {
      ishidden = !ishidden;
    });
  }

  // validate login inputs and log in through Firebase authentication
  void signin() async {
    setState(() {
      errorMessage = "";
    });
    EasyLoading.show(status: "Logging in...");
    if (controllerEmail.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Oops!  Your email address is?";
      });
      return;
    }
    if (controllerPassword.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Oops!  What's your password?";
      });
      return;
    }
    try {
      await authService.value.signIn(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
      );
      EasyLoading.dismiss();
      Future.delayed(Duration(milliseconds: 100));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SettingPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "There is an error during login";
      });
    }
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Login"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // email
            TextField(
              controller: controllerEmail,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            // password
            TextField(
              controller: controllerPassword,
              obscureText: ishidden,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  onPressed: toggleVisibility,
                  icon: ishidden
                      ? Icon(Icons.visibility_outlined)
                      : Icon(Icons.visibility_off_outlined),
                ),
              ),
            ),

            // error message
            if (errorMessage.isNotEmpty) SizedBox(height: 15),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 25),

            // log in button
            FilledButton(
              onPressed: () {
                signin();
              },
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color((0xFF171717)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign In"),
                  SizedBox(width: 10),
                  Icon(Icons.login),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
