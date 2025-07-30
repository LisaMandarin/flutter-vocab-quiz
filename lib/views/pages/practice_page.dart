import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/flipcard_widget.dart';
import 'package:vocab_quiz/views/components/hero_widget.dart';
import 'package:vocab_quiz/views/components/pageIndicator_widget.dart';
import 'package:vocab_quiz/views/pages/quiz_page.dart';
import 'package:flutter/foundation.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.title, required this.vocabList});

  final String title;
  final List<VocabItem> vocabList;
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    // initialize 
    _tabController = TabController(
      length: widget.vocabList.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Practice"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return QuizPage(vocabList: widget.vocabList);
              },
            ),
          );
        },
        backgroundColor: Color(0xFF171717),
        foregroundColor: const Color.fromARGB(255, 117, 15, 15),
        child: Icon(Icons.edit),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              HeroWidget(title: widget.title),
              SizedBox(height: 20),
              SizedBox(
                height: 500,
                child: PageView(
                  controller: _pageViewController,
                  onPageChanged: _handlePageViewChanged,
                  children: widget.vocabList
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
                vocabList: widget.vocabList,
              ),
            ],
          ),
        ),
      ),
    );
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
}
