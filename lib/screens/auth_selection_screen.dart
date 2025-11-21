import 'package:flutter/material.dart';

import '../widgets/button.dart';
import '../constants/colors.dart';
import 'client_login_screen.dart';
import 'plumber_login_screen.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Couleur harmonisée
      body: Stack(
        children: [
          // === BACKGROUND MASCOT / IMAGE AVEC TRANSPARENCE ===
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  "assets/images/mascot.png",
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // === CONTENU CENTRAL ===
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  const Text(
                    "Choisissez votre espace :",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  // CLIENT BUTTON
                  RoleButton(
                    title: "Je suis un plombier",
                    icon: Icons.person_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PlumberLoginScreen()),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PLUMBER BUTTON
                  RoleButton(
                    title: "Je cherches un plombier",
                    icon: Icons.plumbing_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClientLoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
