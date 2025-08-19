import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.controllerSearchText,
    required this.onSubmitted,
    required this.onClosed
  });

  final TextEditingController controllerSearchText;
  final VoidCallback onSubmitted;
  final VoidCallback onClosed;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controllerSearchText,
      decoration: InputDecoration(
        hintText: "Search...",
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(onPressed: widget.onClosed, icon: Icon(Icons.close)),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted:(value) => widget.onSubmitted(),
    );
  }
}
