import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/pages/edit_wordList_page.dart';

// when edit button is clicked, go to "Edit Word List" page.  When finishing editing, refresh page
  void handleEdit({
    required BuildContext context,
    required VocabList data, 
    required String id,
    required VoidCallback refreshCallback
  }) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditWordListPage(vocabList: data, wordListID: id);
        },
      ),
    );
    if (shouldRefresh == true) {
      refreshCallback();
    }
  }