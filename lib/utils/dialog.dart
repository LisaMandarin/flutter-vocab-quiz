import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';

void popupDialog(
  BuildContext context,
  String message,
  VoidCallback onYes, {
  String title = "",
  IconData icon_yes = Icons.check,
  IconData icon_no = Icons.close,
}) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(message, style: cardStyle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      onYes();
                    },
                    icon: Icon(icon_yes, color: Colors.green),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(icon_no, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
