import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/dialog.dart';
import 'package:vocab_quiz/utils/edit.dart';
import 'package:vocab_quiz/utils/remove.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class WordlistsPage extends StatefulWidget {
  const WordlistsPage({super.key});

  @override
  State<WordlistsPage> createState() => _WordlistsPageState();
}

class _WordlistsPageState extends State<WordlistsPage> {
  // refresh page after removing a word list
  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "My Word Lists"),
      body: Container(
        padding: EdgeInsets.all(20),
        // get current user's word lists to build widget
        // show loading animation when fetching
        // show error message when something goes wrong
        // build word lists line by line when fetched
        child: FutureBuilder(
          future: firestore.value.getMyWordLists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error while retrieving your word lists",
                  style: titleStyle,
                ),
              );
            }
            if (snapshot.hasData) {
              final docs = snapshot.data as List<QueryDocumentSnapshot>;
              if (docs.isEmpty) {
                return Center(child: Text("No word lists found"));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final rawData = doc.data() as Map<String, dynamic>;
                  final vocabList = VocabList.fromMap(rawData);
                  final dateTime = vocabList.createdAt.toDate();
                  final formattedDate =
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                  // show delete and edit buttons when swiping left
                  return Slidable(
                    key: ValueKey(doc.id),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      extentRatio: .65,
                      children: [
                        // delete button: show pop-up window to confirm deletion
                        SlidableAction(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          label: 'Delete',
                          onPressed: (context) {
                            popupDialog(
                              context,
                              "Are you sure to delete ${vocabList.title}?",
                              () {
                                removeList(
                                  context: context,
                                  id: doc.id,
                                  title: vocabList.title,
                                  refreshPage: refreshPage,
                                );
                              },
                            );
                          },
                        ),
                        // edit button: click to go to Edit Word List page
                        SlidableAction(
                          icon: Icons.edit,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          label: 'Edit',
                          onPressed: (context) {
                            handleEdit(
                              context: context,
                              data: vocabList,
                              id: doc.id,
                              refreshCallback: refreshPage,
                            );
                          },
                        ),
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(vocabList.title),
                        leading: Icon(Icons.my_library_books_outlined),
                        subtitle: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            // Default return to satisfy non-nullable Widget requirement
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
