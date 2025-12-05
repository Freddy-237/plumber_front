import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ChatAvatar extends StatelessWidget {
  final String name;
  final bool isMe;
  final String? role;
  final String? avatarUrl;
  final double radius;

  const ChatAvatar({
    super.key,
    required this.name,
    this.isMe = false,
    this.role,
    this.avatarUrl,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final base = CircleAvatar(
      radius: radius,
      backgroundColor: isMe ? const Color(0xFF00589e) : Colors.grey.shade300,
      foregroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0] : '?',
              style: TextStyle(
                color: isMe ? AppColors.secondaryColor : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    if (role == 'plumber' || role == 'plombier') {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          base,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build,
                  size: 12,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return base;
  }
}
