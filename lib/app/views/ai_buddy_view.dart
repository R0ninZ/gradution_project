import 'package:flutter/material.dart';

class AIBuddyView extends StatelessWidget {
  const AIBuddyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Buddy'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AI Chatbot Placeholder',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
