import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';

class AddListPage extends StatefulWidget {
  const AddListPage({super.key});

  @override
  State<AddListPage> createState() => _AddlistPageState();
}

class _AddlistPageState extends State<AddListPage> {
  List<TextEditingController> words = [];
  List<TextEditingController> definitions = [];

  @override
  void dispose() {
    for (var c in words) {
      c.dispose();
    }
    for (var c in definitions) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    addNew();
  }

  void addNew() {
    setState(() {
      words.add(TextEditingController());
      definitions.add(TextEditingController());
    });
  }

  void removeRow(int index) {
    setState(() {
      words[index].dispose();
      definitions[index].dispose();
      words.removeAt(index);
      definitions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Add List"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: min(words.length, definitions.length),
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(
                      "${words[index].hashCode}_${definitions[index].hashCode}",
                    ),
                    direction: words.length > 1
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Icon(Icons.delete_forever_outlined, size: 32),
                      ),
                    ),
                    onDismissed: (direction) {
                      removeRow(index);
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text((index + 1).toString()),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: words[index],
                                    decoration: InputDecoration(
                                      labelText: "word",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: definitions[index],
                                    decoration: InputDecoration(
                                      labelText: "definition",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () {
                addNew();
              },
              icon: Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
