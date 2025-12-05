import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.plumbing,
                color: Color(0xFF00589e),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 232, 224, 224),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
