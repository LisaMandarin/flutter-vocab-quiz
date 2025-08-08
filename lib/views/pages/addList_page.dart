import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/add_input_widget.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class AddListPage extends StatefulWidget {
  const AddListPage({super.key});

  @override
  State<AddListPage> createState() => _AddlistPageState();
}

class _AddlistPageState extends State<AddListPage> {
  final TextEditingController controllerTitle = TextEditingController();
  List<TextEditingController> words = [];
  List<TextEditingController> definitions = [];
  List<FocusNode> focusWords = [];
  List<FocusNode> focusDefinitions = [];
  List<Map<String, String>> list = [];
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    for (var c in words) {
      c.dispose();
    }
    for (var c in definitions) {
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

  @override
  void initState() {
    super.initState();
    addNew();
  }

  // initialize controllers for word and definition inputs in initial render or add button is clicked
  void addNew() {
    setState(() {
      words.add(TextEditingController());
      definitions.add(TextEditingController());
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());
    });
  }

  // delete a row of word and definition inputs when swiping left
  void removeRow(int index) {
    // Don't allow removal if only 2 or fewer items remain
    if (words.length <= 2) {
      return;
    }

    // bounds check for safety
    if (index < 0 || index >= words.length) {
      return;
    }

    setState(() {
      words[index].dispose();
      definitions[index].dispose();
      focusWords[index].dispose();
      focusDefinitions[index].dispose();
      words.removeAt(index);
      definitions.removeAt(index);
      focusWords.removeAt(index);
      focusDefinitions.removeAt(index);
    });
  }

  // validate controllers and turn them into list so as to add to list field of a document of word_lists on Firestore
  // return true or false to procceed in save()
  bool convertToList(
    List<TextEditingController> words,
    List<TextEditingController> definitions,
  ) {
    list.clear();
    for (var i = 0; i < words.length; i++) {
      String w = words[i].text.trim();
      String d = definitions[i].text.trim();
      if (w.isEmpty) {
        scrollController.animateTo(
          i * 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        focusWords[i].requestFocus();
        showErrorMessage(context, "Empty word not accepted");
        return false;
      }
      if (d.isEmpty) {
        scrollController.animateTo(
          i * 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        focusDefinitions[i].requestFocus();
        showErrorMessage(context, "Empty definition not accepted");
        return false;
      }

      list.add({"word": w, "definition": d});
    }
    return true;
  }

  // save a vocabulary word list in word_lists on Firestore
  // at least two rows of word and definition required
  Future<void> save() async {
    EasyLoading.show(status: "Saving...");
    if (controllerTitle.text.isEmpty) {
      showErrorMessage(context, "What is the title of the list?");
      await EasyLoading.dismiss();
      return;
    }
    if (!convertToList(words, definitions)) {
      EasyLoading.dismiss();
      return;
    }
    if (list.isEmpty) {
      await EasyLoading.dismiss();
      showErrorMessage(context, "No word or definition is stored");
      return;
    }
    if (list.length < 2) {
      await EasyLoading.dismiss();
      showErrorMessage(
        context,
        "You need at least 2 word-definition sets to save the word list",
      );
      return;
    }

    try {
      await firestore.value.addWordList(controllerTitle, list);

      await EasyLoading.dismiss();
      Future.delayed(Duration(milliseconds: 100));

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      await EasyLoading.dismiss();
      showErrorMessage(
        context,
        e.message ?? "Something went wrong while saving the list",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Add List"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // title input
            TextField(
              controller: controllerTitle,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10),

            // rows of word-definition inputs
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: min(words.length, definitions.length),
                itemBuilder: (context, index) {
                  // Only allow dismissing when more than 2 items exist (minimum 2 required)
                  bool isDismissible = words.length > 2;

                  // a card showing index, word input, definition input, and delete button
                  return AddInputWidget(
                    index: index,
                    controllerWord: words[index],
                    controllerDefinition: definitions[index],
                    focusWord: focusWords[index],
                    focusDefinition: focusDefinitions[index],
                    isDismissible: isDismissible,
                    onDismissed: () => removeRow(index),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    addNew();
                  },
                  icon: Icon(Icons.add_circle_outline, size: 40),
                ),
                IconButton(
                  onPressed: () async {
                    await save();
                  },
                  icon: Icon(Icons.save, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
