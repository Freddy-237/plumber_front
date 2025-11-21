import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumber App'),
        backgroundColor: const Color(0xFF00589e),
      ),
      body: const Center(
        child: Text(
          'Page de chat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00589e),
          ),
        ),
      ),
    );
  }
}
