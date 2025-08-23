import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
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
  TextEditingController controllerSearchText = TextEditingController();
  List<QueryDocumentSnapshot> _originalData = [];
  List<QueryDocumentSnapshot> _displayedData = [];
  bool _loading = true;

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

  Future<void> _fetchPublicWordlists() async {
    try {
      final docs = await firestore.value.getPublicWordLists();
      setState(() {
        _originalData = docs;
        _displayedData = List.from(_originalData);
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

  void onSearchClose() {
    controllerSearchText.clear();
    setState(() {
      _displayedData = List.from(_originalData);
    });
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
                        title: Row(
                          children: [
                            Text(vocabList.title),
                            SizedBox(width: 10),
                            Text(
                              vocabList.username,
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        subtitle: Text(formattedDateTime),
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
