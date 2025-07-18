import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/hero_widget.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.title});

  final String title;
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          HeroWidget(title: widget.title),
          Text(widget.title),
        ],
      ),
    );
  }
}
