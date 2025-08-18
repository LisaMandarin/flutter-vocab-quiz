import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/dialog.dart';
import 'package:vocab_quiz/utils/edit.dart';
import 'package:vocab_quiz/utils/remove.dart';
import 'package:vocab_quiz/views/components/tag_widget.dart';
import 'package:vocab_quiz/views/pages/addList_page.dart';
import 'package:vocab_quiz/views/pages/practice_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vocab_quiz/views/pages/wordLists_page.dart';

class VocablistWidget extends StatefulWidget {
  const VocablistWidget({super.key});

  @override
  State<VocablistWidget> createState() => _VocablistWidgetState();
}

class _VocablistWidgetState extends State<VocablistWidget> {
  late Future<List<QueryDocumentSnapshot>> _wordListsFuture;

  @override
  void initState() {
    super.initState();
    _wordListsFuture = fetchWordLists();
  }

  // fetch user's latest 4 documents in word_lists collection of Firestore
  Future<List<QueryDocumentSnapshot>> fetchWordLists() async {
    final docs = await firestore.value.getMyTop4Lists();
    return docs;
  }

  // rebuild page after removing a word list
  void refreshPage() {
    if (mounted) {
      setState(() {
        _wordListsFuture = fetchWordLists();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _wordListsFuture,
          builder: (context, asyncSnapshot) {
            // default body of My Vocab Lists
            Widget widget = Container();

            // show loading animation when the word lists are still fetching
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              widget = const Center(child: CircularProgressIndicator());
            }

            // show error message when something goes wrong fetching wor lists
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

            // build widget when fetching word lists successfully
            if (asyncSnapshot.hasData) {
              final wordLists = asyncSnapshot.data;
              widget = SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // card title
                    Text("My Vocab Lists", style: cardStyle),
                    const SizedBox(height: 10),

                    // when user has no word lists
                    if (wordLists!.isEmpty)
                      const Text("No word lists found.")
                    // when user has word lists, show the word lists line by line with delete and edit buttons
                    else
                      ...wordLists.map((doc) {
                        final rowData = doc.data() as Map<String, dynamic>;
                        final data = VocabList.fromMap(rowData);

                        final dateTime = data.createdAt.toDate();
                        final formattedDate =
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                        return Slidable(
                          key: ValueKey(doc.id),
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            extentRatio: .65,
                            // action buttons when swiping left: delete and edit
                            children: [
                              // delete button
                              SlidableAction(
                                icon: Icons.delete,
                                flex: 2,
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                label: 'Delete',
                                onPressed: (context) {
                                  popupDialog(
                                    context,
                                    "Are you sure to delete ${data.title}",
                                    () {
                                      removeList(
                                        context: context,
                                        id: doc.id,
                                        title: data.title,
                                        refreshPage: refreshPage,
                                      );
                                    },
                                  );
                                },
                              ),

                              // edit button
                              SlidableAction(
                                icon: Icons.edit_outlined,
                                flex: 2,
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                label: "Edit",
                                onPressed: (context) {
                                  handleEdit(
                                    context: context,
                                    data: data,
                                    id: doc.id,
                                    refreshCallback: refreshPage,
                                  );
                                },
                              ),
                            ],
                          ),

                          // list tile template
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(data.title),
                                ),
                                ?data.isPublic
                                    ? TagWidget(
                                        name: "Public",
                                        color: Colors.pinkAccent,
                                      )
                                    : null,
                                ?data.isFavorite
                                    ? TagWidget(
                                        name: "Favorite",
                                        color: Colors.blueAccent,
                                      )
                                    : null,
                              ],
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: TextStyle(fontSize: 10),
                            ),
                            // click list tile to see the details of the word list
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PracticePage(
                                    title: data.title,
                                    wordlistID: doc.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),

                    // action button at the bottom of vocab lists card: see all and add new list
                    Row(
                      children: [
                        // see all button
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return WordlistsPage();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text("See All"),
                                Icon(Icons.more_horiz),
                              ],
                            ),
                          ),
                        ),

                        // add new list button
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final shouldRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddListPage(),
                                ),
                              );
                              if (shouldRefresh == true && mounted) {
                                setState(() {});
                              }
                            },
                            child: Row(
                              children: [Text("Add New List"), Icon(Icons.add)],
                            ),
                          ),
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
