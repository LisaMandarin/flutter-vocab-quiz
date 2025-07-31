import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class AddListPage extends StatefulWidget {
  const AddListPage({super.key});

  @override
  State<AddListPage> createState() => _AddlistPageState();
}

class _AddlistPageState extends State<AddListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Add List"),
      body: Center(child: Text("Add List"),)
    );
  }
}