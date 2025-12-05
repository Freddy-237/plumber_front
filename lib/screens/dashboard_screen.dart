import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../config/routes.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondaryColor),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              // Confirmer la déconnexion
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text(
                    'Voulez-vous vraiment vous déconnecter et réinitialiser l\'application ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                // Déconnecter Socket.io
                await ref
                    .read(chatProvider.notifier)
                    .disconnectFromConversation();

                // Déconnexion et suppression des données
                await ref.read(authStateProvider.notifier).logout();

                // Supprimer aussi hasSeenHome pour retourner à la page d'accueil
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Nettoyer le token dans ApiClient
                ApiClient().clearAuthToken();

                if (context.mounted) {
                  // Retourner à l'écran de chargement
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.loading,
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bienvenue dans vos messages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Cliquez sur le bouton ci-dessous pour accéder au chat',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  AppRoutes.navigateToChat(context);
                },
                icon: const Icon(Icons.chat, color: AppColors.secondaryColor),
                label: const Text(
                  'Ouvrir le Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
