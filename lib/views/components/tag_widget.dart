import 'package:flutter/material.dart';

class TagWidget extends StatefulWidget {
  const TagWidget({super.key, required this.name, required this.color});

  final String name;
  final Color color;

  @override
  State<TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          widget.name,
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}
