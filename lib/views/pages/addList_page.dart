import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
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
  List<Map<String, String>> wordList = [];
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

  void addNew() {
    setState(() {
      words.add(TextEditingController());
      definitions.add(TextEditingController());
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());
    });
  }

  void removeRow(int index) {
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

  bool convertToList(
    List<TextEditingController> words,
    List<TextEditingController> definitions,
  ) {
    wordList.clear();
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
      if (w.isNotEmpty && d.isNotEmpty) {
        wordList.add({"word": w, "definition": d});
      }
    }
    return true;
  }

  Future<void> save() async {
    if (controllerTitle.text.isEmpty) {
      showErrorMessage(context, "What is the title of the list?");
      return;
    }
    if (!convertToList(words, definitions)) {
      return;
    }
    if (wordList.isEmpty) {
      showErrorMessage(context, "No word or definition is stored");
      return;
    }
    if (wordList.length < 2) {
      showErrorMessage(
        context,
        "You need at least 2 word-definition sets to save the word list",
      );
      return;
    }

    try {
      await firestore.value.addWordList(controllerTitle, wordList);
      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
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
            TextField(
              controller: controllerTitle,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: min(words.length, definitions.length),
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(
                      "${words[index].hashCode}_${definitions[index].hashCode}",
                    ),
                    direction: words.length > 1
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Icon(Icons.delete_forever_outlined, size: 32),
                      ),
                    ),
                    onDismissed: (direction) {
                      removeRow(index);
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text((index + 1).toString()),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: words[index],
                                    focusNode: focusWords[index],
                                    decoration: InputDecoration(
                                      labelText: "word",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: definitions[index],
                                    focusNode: focusDefinitions[index],
                                    decoration: InputDecoration(
                                      labelText: "definition",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
