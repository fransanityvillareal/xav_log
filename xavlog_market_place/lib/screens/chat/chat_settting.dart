import 'package:flutter/material.dart';

class ChatSettting  extends StatelessWidget {
  const ChatSettting ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
