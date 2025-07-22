import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/flipcard_widget.dart';
import 'package:vocab_quiz/views/components/hero_widget.dart';
import 'package:vocab_quiz/views/pages/quiz_page.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.title, required this.vocabList});

  final String title;
  final List<VocabItem> vocabList;
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Practice"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return QuizPage(vocabList: widget.vocabList);
              },
            ),
          );
        },
        backgroundColor: Color(0xFF171717),
        foregroundColor: Colors.white,
        child: Icon(Icons.edit),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              HeroWidget(title: widget.title),
              SizedBox(height: 20),
              ...widget.vocabList.map(
                (item) =>
                    FlipcardWidget(front: item.word, back: item.definition),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
