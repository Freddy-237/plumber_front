import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/plumber_provider.dart';
import '../services/plumber_service.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
  String _selectedFilter = 'Meilleure note';
  String _selectedCity = 'Toutes';

  @override
  void initState() {
    super.initState();
    // Charger les plombiers au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plumberListProvider.notifier).loadPlumbers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    // Si c'est un plombier, afficher la page de paiement
    if (user?.role == UserType.plumber) {
      return _buildPlumberPaymentPage();
    }

    // Si c'est un client, afficher la liste des plombiers
    return _buildClientPlumbersList();
  }

  Widget _buildClientPlumbersList() {
    final plumberState = ref.watch(plumberListProvider);
    final plumbers = plumberState.plumbers;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Techniciens Reconnus',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.secondaryColor),
            onPressed: () {
              ref.read(plumberListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryColor,
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    icon: Icons.sort,
                    label: _selectedFilter,
                    onTap: () => _showSortDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    icon: Icons.location_on,
                    label: _selectedCity,
                    onTap: () => _showCityDialog(),
                  ),
                ),
              ],
            ),
          ),

          // Affichage de l'erreur
          if (plumberState.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plumberState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(plumberListProvider.notifier).clearError();
                      ref.read(plumberListProvider.notifier).refresh();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),

          // Liste des plombiers
          Expanded(
            child: plumberState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondaryColor,
                    ),
                  )
                : plumbers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(plumberListProvider.notifier)
                              .refresh();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: plumbers.length,
                          itemBuilder: (context, index) {
                            return _buildPlumberCard(plumbers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildPlumberCard(PlumberProfile plumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _callPlumber(plumber),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo de profil
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: plumber.profilePicture != null
                          ? ClipOval(
                              child: Image.network(
                                plumber.profilePicture!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.build,
                                    size: 35,
                                    color: AppColors.primaryColor,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.build,
                              size: 35,
                              color: AppColors.primaryColor,
                            ),
                    ),
                    if (plumber.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Informations principales (nom et téléphone)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plumber.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            plumber.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Note et lieu à droite
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Note
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor(plumber.rating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: _getRatingColor(plumber.rating),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            plumber.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getRatingColor(plumber.rating),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Lieu
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plumber.city ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun plombier trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlumberPaymentPage() {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          'Mes Paiements',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 100,
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reversement des gains',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Suivez vos paiements et historique',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.orange;
    return Colors.red;
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trier par'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Meilleure note'),
            _buildSortOption('Plus d\'avis'),
            _buildSortOption('Plus de travaux'),
            _buildSortOption('Récents'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String option) {
    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
        // Appliquer le tri
        ref.read(plumberListProvider.notifier).sortPlumbers(value!);
        Navigator.pop(context);
      },
    );
  }

  void _showCityDialog() {
    final cities = [
      'Toutes',
      'Douala',
      'Yaoundé',
      'Bafoussam',
      'Garoua',
      'Bamenda'
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par ville'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cities.map((city) {
            return RadioListTile<String>(
              title: Text(city),
              value: city,
              groupValue: _selectedCity,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
                // Appliquer le filtre
                final cityFilter = value == 'Toutes' ? null : value;
                ref.read(plumberListProvider.notifier).filterByCity(cityFilter);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un plombier'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom du plombier...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _showSnackBar('Fonctionnalité de recherche à venir');
          },
        ),
      ),
    );
  }

  void _showPlumberDetails(PlumberProfile plumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.build,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      plumber.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plumber.isVerified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Vérifié',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    _buildDetailRow(Icons.star,
                        '${plumber.rating} ⭐ (${plumber.reviewCount} avis)'),
                    _buildDetailRow(Icons.location_on,
                        '${plumber.district ?? ''} ${plumber.city}'),
                    _buildDetailRow(
                        Icons.work, '${plumber.completedJobs} missions'),
                    _buildDetailRow(Icons.phone, plumber.phone),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _callPlumber(plumber);
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Appeler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _chatWithPlumber(plumber);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('Message'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _callPlumber(PlumberProfile plumber) {
    _showSnackBar('Appel de ${plumber.name}...');
    // TODO: Implémenter l'appel téléphonique
  }

  void _chatWithPlumber(PlumberProfile plumber) {
    _showSnackBar('Ouverture du chat avec ${plumber.name}...');
    // TODO: Naviguer vers la page de chat
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
