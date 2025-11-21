import 'package:flutter/material.dart';
import '../constants/colors.dart';

class RegisterTemplate extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback? onSubmit;

  const RegisterTemplate({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          // BACKGROUND image
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  "assets/images/mascot.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: Icon(Icons.menu, color: Colors.white, size: 32),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...fields,
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: onSubmit,
                      child: const Text(
                        "Créer le compte",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
