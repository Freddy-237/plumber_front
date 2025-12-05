import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Réglages',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Notifications
          _buildSectionTitle('Notifications'),
          _buildSwitchCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Recevoir les notifications push',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchCard(
            icon: Icons.volume_up_outlined,
            title: 'Son',
            subtitle: 'Sons des notifications',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),
          _buildSwitchCard(
            icon: Icons.vibration,
            title: 'Vibration',
            subtitle: 'Vibration des notifications',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Section Langue et région
          _buildSectionTitle('Langue et région'),
          _buildSettingCard(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
          ),
          _buildSettingCard(
            icon: Icons.dark_mode_outlined,
            title: 'Thème',
            subtitle: 'Clair',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),

          const SizedBox(height: 24),

          // Section Confidentialité et sécurité
          _buildSectionTitle('Confidentialité et sécurité'),
          _buildSettingCard(
            icon: Icons.security,
            title: 'Confidentialité',
            subtitle: 'Gérer vos données personnelles',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),
          _buildSettingCard(
            icon: Icons.lock_outline,
            title: 'Mot de passe',
            subtitle: 'Modifier votre mot de passe',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),
          _buildSettingCard(
            icon: Icons.block,
            title: 'Utilisateurs bloqués',
            subtitle: 'Gérer les utilisateurs bloqués',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),

          const SizedBox(height: 24),

          // Section Aide et support
          _buildSectionTitle('Aide et support'),
          _buildSettingCard(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            subtitle: 'FAQ et guides',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),
          _buildSettingCard(
            icon: Icons.contact_support_outlined,
            title: 'Contacter le support',
            subtitle: 'Obtenir de l\'aide',
            onTap: () => _showContactDialog(),
          ),
          _buildSettingCard(
            icon: Icons.feedback_outlined,
            title: 'Envoyer un feedback',
            subtitle: 'Partagez votre avis',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),
          _buildSettingCard(
            icon: Icons.star_outline,
            title: 'Noter l\'application',
            subtitle: 'Notez-nous sur le store',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),

          const SizedBox(height: 24),

          // Section À propos
          _buildSectionTitle('À propos'),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'À propos de l\'application',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(),
          ),
          _buildSettingCard(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire les CGU',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),
          _buildSettingCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Lire la politique',
            onTap: () => _showSnackBar('Fonctionnalité à venir'),
          ),

          const SizedBox(height: 24),

          // Bouton de déconnexion
          _buildLogoutButton(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        activeColor: AppColors.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showLogoutDialog(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 12),
                Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('Langue changée en $_selectedLanguage');
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('Language changed to $_selectedLanguage');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vous pouvez nous contacter via :'),
            const SizedBox(height: 16),
            _buildContactMethod(Icons.email, 'support@plumber.com'),
            const SizedBox(height: 8),
            _buildContactMethod(Icons.phone, '+237 6XX XXX XXX'),
            const SizedBox(height: 8),
            _buildContactMethod(Icons.chat, 'Chat en direct'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.plumbing,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Plumber App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Application de gestion de services de plomberie. Connectez-vous avec des plombiers professionnels en temps réel.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '© 2025 FRIDEVS',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.secondaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              _showSnackBar('Déconnexion réussie');
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
