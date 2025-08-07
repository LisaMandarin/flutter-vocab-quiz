import 'package:flutter/material.dart';

class EditInputWidget extends StatefulWidget {
  const EditInputWidget({
    super.key, 
    required this.index, 
    required this.controllerWord, 
    required this.controllerDefinition,
    required this.focusWord,
    required this.focusDefinition
  });

  final String index;
  final TextEditingController controllerWord;
  final TextEditingController controllerDefinition;
  final FocusNode focusWord;
  final FocusNode focusDefinition;

  @override
  State<EditInputWidget> createState() => _EditInputWidgetState();
}

class _EditInputWidgetState extends State<EditInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            border: BoxBorder.fromLTRB(bottom: BorderSide(width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                width: 20,
                height: 30,
                decoration: BoxDecoration(color: Colors.black),
                child: Text(
                  widget.index,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: widget.controllerWord,
                      focusNode: widget.focusWord,
                      decoration: InputDecoration(
                        hint: Text("Enter Word"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                    ),
                    SizedBox(height: 5,),
                    TextField(
                      controller: widget.controllerDefinition,
                      focusNode: widget.focusDefinition,
                      decoration: InputDecoration(
                        hint: Text("Enter Definition"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
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
    );
  }
}