import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/pages/home_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController controllerUsername = TextEditingController();
  String errorMessage = '';

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
                  Card(
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.email_outlined),
                                Text(": $email"),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.person_2_outlined),
                                Text(": ${username ?? "(unknown)"}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: controllerUsername,
                                              decoration: InputDecoration(
                                                label: Text("Username"),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        errorMessage = "";
                                                      });
                                                      if (controllerUsername
                                                          .text
                                                          .trim()
                                                          .isEmpty) {
                                                        setState(() {
                                                          errorMessage =
                                                              "What's your username?";
                                                        });
                                                        return;
                                                      }
                                                      try {
                                                        if (username == null) {
                                                          await firestore.value
                                                              .addUsername(
                                                                controllerUsername
                                                                    .text
                                                                    .trim(),
                                                              );
                                                        } else {
                                                          await firestore.value
                                                              .updateUsername(
                                                                controllerUsername
                                                                    .text
                                                                    .trim(),
                                                              );
                                                        }
                                                        if (!mounted) return;
                                                        Navigator.pop(context);
                                                        setState(() {});
                                                      } on FirebaseException catch (
                                                        e
                                                      ) {
                                                        setState(() {
                                                          errorMessage =
                                                              e.message ??
                                                              "There is an error while updating username";
                                                        });
                                                      }
                                                    },
                                                    child: Text("Okay"),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Cancel"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text("Update Username"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
