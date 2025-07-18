import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/views/components/hero_widget.dart';

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
      appBar: AppBar(
        title: Text(widget.title, style: appBarFont),
        flexibleSpace: Image.asset(
          "assets/images/background.png",
          fit: BoxFit.cover,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            HeroWidget(title: widget.title),
            SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                itemCount: widget.vocabList.length,
                itemBuilder: (context, index) {
                  final item = widget.vocabList[index];
                  return Card(
                    color: Color(0xffc7c7c7),
                    child: Column(
                      children: [Text(item.word), Text(item.definition)],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
