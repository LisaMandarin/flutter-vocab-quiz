import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class PublicWordlistWidget extends StatefulWidget {
  const PublicWordlistWidget({super.key});

  @override
  State<PublicWordlistWidget> createState() => _PublicWordlistWidgetState();
}

class _PublicWordlistWidgetState extends State<PublicWordlistWidget> {
  late Future<List<QueryDocumentSnapshot>> _futureLists;

  @override
  void initState() {
    super.initState();
    _futureLists = _fetchPublicWordlists();
  }

  Future<List<QueryDocumentSnapshot>> _fetchPublicWordlists() async {
    try {
      final docs = await firestore.value.getPublicWordLists();
      return docs;
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(context, e.message ?? "Error while public word lists");
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureLists,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Oops!  Please try again later."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No public word lists found"));
        }
        final docs = snapshot.data as List<QueryDocumentSnapshot>;
        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (BuildContext context, int index) {
            final rawData = docs[index].data() as Map<String, dynamic>;
            final vocabList = VocabList.fromMap(rawData);
            final dateTime = vocabList.updatedAt.toDate();
            final formattedDateTime =
                "${dateTime.day}/${dateTime.month}/${dateTime.year}";
            return Card(
              elevation: 10,
              child: ListTile(
                title: Row(
                  children: [
                    Text(vocabList.title),
                    SizedBox(width: 10),
                    Text(
                      vocabList.username,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  formattedDateTime,
                  style: TextStyle(fontSize: 10),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticePage(
                      title: vocabList.title,
                      wordlistID: docs[index].id,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
