import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plumber/widgets/login_template.dart';

import 'plumber_register_screen.dart';
import 'chat_screen.dart';
import '../providers/auth_provider.dart';

class PlumberLoginScreen extends ConsumerStatefulWidget {
  const PlumberLoginScreen({super.key});

  @override
  ConsumerState<PlumberLoginScreen> createState() => _PlumberLoginScreenState();
}

class _PlumberLoginScreenState extends ConsumerState<PlumberLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

    final authState = ref.read(authStateProvider);

    if (!mounted) return;

    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (authState.user != null) {
      // Rediriger vers la page de chat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return LoginTemplate(
      phoneController: _phoneController,
      passwordController: _passwordController,
      isLoading: authState.isLoading,
      onLogin: () {
        _handleLogin();
      },
      onRegister: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlumberRegisterScreen()),
        );
      },
    );
  }
}
