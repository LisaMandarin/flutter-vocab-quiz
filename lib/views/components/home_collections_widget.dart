import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/views/components/home_collections_card_widget.dart';
import 'package:vocab_quiz/views/pages/my_collections_page.dart';

class HomeCollectionsWidget extends StatefulWidget {
  const HomeCollectionsWidget({super.key, required this.storedWordlists});
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> storedWordlists;

  @override
  State<HomeCollectionsWidget> createState() => _HomeCollectionsWidgetState();
}

class _HomeCollectionsWidgetState extends State<HomeCollectionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: homeTitleStyle,
              children: [
                TextSpan(text: "My Collections"),
                TextSpan(text: "(${widget.storedWordlists.length})"),
                TextSpan(text: ":"),
              ],
            ),
          ),
          HomeCollectionsCardWidget(wordLists: widget.storedWordlists),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCollectionsPage()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text("See All"), Icon(Icons.more_horiz)],
            ),
          ),
        ],
      ),
    );
  }
}
