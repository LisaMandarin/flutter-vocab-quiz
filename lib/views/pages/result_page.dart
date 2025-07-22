import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.controllers,
    required this.vocabList,
  });

  final List<TextEditingController> controllers;
  final List<VocabItem> vocabList;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double calculateScore() {
    int correct = 0;
    int total = widget.vocabList.length;

    for (int i = 0; i < widget.controllers.length; i++) {
      String userInput = widget.controllers[i].text;
      String correctAnswer = widget.vocabList[i].word;
      if (userInput == correctAnswer) {
        correct++;
      }
    }
    return correct / total * 100;
  }

  @override
  Widget build(BuildContext context) {
    double score = calculateScore();

    return Scaffold(
      appBar: AppbarWidget(title: "Score"),
      body: ListView(
        children: [
          ...List.generate(
            widget.controllers.length,
            (index) => Text(widget.controllers[index].text),
          ),
          ...List.generate(
            widget.vocabList.length,
            (index) => ListTile(title: Text(widget.vocabList[index].word)),
          ),
          Text("Your score is ${score.toStringAsFixed(2)}%"),
        ],
      ),
    );
  }
}
