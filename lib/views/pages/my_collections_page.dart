import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/search_bar_widget.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class MyCollectionsPage extends StatefulWidget {
  const MyCollectionsPage({super.key, required this.storedWordLists});

  final List<QueryDocumentSnapshot> storedWordLists;

  @override
  State<MyCollectionsPage> createState() => _MyCollectionsPageState();
}

class _MyCollectionsPageState extends State<MyCollectionsPage> {
  TextEditingController controllerSearchText = TextEditingController();
  List<QueryDocumentSnapshot> _displayedWordLists = [];

  @override
  void initState() {
    _displayedWordLists = widget.storedWordLists;
    super.initState();
  }

  void onSearchSubmitted(List<QueryDocumentSnapshot> data, String query) {
    final queryText = query.trim().toLowerCase();
    final filtered = data.where((d) {
      return (d.data() as Map<String, dynamic>)['wordlistTitle']
          .toString()
          .toLowerCase()
          .contains(queryText);
    }).toList();
    setState(() {
      _displayedWordLists = filtered;
    });
  }

  void onSearchClose() {
    controllerSearchText.clear();
    setState(() {
      _displayedWordLists = widget.storedWordLists;
    });
  }

  @override
  void dispose() {
    controllerSearchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "My Collections"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SearchBarWidget(
              controllerSearchText: controllerSearchText,
              onSubmitted: () => onSearchSubmitted(
                widget.storedWordLists,
                controllerSearchText.text,
              ),
              onClosed: onSearchClose,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _displayedWordLists.length,
                itemBuilder: (BuildContext context, int index) {
                  final doc = StoredPublicWordlist.fromMap(
                    _displayedWordLists[index].data() as Map<String, dynamic>,
                  );
                  final dateTime = doc.storedAt.toDate();
                  final formattedDateTime =
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.my_library_books_outlined),
                      title: Text(
                        doc.wordlistTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Text(formattedDateTime),
                          SizedBox(width: 10),
                          Text(
                            "by ${doc.wordlistOwnerName}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticePage(
                            title: doc.wordlistTitle,
                            wordlistID: doc.wordlistId,
                          ),
                        ),
                      ),
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
