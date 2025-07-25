import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
    required this.vocabList,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;
  final List<VocabItem> vocabList;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            // when the left arrow button is clicked, the current page goes backward by 1 until it is page 1
            onPressed: () {
              if (widget.currentPageIndex == 0) {
                return;
              }
              widget.onUpdateCurrentPageIndex(widget.currentPageIndex - 1);
            },
            icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
          ),
          TabPageSelector(
            controller: widget.tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            // when the right arrow button is clicked, the current page goes forward by 1 until it is the last page
            onPressed: () {
              if (widget.currentPageIndex == widget.vocabList.length - 1) {
                return;
              }
              widget.onUpdateCurrentPageIndex(widget.currentPageIndex + 1);
            },
            icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
          ),
        ],
      ),
    );
  }
}
