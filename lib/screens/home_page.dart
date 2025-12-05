import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';
import 'auth_selection_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _continue(BuildContext context) async {
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenHome', false);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simple hero illustration placeholder
                    Image.asset(
                      'assets/images/mascot1.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 24),
                    Text('Bienvenue sur Le Plombier 237',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor)),
                    const SizedBox(height: 12),
                    Text(
                        'Trouve et contacte facilement des plombiers près de chez toi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: AppColors.secondaryColor)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _continue(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('Commencer', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
