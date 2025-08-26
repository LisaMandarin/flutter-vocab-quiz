import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/dialog.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/search_bar_widget.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';

class MyCollectionsPage extends StatefulWidget {
  const MyCollectionsPage({super.key});

  @override
  State<MyCollectionsPage> createState() => _MyCollectionsPageState();
}

class _MyCollectionsPageState extends State<MyCollectionsPage> {
  final user = authService.value.currentUser;
  late List<QueryDocumentSnapshot> _originalData;
  TextEditingController controllerSearchText = TextEditingController();
  List<QueryDocumentSnapshot> _displayedData = [];
  bool _loading = true;

  @override
  void initState() {
    _fetchStoredWordLists();
    super.initState();
  }

  Future<void> _fetchStoredWordLists() async {
    try {
      if (user == null) return;
      final snapshot = await firestore.value.getStoredPublicWordlistsByUser(
        user!.uid,
      );
      setState(() {
        _originalData = snapshot;
        _displayedData = _originalData;
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

  void onSearchSubmitted(List<QueryDocumentSnapshot> data, String query) {
    final queryText = query.trim().toLowerCase();
    final filtered = data.where((d) {
      return (d.data() as Map<String, dynamic>)['wordlistTitle']
          .toString()
          .toLowerCase()
          .contains(queryText);
    }).toList();
    setState(() {
      _displayedData = filtered;
    });
  }

  void onSearchClose() {
    controllerSearchText.clear();
    setState(() {
      _displayedData = _originalData;
    });
  }

  void _unStoreList(String id) async {
    try {
      await firestore.value.deleteStoredPublicWordlist(id);

      // re-fetch data
      await _fetchStoredWordLists();
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ??
              "Error while deleting the word list from your collections",
        );
      }
    }
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
              onSubmitted: () =>
                  onSearchSubmitted(_originalData, controllerSearchText.text),
              onClosed: onSearchClose,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _displayedData.length,
                itemBuilder: (BuildContext context, int index) {
                  final doc = StoredPublicWordlist.fromMap(
                    _displayedData[index].data() as Map<String, dynamic>,
                  );
                  final dateTime = doc.storedAt.toDate();
                  final formattedDateTime =
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                  return Slidable(
                    key: ValueKey(doc.wordlistId),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      extentRatio: .30,
                      children: [
                        SlidableAction(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          label: 'Delete',
                          onPressed: (context) {
                            popupDialog(
                              context,
                              "Are you sure to delete ${doc.wordlistTitle} from your collections?",
                              () {
                                _unStoreList(_displayedData[index].id);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    child: Card(
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
