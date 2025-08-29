import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/latest_public_wordlists.dart';
import 'package:vocab_quiz/views/components/home_collections_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _greetingName = "";
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _collections = [];

  @override
  void initState() {
    super.initState();
    _greetingName = widget.user.displayName ?? widget.user.email ?? "User";
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    try {
      final data = await firestore.value.getStoredPublicWordlistsByUser(
        widget.user.uid,
      );
      if (!mounted) return;
      setState(() {
        _collections = data.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
      });
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Error while fetching collections",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Hello $_greetingName"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 200, child: Text("My word list profolio")),
              LatestPublicListsWidget(callBack: fetchCollections),
              HomeCollectionsWidget(storedWordlists: _collections),
            ],
          ),
        ),
      ),
    );
  }
}
