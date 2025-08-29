import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';

class HomeCollectionsCardWidget extends StatefulWidget {
  const HomeCollectionsCardWidget({super.key, required this.wordLists});
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> wordLists;

  @override
  State<HomeCollectionsCardWidget> createState() =>
      _HomeCollectionsCardWidgetState();
}

class _HomeCollectionsCardWidgetState extends State<HomeCollectionsCardWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.wordLists.isEmpty) {
      return SizedBox(
        height: 150,
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("You haven't stored any word lists yet"),
          ),
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        itemCount: widget.wordLists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final data = widget.wordLists[index].data();
          final stored = StoredPublicWordlist.fromMap(data);
          final dateTime = stored.storedAt.toDate();
          final formattedDateTime =
              "${dateTime.day}/${dateTime.month}/${dateTime.year}";

          return SizedBox(
            width: 240,
            child: Card(
              child: ListTile(
                title: Text(
                  stored.wordlistTitle,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Author: ${stored.wordlistOwnerName}",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "Saved Date: $formattedDateTime",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
