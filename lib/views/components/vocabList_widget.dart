import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/pages/addList_page.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class VocablistWidget extends StatefulWidget {
  const VocablistWidget({super.key});

  @override
  State<VocablistWidget> createState() => _VocablistWidgetState();
}

class _VocablistWidgetState extends State<VocablistWidget> {
  Future<List<QueryDocumentSnapshot>> fetchWordLists() async {
    final docs = await firestore.value.getMyWordLists();
    return docs;
  }

  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: fetchWordLists(),
          builder: (context, asyncSnapshot) {
            Widget widget = Container();
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              widget = const Center(child: CircularProgressIndicator());
            }
            if (asyncSnapshot.hasError) {
              widget = Center(
                child: Text(
                  asyncSnapshot.error.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            }
            if (asyncSnapshot.hasData) {
              final wordLists = asyncSnapshot.data;
              widget = SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("My Vocab Lists", style: cardStyle),
                    const SizedBox(height: 10),
                    if (wordLists!.isEmpty)
                      const Text("No word lists found.")
                    else
                      ...wordLists.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        String formattedDate = "No date";
                        if (data['createdAt'] != null &&
                            data['createdAt'] is Timestamp) {
                          final timestamp = data['createdAt'] as Timestamp;
                          final dateTime = timestamp.toDate();
                          formattedDate =
                              "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                        }
                        return ListTile(
                          title: Text(data['title'] ?? 'Untitled'),
                          subtitle: Text(
                            formattedDate,
                            style: TextStyle(fontSize: 10),
                          ),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PracticePage(
                                  title: "Practice",
                                  wordlistID: doc.id,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddListPage(refresh: refreshPage),
                              ),
                            );
                          },
                          child: Text("Add New List"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return widget;
          },
        ),
      ),
    );
  }
}
