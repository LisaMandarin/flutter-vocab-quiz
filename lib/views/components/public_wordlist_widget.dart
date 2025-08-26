import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/search_bar_widget.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class PublicWordlistWidget extends StatefulWidget {
  const PublicWordlistWidget({super.key});

  @override
  State<PublicWordlistWidget> createState() => _PublicWordlistWidgetState();
}

class _PublicWordlistWidgetState extends State<PublicWordlistWidget> {
  User? currentUser = authService.value.currentUser;
  TextEditingController controllerSearchText = TextEditingController();
  List<QueryDocumentSnapshot> _originalData = [];
  List<QueryDocumentSnapshot> _displayedData = [];
  Set<String> _storedWordlistIds = {};
  bool _loading = true;

  // fetch public word lists and stored word lists
  @override
  void initState() {
    super.initState();
    _fetchPublicWordlists();
  }

  @override
  void dispose() {
    controllerSearchText.dispose();
    super.dispose();
  }

  // after fetching, set data in _originalData and _displayedData
  // update _loading state
  // store stored word list IDs.
  // When star icon is clicked, update _storedWordlistIds
  Future<void> _fetchPublicWordlists() async {
    try {
      final results = await Future.wait([
        firestore.value.getPublicWordLists(),
        firestore.value.getStoredPublicWordlistsByUser(currentUser!.uid),
      ]);
      final publicWordlists = results[0];
      final storedWordlists = results[1];

      final storedWordlistsIds = storedWordlists
          .map(
            (stored) =>
                (stored.data() as Map<String, dynamic>)['wordlistId'] as String,
          )
          .toSet();

      setState(() {
        _originalData = publicWordlists;
        _displayedData = List.from(_originalData);
        _storedWordlistIds = storedWordlistsIds;
        _loading = false;
      });
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(context, e.message ?? "Error while public word lists");
      }
      setState(() {
        _loading = false;
      });
    }
  }

  void onSearchSubmitted(List<QueryDocumentSnapshot> data, String query) {
    final queryText = query.trim().toLowerCase();
    final filtered = data.where((d) {
      final docData = d.data() as Map<String, dynamic>;
      final title = docData['title'].toString().toLowerCase();
      return title.contains(queryText);
    }).toList();
    setState(() {
      _displayedData = filtered;
    });
  }

  // clear search text and reset displayed data to original data
  void onSearchClose() {
    controllerSearchText.clear();
    setState(() {
      _displayedData = List.from(_originalData);
    });
  }

  // store public word list in stored_public_wordlists
  Future<void> _storeList(
    String wordlistId,
    String wordlistTitle,
    String wordlistOwnerId,
    String wordlistOwnerName,
    String userId,
    String userName,
  ) async {
    try {
      await firestore.value.storePublicWordlist(
        wordlistId,
        wordlistTitle,
        wordlistOwnerId,
        wordlistOwnerName,
        userId,
        userName,
      );
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(context, e.message ?? "Error while storing word list");
      }
    }
  }

  // delete public word list from stored_public_wordlists
  Future<void> _unstoreList(String id) async {
    try {
      await firestore.value.deleteStoredPublicWordlist(id);
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Error while unstoring word list",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (_displayedData.isEmpty) {
        return Center(child: Text("No public word lists found"));
      } else {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SearchBarWidget(
                controllerSearchText: controllerSearchText,
                onSubmitted: () =>
                    onSearchSubmitted(_originalData, controllerSearchText.text),
                onClosed: onSearchClose,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final doc = _displayedData[index];
                    final vocabList = VocabList.fromMap(
                      doc.data() as Map<String, dynamic>,
                    );
                    final dateTime = vocabList.updatedAt.toDate();
                    final formattedDateTime =
                        "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                    return Card(
                      child: ListTile(
                        title: Text(
                          vocabList.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Text(formattedDateTime),
                            SizedBox(width: 10),
                            Text(vocabList.username),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            if (currentUser == null) return;
                            final isStored = _storedWordlistIds.contains(
                              doc.id,
                            );
                            if (isStored) {
                              final savedId = '${currentUser!.uid}_${doc.id}';
                              await _unstoreList(savedId);
                              setState(() {
                                _storedWordlistIds.remove(doc.id);
                              });
                            } else {
                              await _storeList(
                                doc.id,
                                vocabList.title,
                                vocabList.ownerId,
                                vocabList.username,
                                currentUser!.uid,
                                currentUser!.displayName ?? "",
                              );
                              setState(() {
                                _storedWordlistIds.add(doc.id);
                              });
                            }
                          },
                          icon: Icon(
                            _storedWordlistIds.contains(doc.id)
                                ? Icons.star
                                : Icons.star_border,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePage(
                              title: vocabList.title,
                              wordlistID: doc.id,
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
        );
      }
    }
  }
}
