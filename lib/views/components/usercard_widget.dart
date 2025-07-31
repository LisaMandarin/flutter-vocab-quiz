import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';

class UsercardWidget extends StatefulWidget {
  final String email;
  final String? username;
  final TextEditingController controllerUsername;
  final String errorMessage;
  final VoidCallback refresh;

  const UsercardWidget({
    super.key,
    required this.email,
    required this.username,
    required this.controllerUsername,
    required this.errorMessage,
    required this.refresh,
  });

  @override
  State<UsercardWidget> createState() => _UsercardWidgetState();
}

class _UsercardWidgetState extends State<UsercardWidget> {
  Future<void> updateUsername() async {
    final newName = widget.controllerUsername.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("What's your username")));
      return;
    }
    try {
      if (widget.username == null) {
        await firestore.value.addUsername(newName);
      } else {
        await firestore.value.updateUsername(newName);
      }
      if (!context.mounted) return;
      Navigator.pop(context);
      widget.refresh();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "There is an error while updating username",
          ),
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User", style: cardStyle),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email_outlined),
                  Text(": ${widget.email}"),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.person_2_outlined),
                  Text(": ${widget.username ?? "(unknown)"}"),
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
                                controller: widget.controllerUsername,
                                decoration: InputDecoration(
                                  label: Text("Username"),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        await updateUsername();
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
    );
  }
}
