import 'package:flutter/material.dart';

import '../constants/colors.dart';

class RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 1,
              color: Color.fromARGB(255, 14, 17, 21),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: AppColors.primaryColor),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
