import 'package:flutter/material.dart';
import 'text_field.dart';
import '../constants/colors.dart';

class LoginTemplate extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final TextEditingController? phoneController;
  final TextEditingController? passwordController;
  final bool isLoading;

  const LoginTemplate({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.phoneController,
    this.passwordController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Couleur harmonisée
      body: Stack(
        children: [
          // === BACKGROUND MASCOT / IMAGE AVEC TRANSPARENCE ===
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  "assets/images/mascot.png", // mets ton image ici
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
                  // TITRE
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // === TÉLÉPHONE ===
                  AppTextField(
                    label: 'Téléphone',
                    icon: Icons.phone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  // === PASSWORD ===
                  AppTextField(
                    label: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscure: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 35),

                  // === BUTTON LOGIN ===
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColors.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                      ),
                      onPressed: isLoading ? null : onLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : const Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === LINK REGISTER ===
                  GestureDetector(
                    onTap: onRegister,
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  // Note: specific field styling moved to `AppTextField` in text_field.dart
}
