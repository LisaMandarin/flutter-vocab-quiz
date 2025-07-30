import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Setting"),
      body: Text("Setting"),
    );
  }
}
