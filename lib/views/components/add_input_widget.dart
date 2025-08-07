import 'package:flutter/material.dart';

class AddInputWidget extends StatefulWidget {
  const AddInputWidget({
    super.key,
    required this.index,
    required this.controllerWord,
    required this.controllerDefinition,
    required this.focusWord,
    required this.focusDefinition,
    required this.isDismissible,
    required this.onDismissed,
  });

  // display index shown to user
  final int index;
  final TextEditingController controllerWord;
  final TextEditingController controllerDefinition;
  final FocusNode focusWord;
  final FocusNode focusDefinition;
  final bool isDismissible;
  final VoidCallback onDismissed;

  @override
  State<AddInputWidget> createState() => _AddInputWidgetState();
}

class _AddInputWidgetState extends State<AddInputWidget> {
  @override
  Widget build(BuildContext context) {
    // Widget structure: Dismissible > Padding > IntrinsicHeight > Container > Row
    // - Dismissible: Enables swipe-to-delete functionality
    // - Padding: Adds spacing around the entire item
    // - IntrinsicHeight: Ensures consistent height across items
    // - Container: Provides visual styling (borders, decoration)
    // - Row: Arranges index indicator and input fields horizontally
    return Dismissible(
      // unique key required for Dismissible to track widget identity  
      key: ValueKey("${widget.controllerWord.text.hashCode}_${widget.controllerDefinition.text.hashCode}"),

      // set swipe direction based on dismissible state
      direction: widget.isDismissible
          ? DismissDirection.endToStart
          : DismissDirection.none,
          
      // execute callback when item is dismissed (swiped away)
      onDismissed: widget.isDismissible
          ? (direction) => widget.onDismissed.call()
          : null,
          
      // background shown during swipe gesture
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Icon(
            Icons.delete_forever_outlined,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: IntrinsicHeight(
          // IntrinsicHeight ensures both columns have same height
          child: Container(
            decoration: BoxDecoration(
              // bottom border to separate items visually
              border: Border(bottom: BorderSide(width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // index number indicator (black box with white text)
                Container(
                  alignment: Alignment.center,
                  width: 20,
                  height: 30,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Text(
                    (widget.index + 1).toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                
                // flexible column containing word and definition inputs
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // word input field
                      TextField(
                        controller: widget.controllerWord,
                        focusNode: widget.focusWord,
                        decoration: InputDecoration(
                          hintText: "Enter Word",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      
                      // definition input field
                      TextField(
                        controller: widget.controllerDefinition,
                        focusNode: widget.focusDefinition,
                        decoration: InputDecoration(
                          hintText: "Enter Definition",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
