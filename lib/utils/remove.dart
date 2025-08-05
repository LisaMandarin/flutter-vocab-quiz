import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';

void removeList({
  required BuildContext context,
  required String? id,
  required String title,
  required VoidCallback refreshPage,
}) async {
  if (id == null) {
    if (context.mounted) {
      showErrorMessage(context, "Error while deleting the word list");
    }
    return;
  }
  try {
    await firestore.value.deleteWordList(id);
    refreshPage();
    if (context.mounted) {
      showSuccessMessage(context, "You have deleted $title");
    }
  } on FirebaseException catch (e) {
    if (context.mounted) {
      showErrorMessage(
        context,
        e.message ?? "Error while deleting the word list",
      );
    }
  }
}
