import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';
import 'package:vocab_quiz/views/pages/public_wordlist_page.dart';

class LatestPublicListsWidget extends StatefulWidget {
  const LatestPublicListsWidget({super.key, required this.callBack});
  final VoidCallback callBack;

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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Public Word Lists", style: homeTitleStyle),
          SizedBox(
            height: 140,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _latestPublicWordlists.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final data =
                          _latestPublicWordlists[index].data()
                              as Map<String, dynamic>;
                      final vocabList = VocabList.fromMap(data);
                      final dateTime = vocabList.updatedAt.toDate();
                      final formattedDateTime =
                          "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                      return SizedBox(
                        width: 240,
                        child: Card(
                          child: ListTile(
                            title: Text(
                              vocabList.title,
                              style: homeCardTitleStyle,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vocabList.username,
                                  style: homeCardSubtitleStyle,
                                ),
                                Text(
                                  formattedDateTime,
                                  style: homeCardSubtitleStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: Text("See All")),
              Icon(Icons.more_horiz),
            ],
          ),
        ],
      ),
    );
  }
}
