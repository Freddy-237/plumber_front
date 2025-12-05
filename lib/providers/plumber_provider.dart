import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/plumber_service.dart';

/// État de la liste des plombiers
class PlumberListState {
  final List<PlumberProfile> plumbers;
  final bool isLoading;
  final String? error;
  final String? selectedCity;
  final double? minRating;

  PlumberListState({
    this.plumbers = const [],
    this.isLoading = false,
    this.error,
    this.selectedCity,
    this.minRating,
  });

  PlumberListState copyWith({
    List<PlumberProfile>? plumbers,
    bool? isLoading,
    String? error,
    String? selectedCity,
    double? minRating,
  }) {
    return PlumberListState(
      plumbers: plumbers ?? this.plumbers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCity: selectedCity ?? this.selectedCity,
      minRating: minRating ?? this.minRating,
    );
  }
}

/// Provider pour la liste des plombiers
class PlumberListNotifier extends StateNotifier<PlumberListState> {
  final PlumberService _plumberService;

  PlumberListNotifier(this._plumberService) : super(PlumberListState());

  /// Charge la liste des plombiers depuis l'API
  Future<void> loadPlumbers({String? city, double? minRating}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('🔄 Chargement des plombiers...');
      debugPrint('   - Ville: ${city ?? "Toutes"}');
      debugPrint('   - Note min: ${minRating ?? "Aucune"}');

      final plumbers = await _plumberService.getPlumbers(
        city: city,
        minRating: minRating,
      );

      debugPrint('✅ ${plumbers.length} plombiers chargés');

      state = state.copyWith(
        plumbers: plumbers,
        isLoading: false,
        selectedCity: city,
        minRating: minRating,
      );
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des plombiers: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rafraîchit la liste des plombiers
  Future<void> refresh() async {
    await loadPlumbers(
      city: state.selectedCity,
      minRating: state.minRating,
    );
  }

  /// Filtre par ville
  Future<void> filterByCity(String? city) async {
    await loadPlumbers(
      city: city,
      minRating: state.minRating,
    );
  }

  /// Filtre par note minimale
  Future<void> filterByRating(double? minRating) async {
    await loadPlumbers(
      city: state.selectedCity,
      minRating: minRating,
    );
  }

  /// Trie les plombiers localement
  void sortPlumbers(String sortBy) {
    final sortedPlumbers = List<PlumberProfile>.from(state.plumbers);

    switch (sortBy) {
      case 'Meilleure note':
        sortedPlumbers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Plus de travaux':
        sortedPlumbers
            .sort((a, b) => b.completedJobs.compareTo(a.completedJobs));
        break;
      case 'Plus d\'avis':
        sortedPlumbers.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'Récents':
        sortedPlumbers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        // Par défaut, trier par note
        sortedPlumbers.sort((a, b) => b.rating.compareTo(a.rating));
    }

    state = state.copyWith(plumbers: sortedPlumbers);
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global pour la liste des plombiers
final plumberListProvider =
    StateNotifierProvider<PlumberListNotifier, PlumberListState>((ref) {
  return PlumberListNotifier(PlumberService());
});
