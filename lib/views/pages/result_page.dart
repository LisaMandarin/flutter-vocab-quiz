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
  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
