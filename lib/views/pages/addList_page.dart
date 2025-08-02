import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class AddListPage extends StatefulWidget {
  const AddListPage({super.key, required this.refresh});

  final VoidCallback refresh;

  @override
  State<AddListPage> createState() => _AddlistPageState();
}

class _AddlistPageState extends State<AddListPage> {
  final TextEditingController controllerTitle = TextEditingController();
  List<TextEditingController> words = [];
  List<TextEditingController> definitions = [];
  List<Map<String, String>> wordList = [];

  @override
  void dispose() {
    for (var c in words) {
      c.dispose();
    }
    for (var c in definitions) {
      c.dispose();
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
    });
  }

  void removeRow(int index) {
    setState(() {
      words[index].dispose();
      definitions[index].dispose();
      words.removeAt(index);
      definitions.removeAt(index);
    });
  }

  void convertToList(
    List<TextEditingController> words,
    List<TextEditingController> definitions,
  ) {
    wordList.clear();
    for (var i = 0; i < words.length; i++) {
      String w = words[i].text.trim();
      String d = definitions[i].text.trim();
      if (w.isNotEmpty && d.isNotEmpty) {
        wordList.add({"word": w, "definition": d});
      }
    }
  }

  Future<void> save() async {
    if (controllerTitle.text.isEmpty) {
      showErrorMessage(context, "What is the title of the list?");
      return;
    }

    convertToList(words, definitions);

    if (wordList.isEmpty) {
      showErrorMessage(context, "No word or definition is stored");
      return;
    }
    try {
      await firestore.value.addWordList(controllerTitle, wordList);
      Navigator.pop(context);
      widget.refresh();
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
                                    decoration: InputDecoration(
                                      labelText: "word",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: definitions[index],
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
