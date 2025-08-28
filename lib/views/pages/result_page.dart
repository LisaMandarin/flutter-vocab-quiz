import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.controllers,
    required this.wordlistID,
  });

  final List<TextEditingController> controllers;
  final String wordlistID;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double _score = 0;
  User? user = authService.value.currentUser;
  VocabList? _vocabList;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // get the word list title and word-definition pairs and other information
  void fetchData() async {
    try {
      final data = await firestore.value.getWordList(widget.wordlistID);
      if (data != null) {
        setState(() {
          _vocabList = VocabList.fromMap(data.data() as Map<String, dynamic>);
          calculateScore(_vocabList!.list);
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(context, e.message ?? "");
      }
    }
  }

  // check if user inputs match the words in the vocab list and calculate the score
  void calculateScore(List<VocabItem> vocabList) {
    int correct = 0;
    int total = vocabList.length;

    for (int i = 0; i < widget.controllers.length; i++) {
      String userInput = widget.controllers[i].text;
      String correctAnswer = vocabList[i].word;
      if (userInput == correctAnswer) {
        correct++;
      }
    }
    _score = correct / total * 100;
  }

  Future<void> saveScore(
    String userID,
    String wordlistID,
    String wordlistTitle,
    double score,
  ) async {
    try {
      await firestore.value.saveScore(
        userID,
        user?.displayName ?? "unknown user",
        wordlistID,
        wordlistTitle,
        score,
      );
      print('clicked');
      showSuccessMessage(context, "Score saved");
    } on FirebaseException catch (e) {
      print(e.message);
      if (mounted) {
        showErrorMessage(context, e.message ?? "Error while saving score");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Score"),
      body: Column(
        children: [
          Stack(
            alignment: Alignment(0, 0),
            children: [
              if (_score == 100)
                Lottie.asset('assets/lotties/congratulations.json'),
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 15.0,
                percent: _score / 100,
                header: Text(
                  _score == 100 ? "Congratulations" : "",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
                ),
                center: Text("${_score.toStringAsFixed(2)}%"),
                progressColor: _score > 60 ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _vocabList == null
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      ...List.generate(_vocabList!.list.length, (index) {
                        final userInput = widget.controllers[index].text.trim();
                        final correctAnswer = _vocabList!.list[index].word;
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
                                      color: isCorrect
                                          ? Colors.black54
                                          : Colors.red,
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
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        child: SafeArea(
          top: false,
          child: TextButton(
            onPressed: () async {
              if (user != null && _vocabList != null) {
                await saveScore(
                  user!.uid,
                  widget.wordlistID,
                  _vocabList!.title,
                  _score,
                );
              }
            },
            child: Text(
              "Save Score",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
