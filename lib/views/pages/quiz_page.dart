import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/input_widget.dart';
import 'package:vocab_quiz/views/pages/result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.wordlistID});
  final String wordlistID;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  VocabList? _vocabList;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  ScrollController scrollController = ScrollController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData(widget.wordlistID);
  }

  Future<void> _loadData(String id) async {
    try {
      final data = await firestore.value.getWordList(id);
      if (data != null) {
        final vocabList = VocabList.fromMap(
          data.data() as Map<String, dynamic>,
        );
        _controllers = List.generate(
          vocabList.list.length,
          (index) => TextEditingController(),
        );

        _focusNodes = List.generate(
          vocabList.list.length,
          (index) => FocusNode(),
        );

        setState(() {
          _vocabList = vocabList;
          _loading = false;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(context, e.message ?? "Error!");
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Quiz"),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              controller: scrollController,
              padding: EdgeInsets.all(20),
              children: [
                Center(child: Text(_vocabList!.title, style: titleStyle)),
                ...List.generate(
                  _vocabList!.list.length,
                  (index) => InputWidget(
                    definition: _vocabList!.list[index].definition,
                    index: (index + 1).toString(),
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color((0xFF171717)),
                  ),
                  //inputs validation.  Check if the inputs are empty.  Scroll to the first empty input and show the erro message when the button is clicked.  If all inputs pass the validation, direct to result page.
                  onPressed: () async {
                    EasyLoading.show(status: "Please wait...");
                    for (int i = 0; i < _vocabList!.list.length; i++) {
                      if (_controllers[i].text.trim().isEmpty) {
                        scrollController.animateTo(
                          i * 100,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        _focusNodes[i].requestFocus();
                        await EasyLoading.dismiss();
                        showErrorMessage(context, "Empty answer not accepted");
                        return;
                      }
                    }
                    EasyLoading.dismiss();
                    Future.delayed(Duration(milliseconds: 100));

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ResultPage(
                            controllers: _controllers,
                            wordlistID: widget.wordlistID,
                          );
                        },
                      ),
                    );
                  },
                  child: Text("See Score"),
                ),
                SizedBox(height: 20),
              ],
            ),
    );
  }
}
