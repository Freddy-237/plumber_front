import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/register_template.dart';
import '../widgets/register_input_field.dart';
import '../providers/auth_provider.dart';

class PlumberRegisterScreen extends ConsumerStatefulWidget {
  const PlumberRegisterScreen({super.key});

  @override
  ConsumerState<PlumberRegisterScreen> createState() =>
      _PlumberRegisterScreenState();
}

class _PlumberRegisterScreenState extends ConsumerState<PlumberRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _cniNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _cniNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation basique
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _cniNumberController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Appeler le provider d'authentification
    await ref.read(authStateProvider.notifier).registerPlumber(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          city: _cityController.text.trim(),
          cni_number: _cniNumberController.text.trim(),
          district: _districtController.text.trim().isEmpty
              ? null
              : _districtController.text.trim(),
        );

    // Vérifier l'état après l'inscription
    final authState = ref.read(authStateProvider);

    if (!mounted) return;

    if (authState.error != null) {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (authState.user != null) {
      // Afficher message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Rediriger vers la page de login après 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop(); // Retour à l'écran de login
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return RegisterTemplate(
      title: "Inscription Plombier",
      onSubmit: authState.isLoading
          ? null
          : () {
              _handleSubmit();
            },
      fields: [
        // Photo de profil circulaire en haut
        const RegisterPhotoPicker(),

        RegisterInputField(
          label: "Nom complet",
          icon: Icons.person,
          controller: _nameController,
        ),
        RegisterInputField(
          label: "Téléphone",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),
        RegisterInputField(
          label: "Ville",
          icon: Icons.location_city,
          controller: _cityController,
        ),
        RegisterInputField(
          label: "Quartier (optionnel)",
          icon: Icons.home,
          controller: _districtController,
        ),

        // Champs spécifiques plombier
        RegisterInputField(
          label: "Numéro CNI",
          icon: Icons.badge,
          controller: _cniNumberController,
        ),

        // Photo CNI à ajouter après le numéro
        const RegisterImagePicker(label: 'Ajouter photo CNI'),

        RegisterInputField(
          label: "Mot de passe",
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
        ),
        RegisterInputField(
          label: "Confirmer mot de passe",
          icon: Icons.lock_outline,
          obscure: true,
          controller: _confirmPasswordController,
        ),
        if (authState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
