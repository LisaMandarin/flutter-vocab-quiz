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
    required this.onDismissible,
  });

  final int index;
  final TextEditingController controllerWord;
  final TextEditingController controllerDefinition;
  final FocusNode focusWord;
  final FocusNode focusDefinition;
  final bool isDismissible;
  final VoidCallback onDismissible;

  @override
  State<AddInputWidget> createState() => _AddInputWidgetState();
}

class _AddInputWidgetState extends State<AddInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // every dismissible item needs a unique key
      key: ValueKey(
        "${widget.controllerWord.text.hashCode}_${widget.controllerDefinition.text.hashCode}",
      ),

      // if only one row exists, it can't be dismissed
      direction: widget.isDismissible
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Icon(Icons.delete_forever_outlined, size: 32),
        ),
      ),

      // when swiping left, dismiss the row
      onDismissed: (direction) {
        widget.onDismissible();
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // row index
              SizedBox(
                width: 20,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text((widget.index + 1).toString()),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // word input
                    TextField(
                      controller: widget.controllerWord,
                      focusNode: widget.focusWord,
                      decoration: InputDecoration(labelText: "word"),
                    ),
                    SizedBox(height: 10),
                    
                    // definition input
                    TextField(
                      controller: widget.controllerDefinition,
                      focusNode: widget.focusDefinition,
                      decoration: InputDecoration(labelText: "Definition"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
