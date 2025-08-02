import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
