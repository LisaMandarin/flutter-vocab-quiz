import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/utils/snackbar.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/flipcard_widget.dart';
import 'package:vocab_quiz/views/components/hero_widget.dart';
import 'package:vocab_quiz/views/components/pageIndicator_widget.dart';
import 'package:vocab_quiz/views/pages/quiz_page.dart';
import 'package:flutter/foundation.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({
    super.key,
    required this.title,
    required this.wordlistID,
  });

  final String title;
  final String wordlistID;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  List<VocabItem> _list = [];

  @override
  void initState() {
    super.initState();

    // initialize page controller first (safe to do synchronously)
    _pageViewController = PageController();

    //Move async loading into its own method (_loadData) so initState stays synchronous
    _loadData();
  }

  // Load vocab list from Firestore and sets up tab controller
  Future<void> _loadData() async {
    // Fetch raw map data from Firestore
    final data = await fetchWordList(widget.wordlistID);

    // If no data found, do nothing
    if (data != null) {
      // Convert Firestore map into our model
      final vocabList = VocabList.fromMap(data);

      // Update state AFTER data is loaded
      setState(() {
        _list = vocabList.list;

        // Create TabController now that we know the list length
        _tabController = TabController(length: _list.length, vsync: this);
      });
    }
  }

  // fetch a document from word_lists collection on Firestore
  Future<Map<String, dynamic>?> fetchWordList(String id) async {
    try {
      final DocumentSnapshot? doc = await firestore.value.getWordList(id);
      if (doc == null || !doc.exists) return null;

      final wordList = doc.data() as Map<String, dynamic>;
      return wordList;
    } on FirebaseException catch (e) {
      if (mounted) {
        showErrorMessage(
          context,
          e.message ?? "Something went wrong while fetching word list",
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    if (_list.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  // change the current page on desktop/web device, not working on mobile device
  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  // update the current page when the button is clicked
  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // check if the device is desktop/web
  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.macOS ||
        TargetPlatform.linux ||
        TargetPlatform.windows => true,
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.fuchsia => false,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Practice"),
      floatingActionButton: FloatingActionButton(
        // click to go to Quiz Page only when list is not empty
        onPressed: _list.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return QuizPage(vocabList: _list, title: widget.title);
                    },
                  ),
                );
              }
            : null,
        child: Icon(Icons.edit),
      ),

      body: _list.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    HeroWidget(title: widget.title),
                    SizedBox(height: 20),

                    // show flashcards only when list is not empty
                    SizedBox(
                      height: 500,
                      child: PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: _list
                            .map(
                              (item) => FlipcardWidget(
                                front: item.word,
                                back: item.definition,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    PageIndicator(
                      tabController: _tabController,
                      currentPageIndex: _currentPageIndex,
                      onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                      isOnDesktopAndWeb: _isOnDesktopAndWeb,
                      vocabList: _list,
                    ),
                  ],
                ),
              ),
            )
          // show loading animation when list is not fetched yet or empty list
          : Center(child: CircularProgressIndicator()),
    );
  }
}
