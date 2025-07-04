import 'package:flutter/material.dart';
class WidgetA extends StatefulWidget {
  @override
  State<WidgetA> createState() => _WidgetAState();
}

class _WidgetAState extends State<WidgetA> {
  List<String> items = ['Apple', 'Banana'];

  @override
  Widget build(BuildContext context) {
    return WidgetB(items: items);
  }
}

class WidgetB extends StatelessWidget {
  final List<String> items;
  const WidgetB({required this.items});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        items.add('Orange'); // This modifies the original list in WidgetA
      },
      child: Text('Add Orange'),
    );
  }
}