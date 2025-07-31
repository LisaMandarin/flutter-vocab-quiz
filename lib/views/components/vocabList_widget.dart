import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/views/pages/addList_page.dart';

class VocablistWidget extends StatefulWidget {
  const VocablistWidget({super.key});

  @override
  State<VocablistWidget> createState() => _VocablistWidgetState();
}

class _VocablistWidgetState extends State<VocablistWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Vocab Lists", style: cardStyle),
              Text("..."),
              Text("..."),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddListPage()),
                      );
                    },
                    child: Text("Add New List"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
