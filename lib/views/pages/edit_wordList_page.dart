import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/edit_input_widget.dart';

class EditWordListPage extends StatefulWidget {
  const EditWordListPage({
    super.key,
    required this.vocabList,
    required this.wordListID,
  });
  final VocabList vocabList;
  final String wordListID;

  @override
  State<EditWordListPage> createState() => _EditWordListPageState();
}

class _EditWordListPageState extends State<EditWordListPage> {
  TextEditingController controllerTitle = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<TextEditingController> controllerWords = [];
  List<TextEditingController> controllerDefinitions = [];
  List<FocusNode> focusWords = [];
  List<FocusNode> focusDefinitions = [];

  @override
  void initState() {
    super.initState();
    generateInputValues();
  }

  void generateInputValues() async {
    controllerTitle.text = widget.vocabList.title;
    final vocabList = widget.vocabList.wordList;
    if (vocabList.isNotEmpty) {
      for (var i = 0; i < vocabList.length; i++) {
        final TextEditingController controllerW = TextEditingController();
        final TextEditingController controllerD = TextEditingController();
        final focusW = FocusNode();
        final focusD = FocusNode();
        controllerW.text = vocabList[i].word;
        controllerD.text = vocabList[i].definition;
        controllerWords.add(controllerW);
        controllerDefinitions.add(controllerD);
        focusWords.add(focusW);
        focusDefinitions.add(focusD);
      }
    }
  }

  @override
  void dispose() {
    for (var c in controllerWords) {
      c.dispose();
    }
    for (var c in controllerDefinitions) {
      c.dispose();
    }
    for (var f in focusWords) {
      f.dispose();
    }
    for (var f in focusDefinitions) {
      f.dispose();
    }
    super.dispose();
  }

  List<Map<String, String>> convertToWordList(
    List<TextEditingController> controllerWords,
    List<TextEditingController> controllerDefinitions,
  ) {
    final List<Map<String, String>> wordList = [];
    for (int i = 0; i < controllerWords.length; i++) {
      final vocabItem = {
        "word": controllerWords[i].text.trim(),
        "definition": controllerDefinitions[i].text.trim(),
      };
      wordList.add(vocabItem);
    }
    return wordList;
  }

  Future<bool> updateWordList(
    String id,
    String title,
    List<Map<String, String>> wordList,
  ) async {
    try {
      if (id.isEmpty) {
        showErrorMessage(context, "Invalid word list ID");
        return false;
      }
      await firestore.value.updateWordList(id, title, wordList);
      return true;
    } on FirebaseException catch (e) {
      showErrorMessage(context, e.message ?? "Error while updating word list");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Edit Word List"),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(20),
        children: [
          Center(child: TextField(controller: controllerTitle)),
          ...List.generate(
            widget.vocabList.wordList.length,
            (index) => EditInputWidget(
              index: (index + 1).toString(),
              controllerWord: controllerWords[index],
              controllerDefinition: controllerDefinitions[index],
              focusWord: focusWords[index],
              focusDefinition: focusDefinitions[index],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Color((0xFF171717))),
            //inputs validation.  Check if the inputs are empty.  Scroll to the first empty input and show the erro message when the button is clicked.  If all inputs pass the validation, direct to result page.
            onPressed: () async {
              if (controllerTitle.text.trim().isEmpty) {
                showErrorMessage(context, "Empty title not accepted");
                return;
              }
              for (int i = 0; i < widget.vocabList.wordList.length; i++) {
                if (controllerWords[i].text.trim().isEmpty) {
                  scrollController.animateTo(
                    i * 100,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  focusWords[i].requestFocus();
                  showErrorMessage(context, "Empty word not accepted");
                  return;
                }
                if (controllerDefinitions[i].text.trim().isEmpty) {
                  scrollController.animateTo(
                    i * 100,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  focusDefinitions[i].requestFocus();
                  showErrorMessage(context, "Empty definition not accepted");
                  return;
                }
              }
              final wordList = convertToWordList(
                controllerWords,
                controllerDefinitions,
              );
              final success = await updateWordList(
                widget.wordListID,
                controllerTitle.text.trim(),
                wordList,
              );
              if (success && context.mounted) {
                showSuccessMessage(context, "The word list has been updated");
                Navigator.pop(context, true);
              }
            },
            child: Text("Update Word List"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
