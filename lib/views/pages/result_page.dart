import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  // check if user inputs match the words in the vocab list and calculate the score
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
          Stack(
            alignment: Alignment(0, 0),
            children: [
              if (score == 100)
                Lottie.asset('assets/lotties/congratulations.json'),
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 15.0,
                percent: score / 100,
                header: Text(
                  score == 100 ? "Congratulations" : "",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
                ),
                center: Text("${score.toStringAsFixed(2)}%"),
                progressColor: score > 60 ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 10),
          ...List.generate(widget.vocabList.length, (index) {
            final userInput = widget.controllers[index].text.trim();
            final correctAnswer = widget.vocabList[index].word;
            final isCorrect = userInput == correctAnswer;

            return Card(
              child: ListTile(
                leading: Icon(
                  isCorrect ? Icons.check : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Your answer: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: userInput,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.black54 : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: isCorrect
                    ? null
                    : Text("Correct answer: $correctAnswer"),
              ),
            );
          }),
        ],
      ),
    );
  }
}
