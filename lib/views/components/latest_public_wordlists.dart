import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';
import 'package:vocab_quiz/views/pages/public_wordlist_page.dart';

class LatestPublicListsWidget extends StatefulWidget {
  const LatestPublicListsWidget({super.key});

  @override
  State<LatestPublicListsWidget> createState() =>
      _LatestPublicListsWidgetState();
}

class _LatestPublicListsWidgetState extends State<LatestPublicListsWidget> {
  bool _loading = true;
  List<QueryDocumentSnapshot> _latestPublicWordlists = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestPublicWordLists();
  }

  Future<void> _fetchLatestPublicWordLists() async {
    try {
      final data = await firestore.value.getLatestPublicWordLists();
      if (mounted) {
        setState(() {
          _latestPublicWordlists = data;
          _loading = false;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Error while fetching public word lists",
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: "Public Word Lists"),
                        TextSpan(text: ":"),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _latestPublicWordlists.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = _latestPublicWordlists[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final vocabList = VocabList.fromMap(data);
                        final dateTime = vocabList.updatedAt.toDate();
                        final formattedDateTime =
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PracticePage(
                                  title: vocabList.title,
                                  wordlistID: doc.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vocabList.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  formattedDateTime,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicWordlistPage(),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text("See All"), Icon(Icons.more_horiz)],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
