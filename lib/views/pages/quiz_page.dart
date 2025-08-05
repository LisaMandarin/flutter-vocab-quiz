import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/input_widget.dart';
import 'package:vocab_quiz/views/pages/result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.vocabList, required this.title});
  final List<VocabItem> vocabList;
  final String title;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<TextEditingController> _controllers = [];
  late List<FocusNode> _focusNodes = [];
  late ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.vocabList.length,
      (index) => TextEditingController(),
    );

    _focusNodes = List.generate(
      widget.vocabList.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Quiz"),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(20),
        children: [
          Center(child: Text(widget.title, style: titleStyle)),
          ...List.generate(
            widget.vocabList.length,
            (index) => InputWidget(
              definition: widget.vocabList[index].definition,
              index: (index + 1).toString(),
              controller: _controllers[index],
              focusNode: _focusNodes[index],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Color((0xFF171717))),
            //inputs validation.  Check if the inputs are empty.  Scroll to the first empty input and show the erro message when the button is clicked.  If all inputs pass the validation, direct to result page.
            onPressed: () {
              for (int i = 0; i < widget.vocabList.length; i++) {
                if (_controllers[i].text.trim().isEmpty) {
                  scrollController.animateTo(
                    i * 100,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  _focusNodes[i].requestFocus();
                  showErrorMessage(context, "Empty answer(s) not accepted");
                  return;
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ResultPage(
                      controllers: _controllers,
                      vocabList: widget.vocabList,
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
