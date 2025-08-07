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
    initializeControllers();
  }

  // give controllers values in initial render
  void initializeControllers() {
    controllerTitle.text = widget.vocabList.title;
    for (final item in widget.vocabList.list) {
      controllerWords.add(TextEditingController(text: item.word));
      controllerDefinitions.add(TextEditingController(text: item.definition));
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());
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

  // turn input values into list so as to update list field of the document in word_lists on Firestore
  List<VocabItem> convertToList(
    List<TextEditingController> controllerWords,
    List<TextEditingController> controllerDefinitions,
  ) {
    if (controllerWords.length != controllerDefinitions.length) {
      throw Exception(
        "The number of words are not the same as the number of definitions",
      );
    }
    final List<VocabItem> list = [];
    for (int i = 0; i < controllerWords.length; i++) {
      final vocabItem = VocabItem(
        word: controllerWords[i].text.trim(),
        definition: controllerDefinitions[i].text.trim(),
      );
      list.add(vocabItem);
    }
    return list;
  }

  // update document of word_lists on Firestore: title/list/username/createdAt
  Future<bool> updateWordList(
    String id,
    String title,
    List<VocabItem> list,
  ) async {
    try {
      if (id.isEmpty) {
        showErrorMessage(context, "Invalid word list ID");
        return false;
      }
      await firestore.value.updateWordList(id, title, list);
      return true;
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Error while updating word list",
        );
      }
      return false;
    }
  }

  //inputs validation.  Check if the inputs are empty.
  //Scroll to the first empty input and show the erro message when the Update Word List button is clicked.
  //If all inputs pass the validation, direct to result page.
  Future<void> handleUpdate() async {
    if (controllerTitle.text.trim().isEmpty) {
      showErrorMessage(context, "Empty title not accepted");
      return;
    }
    for (int i = 0; i < controllerWords.length; i++) {
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
    final list = convertToList(controllerWords, controllerDefinitions);
    final success = await updateWordList(
      widget.wordListID,
      controllerTitle.text.trim(),
      list,
    );
    if (!mounted) return;

    if (success) {
      showSuccessMessage(context, "The word list has been updated");
      Navigator.pop(context, true);
    }
  }

  void addNew() {
    setState(() {
      controllerWords.add(TextEditingController());
      controllerDefinitions.add(TextEditingController());
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());
    });
  }

  void removeItem(int index) {
    if (controllerWords.length <= 2) return; // Don't allow removal if only 2 or fewer items
    
    setState(() {
      controllerWords[index].dispose();
      controllerDefinitions[index].dispose();
      focusWords[index].dispose();
      focusDefinitions[index].dispose();
      
      controllerWords.removeAt(index);
      controllerDefinitions.removeAt(index);
      focusWords.removeAt(index);
      focusDefinitions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Edit Word List"),
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
                itemCount: controllerWords.length,
                itemBuilder: (BuildContext context, int index) {
                  return EditInputWidget(
                    id: "edit_item_$index",
                    index: (index + 1).toString(),
                    controllerWord: controllerWords[index],
                    controllerDefinition: controllerDefinitions[index],
                    focusWord: focusWords[index],
                    focusDefinition: focusDefinitions[index],
                    isDismissible: controllerWords.length > 2,
                    onDismissed: () => removeItem(index),
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
                  icon: Icon(Icons.add_circle_outlined, size: 40),
                ),
                IconButton(
                  onPressed: handleUpdate,
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
