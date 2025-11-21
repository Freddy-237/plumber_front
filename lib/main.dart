import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/colors.dart';
import 'screens/auth_selection_screen.dart';

// MAIN ENTRY
void main() {
  runApp(const ProviderScope(child: PlumberApp()));
}

class PlumberApp extends StatelessWidget {
  const PlumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Le Plombier 237',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondaryColor,
        ),
        useMaterial3: true,
      ),
      home: const AuthSelectionScreen(),
    );
  }
}
