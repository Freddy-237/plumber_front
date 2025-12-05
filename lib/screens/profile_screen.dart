import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucun utilisateur connecté'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: CustomScrollView(
        slivers: [
          // App Bar avec gradient et photo de profil
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.secondaryColor,
                          child: user.profilePicture != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.profilePicture!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        user.role == UserType.plumber
                                            ? Icons.build
                                            : Icons.person,
                                        size: 50,
                                        color: AppColors.primaryColor,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  user.role == UserType.plumber
                                      ? Icons.build
                                      : Icons.person,
                                  size: 50,
                                  color: AppColors.primaryColor,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Nom
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge de rôle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role == UserType.plumber
                            ? '🔧 Plombier'
                            : '👤 Client',
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu du profil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations personnelles
                  _buildSectionTitle('Informations personnelles'),
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: user.phone,
                    onTap: () => _showEditDialog(context, 'phone', user.phone),
                  ),
                  if (user.city != null)
                    _buildInfoCard(
                      icon: Icons.location_city,
                      title: 'Ville',
                      value: user.city!,
                      onTap: () => _showEditDialog(context, 'city', user.city),
                    ),
                  if (user.district != null)
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Quartier',
                      value: user.district!,
                      onTap: () =>
                          _showEditDialog(context, 'district', user.district),
                    ),

                  // Section spécifique aux plombiers
                  if (user.role == UserType.plumber) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Informations professionnelles'),
                    if (user.cniNumber != null)
                      _buildInfoCard(
                        icon: Icons.badge,
                        title: 'Numéro CNI',
                        value: user.cniNumber!,
                        onTap: null, // Non modifiable
                      ),
                    _buildInfoCard(
                      icon: Icons.verified_user,
                      title: 'Statut de vérification',
                      value: user.cniImage != null ? 'Vérifié' : 'Non vérifié',
                      valueColor:
                          user.cniImage != null ? Colors.green : Colors.orange,
                      trailing: Icon(
                        user.cniImage != null
                            ? Icons.check_circle
                            : Icons.pending,
                        color: user.cniImage != null
                            ? Colors.green
                            : Colors.orange,
                      ),
                      onTap: null,
                    ),
                  ],

                  // Bouton de déconnexion
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 32),

                  // Version de l'app
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Color? valueColor,
    Widget? trailing,
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
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.edit,
                    color: Colors.grey[400],
                    size: 20,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsCard({
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.grey[700],
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

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
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
          onTap: () => _showLogoutDialog(context, ref),
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

  void _showEditDialog(
      BuildContext context, String field, String? currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${_getFieldName(field)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: _getFieldName(field),
            border: const OutlineInputBorder(),
          ),
          keyboardType:
              field == 'phone' ? TextInputType.phone : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la mise à jour du profil
              Navigator.pop(context);
              _showSnackBar(context, 'Fonctionnalité à venir');
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
              // TODO: Navigate to login screen
              _showSnackBar(context, 'Déconnexion réussie');
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  String _getFieldName(String field) {
    switch (field) {
      case 'phone':
        return 'Téléphone';
      case 'city':
        return 'Ville';
      case 'district':
        return 'Quartier';
      default:
        return field;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
