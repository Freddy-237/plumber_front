import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // 🔑 Charger l'authentification depuis le stockage
    await ref.read(authStateProvider.notifier).checkStoredAuth();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Vérifier si l'utilisateur est connecté
    final authState = ref.read(authStateProvider);
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHome = prefs.getBool('hasSeenHome') ?? false;

    if (!mounted) return;

    // Si l'utilisateur est connecté, aller vers MainScreen
    if (authState.isAuthenticated) {
      AppRoutes.navigateToMain(context);
    }
    // Sinon, si première visite, montrer HomePage
    else if (!hasSeenHome) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
    // Sinon, aller vers AuthSelection pour se connecter
    else {
      AppRoutes.navigateToAuthSelection(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Image.asset(
                  'assets/images/mascot237.png',
                  width: 200,
                  height: 200,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
