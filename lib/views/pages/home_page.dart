import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/latest_public_wordlists.dart';
import 'package:vocab_quiz/views/components/my_saved_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _greetingName = "User";

  @override
  void initState() {
    super.initState();
    final user = firestore.value.user;
    _greetingName = (user?.displayName ?? user?.email) ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Hello $_greetingName"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 200, child: Text("My word list profolio")),
            LatestPublicListsWidget(),
            MySavedWidget(),
          ],
        ),
      ),
    );
  }
}
