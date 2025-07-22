import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/input_widget.dart';
import 'package:vocab_quiz/views/pages/result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.vocabList});
  final List<VocabItem> vocabList;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.vocabList.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Quiz"),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ...List.generate(
            widget.vocabList.length,
            (index) => InputWidget(
              definition: widget.vocabList[index].definition,
              index: (index + 1).toString(),
              controller: _controllers[index],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Color((0xFF171717))),
            onPressed: () {
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
          ...List.generate(
            widget.vocabList.length,
            (index) => Text(_controllers[index].text),
          ),
        ],
      ),
    );
  }
}
