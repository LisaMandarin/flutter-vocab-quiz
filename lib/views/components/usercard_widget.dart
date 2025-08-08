import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';

class UsercardWidget extends StatefulWidget {
  final String email;
  final String? username;
  final String errorMessage;
  final VoidCallback refresh;

  const UsercardWidget({
    super.key,
    required this.email,
    required this.username,
    required this.errorMessage,
    required this.refresh,
  });

  @override
  State<UsercardWidget> createState() => _UsercardWidgetState();
}

class _UsercardWidgetState extends State<UsercardWidget> {
  final TextEditingController controllerUsername = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeUsername(widget.username);
  }

  @override
  void dispose() {
    controllerUsername.dispose();
    super.dispose();
  }

  //initialize username controller
  void initializeUsername(String? username) {
    controllerUsername.text = username ?? "";
  }

  // update username when Okay icon in alert dialog is clicked
  Future<void> _updateUsername() async {
    EasyLoading.show(status: "Updating...");
    final newName = controllerUsername.text.trim();
    if (newName.isEmpty) {
      showErrorMessage(context, "What's your username");
      await EasyLoading.dismiss();
      return;
    }
    try {
      if (widget.username == null) {
        await firestore.value.addUsername(newName);
      } else {
        await firestore.value.updateUsername(newName);
      }
      await EasyLoading.dismiss();
      Future.delayed(Duration(milliseconds: 100));
      if (context.mounted) {
        Navigator.pop(context);

        widget.refresh();
      }
    } on FirebaseException catch (e) {
      await EasyLoading.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? "There is an error while updating username",
            ),
          ),
        );
      }
    }
    return;
  }

  // show dialog when update username button is clicked
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // username input in pop-up dialog
            TextField(
              controller: controllerUsername,
              decoration: InputDecoration(label: Text("Username")),
            ),
            // action buttons in pop-up dialog: okay and cancel
            Row(
              children: [
                // okay button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await _updateUsername();
                    },
                    icon: const Icon(Icons.check, color: Colors.green),
                    label: const Text(
                      'Okay',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // cancel button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      controllerUsername.text = widget.username ?? "";
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: Colors.grey),
                    label: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              // Card title
              Text("User", style: cardStyle),
              SizedBox(height: 10),

              // email
              Row(
                children: [
                  Icon(Icons.email_outlined),
                  Text(": ${widget.email}"),
                ],
              ),

              // username
              Row(
                children: [
                  Icon(Icons.person_2_outlined),
                  Text(": ${widget.username ?? "(unknown)"}"),
                ],
              ),

              // update username button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    // show pop-up dialog when update username button is clicked
                    onPressed: _showUpdateDialog,
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
