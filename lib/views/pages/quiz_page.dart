import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/views/components/input_widget.dart';
import 'package:vocab_quiz/views/pages/home_page.dart';
import 'package:vocab_quiz/data/vocabList.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  TextEditingController vocab1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz", style: appBarFont),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return HomePage(title: "Vocab Quiz");
                  },
                ),
              );
            },
            icon: Icon(Icons.home_outlined),
          ),
        ],
        flexibleSpace: Image.asset(
          "assets/images/background1.png",
          fit: BoxFit.cover,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: adjList.length,
        itemBuilder: (BuildContext context, int index) {
          final item = adjList[index];
          return InputWidget(
            definition: item.definition,
            index: (index + 1).toString(),
          );
        },
      ),
    );
  }
}
