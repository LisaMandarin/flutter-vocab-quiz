import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/usercard_widget.dart';
import 'package:vocab_quiz/views/pages/home_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController controllerUsername = TextEditingController();
  String errorMessage = '';
  void refreshPage() {
    setState(() {});
  }

  @override
  void dispose() {
    controllerUsername.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Setting"),
      body: FutureBuilder(
        future: firestore.value.getUserDoc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final userData = snapshot.data;
            final email = userData?['email'] ?? "";
            final username = (userData)?['username'];
            if (controllerUsername.text.isEmpty && username != null) {
              controllerUsername.text = username;
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username != null ? "Hello, $username" : "Hello",
                    style: titleStyle,
                  ),
                  UsercardWidget(
                    email: email,
                    username: username,
                    controllerUsername: controllerUsername,
                    errorMessage: errorMessage,
                    refresh: refreshPage,
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await authService.value.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(title: "Vocab Quiz"),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text("Sign Out"),
                  ),
                ],
              ),
            );
          }
          // Always return a widget if no data or error
          return Center(child: Text('No user data found.'));
        },
      ),
    );
  }
}
