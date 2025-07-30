import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

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

  void toggleVisibility() {
    setState(() {
      ishidden = !ishidden;
    });
  }

  void signin() {
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
            if (errorMessage.isNotEmpty) SizedBox(height: 15),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 25),
            FilledButton(
              onPressed: () {
                signin();
              },
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
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
