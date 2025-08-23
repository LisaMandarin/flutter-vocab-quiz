import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/public_wordlist_widget.dart';

class PublicWordlistPage extends StatelessWidget {
  const PublicWordlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Public Word Lists"),
      body: PublicWordlistWidget(),
    );
  }
}
