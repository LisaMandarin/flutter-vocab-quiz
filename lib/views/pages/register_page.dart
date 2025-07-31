import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirm = TextEditingController();
  bool ishidden = true;
  bool ishidden2 = true;
  String errorMessage = '';

  void toggleVisibility() {
    setState(() {
      ishidden = !ishidden;
    });
  }

  void toggleVisibility2() {
    setState(() {
      ishidden2 = !ishidden2;
    });
  }

  void register() async {
    setState(() {
      errorMessage = "";
    });
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
    if (controllerConfirm.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please confirm your password";
      });
      return;
    }
    if (controllerPassword.text.trim() != controllerConfirm.text.trim()) {
      setState(() {
        errorMessage =
            "Oops!  Your first password does not match the second one";
      });
      return;
    }
    try {
      await authService.value.createAccount(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
      );
      await firestore.value.createUserRecordIfNotExists();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage =
            e.message ??
            "Something went wrong during registration.  Try again later";
      });
    }
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    controllerConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Register"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            SizedBox(height: 15),
            TextField(
              controller: controllerConfirm,
              obscureText: ishidden2,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  onPressed: toggleVisibility2,
                  icon: ishidden2
                      ? Icon(Icons.visibility_outlined)
                      : Icon(Icons.visibility_off_outlined),
                ),
              ),
            ),
            if (errorMessage.isNotEmpty) SizedBox(height: 15),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 25),
            FilledButton(
              onPressed: () {
                register();
              },
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Register"),
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
