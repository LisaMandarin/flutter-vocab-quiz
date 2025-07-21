import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  const InputWidget({super.key, required this.definition, required this.index});

  final String definition;
  final String index;
  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
              SizedBox(width: 5),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.definition, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 5),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hint: Text("Enter word"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
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
