import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/pages/my_collections_page.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class MySavedWidget extends StatefulWidget {
  const MySavedWidget({super.key});

  @override
  State<MySavedWidget> createState() => _MySavedWidgetState();
}

class _MySavedWidgetState extends State<MySavedWidget> {
  late List<QueryDocumentSnapshot> _storedPublicWordlists;
  QueryDocumentSnapshot? _latestStoredWordlist;
  final _user = authService.value.currentUser;
  bool _loading = true;

  @override
  void initState() {
    _fetchStoredPublicWordlists();
    super.initState();
  }

  Future<void> _fetchStoredPublicWordlists() async {
    try {
      final data = await firestore.value.getStoredPublicWordlistsByUser(
        _user!.uid,
      );
      setState(() {
        _storedPublicWordlists = data;
        _latestStoredWordlist = data.isNotEmpty ? data[0] : null;
        _loading = false;
      });
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Error while fetching stored public word lists",
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: _loading
            ? Center(child: CircularProgressIndicator())
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
                        TextSpan(text: "My Collections"),
                        TextSpan(text: "(${_storedPublicWordlists.length})"),
                        TextSpan(text: ":"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticePage(
                            title:
                                "${_latestStoredWordlist != null ? (_latestStoredWordlist!.data() as Map<String, dynamic>)['wordlistTitle'] : "Unknown Title"}",
                            wordlistID:
                                "${(_latestStoredWordlist!.data() as Map<String, dynamic>)['wordlistId']}",
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${_latestStoredWordlist != null ? (_latestStoredWordlist!.data() as Map<String, dynamic>)['wordlistTitle'] : "(Unknown Title)"}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "(${_latestStoredWordlist != null ? (_latestStoredWordlist!.data() as Map<String, dynamic>)['wordlistOwnerName'] : "(Unknown Owner)"})",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyCollectionsPage(),
                        ),
                      );
                      // Refresh data when returning from MyCollectionsPage
                      _fetchStoredPublicWordlists();
                    },
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
