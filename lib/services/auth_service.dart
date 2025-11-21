import 'package:dio/dio.dart';

import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  /// Inscription d'un client
  Future<User> registerClient({
    required String name,
    required String phone,
    required String password,
    required String city,
    String? district,
    String? profile_picture,
  }) async {
    try {
      print('\n========== REGISTER CLIENT ==========');
      print('Données envoyées:');
      print('  - name: $name');
      print('  - phone: $phone');
      print('  - password: ${password.replaceAll(RegExp(r'.'), '*')}');
      print('  - city: $city');
      print('  - district: $district');
      print('  - role: client');
      print('  - profile_picture: $profile_picture');

      // Utiliser FormData pour multipart/form-data (requis par multer)
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'password': password,
        'city': city,
        'district': district ?? '',
        'role': 'client',
      });

      final response =
          await apiClient.post('/api/auth/register', data: formData);

      print('\nRéponse du serveur:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Data: ${response.data}');

      // Si le backend retourne l'user directement, on l'utilise
      if (response.data.containsKey('user') && response.data['user'] != null) {
        print('  - User reçu directement du backend');
        final userData = response.data['user'];
        userData['token'] = ''; // Token vide pour l'instant
        print('=====================================\n');
        return User.fromJson(userData);
      }

      // Sinon, on fetch l'user par ID (ancien comportement)
      final userId = response.data['id'];
      print('  - User ID reçu: $userId');
      print('  - Fetching user details...');
      print('=====================================\n');
      return await getUserById(userId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Inscription d'un plombier
  Future<User> registerPlumber({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cni_number,
    String? district,
    String? cni_image,
    String? profile_picture,
  }) async {
    try {
      print('\n========== REGISTER PLUMBER ==========');
      print('Données envoyées:');
      print('  - name: $name');
      print('  - phone: $phone');
      print('  - password: ${password.replaceAll(RegExp(r'.'), '*')}');
      print('  - city: $city');
      print('  - district: $district');
      print('  - role: plombier');
      print('  - cni_number: $cni_number');
      print('  - cni_image: $cni_image');
      print('  - profile_picture: $profile_picture');

      // Utiliser FormData pour multipart/form-data (requis par multer)
      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'password': password,
        'city': city,
        'district': district ?? '',
        'role': 'plombier',
        'cni_number': cni_number,
      });

      final response =
          await apiClient.post('/api/auth/register', data: formData);

      print('\nRéponse du serveur:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Data: ${response.data}');

      // Si le backend retourne l'user directement, on l'utilise
      if (response.data.containsKey('user') && response.data['user'] != null) {
        print('  - User reçu directement du backend');
        final userData = response.data['user'];
        userData['token'] = ''; // Token vide pour l'instant
        print('======================================\n');
        return User.fromJson(userData);
      }

      // Sinon, on fetch l'user par ID (ancien comportement)
      final userId = response.data['id'];
      print('  - User ID reçu: $userId');
      print('  - Fetching user details...');
      print('======================================\n');
      return await getUserById(userId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Connexion avec téléphone et mot de passe
  Future<User> login({
    required String phone,
    required String password,
  }) async {
    try {
      print('\n========== LOGIN ==========');
      print('Données envoyées:');
      print('  - phone: $phone');
      print('  - password: ${password.replaceAll(RegExp(r'.'), '*')}');

      final response = await apiClient.post('/api/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      print('\nRéponse du serveur:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Data: ${response.data}');

      // Backend retourne { token, user: {...} }
      final userData = response.data['user'];
      final token = response.data['token'];

      print('  - Token reçu: ${token.substring(0, 20)}...');
      print('  - User Data: $userData');

      // Ajouter le token dans les données user
      userData['token'] = token;

      print('===========================\n');

      return User.fromJson(userData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Déconnexion
  Future<void> logout(String token) async {
    try {
      await apiClient.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un utilisateur par ID
  Future<User> getUserById(String userId) async {
    try {
      print('\n========== GET USER BY ID ==========');
      print('User ID demandé: $userId');

      final response = await apiClient.get('/api/auth/users/$userId');

      print('\nRéponse du serveur:');
      print('  - Status Code: ${response.statusCode}');
      print('  - User Data: ${response.data}');

      // Ajouter un token vide temporaire (sera remplacé après login)
      final userData = response.data;
      userData['token'] = '';

      print('====================================\n');

      return User.fromJson(userData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Vérifier si le token est valide
  Future<User> verifyToken(String token) async {
    try {
      final response = await apiClient.get(
        '/verify',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gestion des erreurs
  String _handleError(DioException e) {
    print('\n========== ERREUR API ==========');
    print('Type d\'erreur: ${e.type}');
    print('Message: ${e.message}');

    if (e.response != null) {
      print('Status Code: ${e.response!.statusCode}');
      print('Response Data: ${e.response!.data}');
      print('Response Headers: ${e.response!.headers}');

      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        print('Message d\'erreur du serveur: ${data['message']}');
        print('================================\n');
        return data['message'] as String;
      }
      print('================================\n');
      return 'Erreur: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      print('Timeout de connexion');
      print('================================\n');
      return 'Délai de connexion dépassé';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      print('Timeout de réception');
      print('================================\n');
      return 'Délai de réception dépassé';
    } else {
      print('Erreur de connexion');
      print('================================\n');
      return 'Erreur de connexion au serveur';
    }
  }
}
