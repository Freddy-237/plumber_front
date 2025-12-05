import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Modèle pour un profil de plombier avec statistiques
class PlumberProfile {
  final String id;
  final String name;
  final String? profilePicture;
  final double rating;
  final int reviewCount;
  final String? city;
  final String? district;
  final String phone;
  final bool isVerified;
  final int completedJobs;
  final String? cniNumber;
  final String? cniImage;
  final DateTime createdAt;

  PlumberProfile({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.rating,
    required this.reviewCount,
    this.city,
    this.district,
    required this.phone,
    this.isVerified = false,
    this.completedJobs = 0,
    this.cniNumber,
    this.cniImage,
    required this.createdAt,
  });

  factory PlumberProfile.fromJson(Map<String, dynamic> json) {
    // Le backend retourne rating_avg et rating_count
    final ratingAvg = json['rating_avg'];
    final ratingCount = json['rating_count'];

    return PlumberProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      profilePicture: json['profile_picture'] as String?,
      rating: ratingAvg != null
          ? double.tryParse(ratingAvg.toString()) ?? 0.0
          : 0.0,
      reviewCount:
          ratingCount != null ? int.tryParse(ratingCount.toString()) ?? 0 : 0,
      city: json['city'] as String?,
      district: json['district'] as String?,
      phone: json['phone'] as String,
      isVerified: json['cni_number'] != null && json['cni_image'] != null,
      completedJobs: 0, // TODO: Ajouter un champ dans la DB pour ça
      cniNumber: json['cni_number'] as String?,
      cniImage: json['cni_image'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'profile_picture': profilePicture,
        'rating': rating,
        'review_count': reviewCount,
        'city': city,
        'district': district,
        'phone': phone,
        'is_verified': isVerified,
        'completed_jobs': completedJobs,
        'cni_number': cniNumber,
        'cni_image': cniImage,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Service pour gérer les opérations liées aux plombiers
class PlumberService {
  final Dio _dio = ApiClient.dio;

  /// Récupère la liste de tous les plombiers triés par note
  /// Utilise l'endpoint /api/auth/users/role/plombier du backend
  Future<List<PlumberProfile>> getPlumbers({
    String? city,
    double? minRating,
  }) async {
    try {
      debugPrint('\n========== GET PLUMBERS ==========');
      debugPrint('Ville: ${city ?? "Toutes"}');
      debugPrint('Note minimale: ${minRating ?? "Aucune"}');

      // Utiliser l'endpoint correct: GET /api/auth/users/role/plombier
      final response = await _dio.get('/api/auth/users/role/plombier');

      if (response.statusCode == 200) {
        final data = response.data;

        // Le backend retourne directement un tableau de plombiers
        List plumbersJson;
        if (data is List) {
          plumbersJson = data;
        } else if (data is Map) {
          plumbersJson = data['data'] ?? data['users'] ?? [];
        } else {
          plumbersJson = [];
        }

        debugPrint('📦 Données reçues: ${plumbersJson.length} plombiers');

        // Convertir en objets PlumberProfile
        var plumbers =
            plumbersJson.map((json) => PlumberProfile.fromJson(json)).toList();

        debugPrint('👷 ${plumbers.length} plombiers convertis');

        // Filtrer par ville si spécifié
        if (city != null && city != 'Toutes') {
          plumbers = plumbers.where((p) => p.city == city).toList();
          debugPrint('🔍 Filtre ville "$city": ${plumbers.length} résultats');
        }

        // Filtrer par note minimale si spécifié
        if (minRating != null) {
          plumbers = plumbers.where((p) => p.rating >= minRating).toList();
          debugPrint(
              '⭐ Filtre note min $minRating: ${plumbers.length} résultats');
        }

        // Trier par note décroissante (les mieux notés en premier)
        plumbers.sort((a, b) => b.rating.compareTo(a.rating));

        debugPrint('✅ ${plumbers.length} plombiers récupérés et triés');
        debugPrint('==================================\n');

        return plumbers;
      } else {
        throw Exception('Erreur lors de la récupération des plombiers');
      }
    } on DioException catch (e) {
      debugPrint('❌ Erreur DioException: ${e.message}');
      debugPrint('Type: ${e.type}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint('❌ Erreur inattendue: $e');
      throw Exception('Erreur lors de la récupération des plombiers: $e');
    }
  }

  /// Récupère les détails d'un plombier spécifique
  /// Utilise l'endpoint /api/auth/users/:id du backend
  Future<PlumberProfile> getPlumberById(String plumberId) async {
    try {
      debugPrint('\n========== GET PLUMBER BY ID ==========');
      debugPrint('ID: $plumberId');

      final response = await _dio.get('/api/auth/users/$plumberId');

      if (response.statusCode == 200) {
        final plumberJson = response.data;

        final plumber = PlumberProfile.fromJson(plumberJson);

        debugPrint('✅ Plombier récupéré: ${plumber.name}');
        debugPrint('=======================================\n');

        return plumber;
      } else {
        throw Exception('Plombier non trouvé');
      }
    } on DioException catch (e) {
      debugPrint('❌ Erreur DioException: ${e.message}');
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint('❌ Erreur inattendue: $e');
      throw Exception('Erreur lors de la récupération du plombier: $e');
    }
  }

  /// Noter un plombier
  /// Utilise l'endpoint POST /api/auth/users/:id/rate du backend
  Future<Map<String, dynamic>> ratePlumber({
    required String plumberId,
    required double rating,
  }) async {
    try {
      debugPrint('\n========== RATE PLUMBER ==========');
      debugPrint('ID: $plumberId');
      debugPrint('Note: $rating');

      if (rating < 1 || rating > 5) {
        throw Exception('La note doit être entre 1 et 5');
      }

      final response = await _dio.post(
        '/api/auth/users/$plumberId/rate',
        data: {'rating': rating},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('✅ Note enregistrée');
        debugPrint('Nouvelle moyenne: ${data['rating_avg']}');
        debugPrint('Nombre total d\'avis: ${data['rating_count']}');
        debugPrint('==================================\n');

        return {
          'rating_avg': data['rating_avg'],
          'rating_count': data['rating_count'],
        };
      } else {
        throw Exception('Erreur lors de l\'enregistrement de la note');
      }
    } on DioException catch (e) {
      debugPrint('❌ Erreur DioException: ${e.message}');
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint('❌ Erreur inattendue: $e');
      throw Exception('Erreur lors de l\'enregistrement de la note: $e');
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return 'Plombiers non trouvés';
        } else if (statusCode == 401) {
          return 'Non autorisé. Veuillez vous reconnecter';
        } else if (statusCode == 500) {
          return 'Erreur serveur. Veuillez réessayer plus tard';
        }
        return 'Erreur: ${e.response?.data?['message'] ?? e.message}';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.unknown:
        return 'Erreur de connexion. Vérifiez votre connexion internet';
      default:
        return 'Une erreur est survenue';
    }
  }
}
