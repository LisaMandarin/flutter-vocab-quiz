import 'package:flutter/cupertino.dart';

class SwitchWidget extends StatefulWidget {
  const SwitchWidget({
    super.key,
    required this.name,
    required this.value,
    required this.onChange,
  });

  final String name;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  @override
  Widget build(BuildContext context) {
    bool changedValue = widget.value;
    return Row(
      children: [
        Text(widget.name),
        CupertinoSwitch(value: changedValue, onChanged: widget.onChange),
      ],
    );
  }
}
