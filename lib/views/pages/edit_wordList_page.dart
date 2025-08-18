import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/utils/dialog.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/edit_input_widget.dart';
import 'package:vocab_quiz/views/components/swtich_widget.dart';

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

  // tracks if user has made any changes to show unsaved changes dialog
  bool _hasUnsavedChanges = false;

  bool _isPublic = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    initializeControllers();
    _isPublic = widget.vocabList.isPublic;
    _isFavorite = widget.vocabList.isFavorite;
  }

  // initialize controllers with existing word list data and set up change listeners
  void initializeControllers() {
    // Set title and add listener for change detection
    controllerTitle.text = widget.vocabList.title;
    controllerTitle.addListener(_onFormChanged);

    // create controllers for each existing word-definition pair
    for (final item in widget.vocabList.list) {
      final wordController = TextEditingController(text: item.word);
      final definitionController = TextEditingController(text: item.definition);

      // add change listeners to track modifications
      wordController.addListener(_onFormChanged);
      definitionController.addListener(_onFormChanged);

      // add to lists for UI rendering
      controllerWords.add(wordController);
      controllerDefinitions.add(definitionController);
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());
    }
  }

  // called whenever any text field changes to track unsaved modifications
  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
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
    controllerTitle.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // convert controller values into a list of VocabItem objects for Firestore storage
  List<VocabItem> convertToList(
    List<TextEditingController> controllerWords,
    List<TextEditingController> controllerDefinitions,
  ) {
    // validates that word and definition controllers have matching lengths
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

  // update the word list document in Firestore with new title and word-definition pairs
  // returns true if successful, false if error occurred
  Future<bool> updateWordList(
    String id,
    String title,
    List<VocabItem> list,
    bool isPublic,
    bool isFavorite,
  ) async {
    try {
      if (id.isEmpty) {
        showErrorMessage(context, "Invalid word list ID");
        return false;
      }

      await firestore.value.updateWordList(
        id,
        title,
        list,
        isPublic,
        isFavorite,
      );

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

  // handle the update button press - validates inputs and saves to Firestore
  // perform input validation, scroll to first empty field if found,
  // convert data to VocabItem list, and call updateWordList
  Future<void> handleUpdate() async {
    EasyLoading.show(status: "Updating...");
    if (controllerTitle.text.trim().isEmpty) {
      await EasyLoading.dismiss();
      if (mounted) {
        showErrorMessage(context, "Empty title not accepted");
      }
      return;
    }

    // validate all word and definition pairs are filled
    for (int i = 0; i < controllerWords.length; i++) {
      if (controllerWords[i].text.trim().isEmpty) {
        // scroll to empty word field and focus it
        scrollController.animateTo(
          i * 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        focusWords[i].requestFocus();
        EasyLoading.dismiss();
        showErrorMessage(context, "Empty word not accepted");
        return;
      }

      if (controllerDefinitions[i].text.trim().isEmpty) {
        // scroll to empty definition field and focus it
        scrollController.animateTo(
          i * 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        focusDefinitions[i].requestFocus();
        EasyLoading.dismiss();
        showErrorMessage(context, "Empty definition not accepted");
        return;
      }
    }

    // all validation passed - convert to VocabItem list and save
    final list = convertToList(controllerWords, controllerDefinitions);
    final success = await updateWordList(
      widget.wordListID,
      controllerTitle.text.trim(),
      list,
      _isPublic,
      _isFavorite,
    );

    if (!mounted) return;

    if (success) {
      // mark as saved and return to previous page
      _hasUnsavedChanges = false;
      await EasyLoading.dismiss();
      Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        showSuccessMessage(context, "The word list has been updated");
        Navigator.pop(context, true);
      }
    }
  }

  // add a new empty word-definition pair to the list
  // creates new controllers and focus nodes with change listeners
  void addNew() {
    setState(() {
      final wordController = TextEditingController();
      final definitionController = TextEditingController();

      // Add change listeners to track modifications
      wordController.addListener(_onFormChanged);
      definitionController.addListener(_onFormChanged);

      // Add new controllers and focus nodes to the lists
      controllerWords.add(wordController);
      controllerDefinitions.add(definitionController);
      focusWords.add(FocusNode());
      focusDefinitions.add(FocusNode());

      // Mark as having unsaved changes
      _hasUnsavedChanges = true;
    });
  }

  // remove a word-definition pair at the specified index
  // ensure minimum of 2 items remain and properly dispose resources
  void removeItem(int index) {
    // Don't allow removal if only 2 or fewer items remain
    if (controllerWords.length <= 2) {
      return;
    }

    setState(() {
      controllerWords[index].dispose();
      controllerDefinitions[index].dispose();
      focusWords[index].dispose();
      focusDefinitions[index].dispose();

      // Remove from all lists at the specified index
      controllerWords.removeAt(index);
      controllerDefinitions.removeAt(index);
      focusWords.removeAt(index);
      focusDefinitions.removeAt(index);

      // Mark as having unsaved changes
      _hasUnsavedChanges = true;
    });
  }

  // show confirmation dialog when user tries to exit with unsaved changes
  // uses the app's standard popupDialog for consistent UI
  void _showExitConfirmationDialog() {
    print(_hasUnsavedChanges);
    // If no changes were made, exit immediately
    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    // show confirmation dialog
    popupDialog(
      context,
      "You have unsaved changes. Are you sure you want to leave without saving?",
      () => Navigator.pop(context), // Callback when user confirms exit
      title: "Unsaved Changes",
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // prevent automatic popping to show confirmation dialog
      canPop: false,

      // handle back button/gesture with unsaved changes confirmation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmationDialog();
      },
      child: Scaffold(
        appBar: AppbarWidget(title: "Edit Word List"),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // word list setting: favorite and public
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SwitchWidget(
                      name: "Public",
                      value: _isPublic,
                      onChange: (val) {
                        setState(() {
                          if (_isPublic == val) return;
                          _isPublic = val;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SwitchWidget(
                      name: "Favorite",
                      value: _isFavorite,
                      onChange: (val) {
                        setState(() {
                          if (_isFavorite == val) return;
                          _isFavorite = val;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              // Title input field
              TextField(
                controller: controllerTitle,
                decoration: InputDecoration(labelText: "Title"),
              ),
              SizedBox(height: 10),

              // Scrollable list of word-definition input pairs
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
                      // Allow dismissing only when more than 2 items exist
                      isDismissible: controllerWords.length > 2,
                      // Handle item removal by swiping
                      onDismissed: () {
                        // Use the current index from the closure
                        removeItem(index);
                      },
                    );
                  },
                ),
              ),

              // Action buttons: Add new item and Save
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Add new word-definition pair button
                  IconButton(
                    onPressed: () {
                      addNew();
                    },
                    icon: Icon(Icons.add_circle_outlined, size: 40),
                  ),
                  // Save changes button
                  IconButton(
                    onPressed: handleUpdate,
                    icon: Icon(Icons.save, size: 40),
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
