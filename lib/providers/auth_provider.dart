import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider du service d'authentification
final authServiceProvider = Provider((ref) => AuthService());

/// Provider de l'état d'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// États possibles de l'authentification
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Notifier pour gérer l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  /// Inscription client
  Future<void> registerClient({
    required String name,
    required String phone,
    required String password,
    required String city,
    String? district,
    String? profile_picture,
  }) async {
    print('\n[AUTH PROVIDER] Inscription client démarrée');
    print('  - name: $name');
    print('  - phone: $phone');
    print('  - city: $city');
    print('  - district: $district');

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.registerClient(
        name: name,
        phone: phone,
        password: password,
        city: city,
        district: district,
        profile_picture: profile_picture,
      );

      print('[AUTH PROVIDER] Inscription réussie!');
      print('  - User ID: ${user.id}');
      print('  - User Name: ${user.name}');
      print('  - User Phone: ${user.phone}');

      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      print('[AUTH PROVIDER] Erreur lors de l\'inscription: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Inscription plombier
  Future<void> registerPlumber({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cni_number,
    String? district,
    String? cni_image,
    String? profile_picture,
  }) async {
    print('\n[AUTH PROVIDER] Inscription plombier démarrée');
    print('  - name: $name');
    print('  - phone: $phone');
    print('  - city: $city');
    print('  - district: $district');
    print('  - cni_number: $cni_number');

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.registerPlumber(
        name: name,
        phone: phone,
        password: password,
        city: city,
        cni_number: cni_number,
        district: district,
        cni_image: cni_image,
        profile_picture: profile_picture,
      );

      print('[AUTH PROVIDER] Inscription réussie!');
      print('  - User ID: ${user.id}');
      print('  - User Name: ${user.name}');
      print('  - User Phone: ${user.phone}');
      print('  - CNI Number: ${user.cni_number}');

      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      print('[AUTH PROVIDER] Erreur lors de l\'inscription: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Connexion
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    print('\n[AUTH PROVIDER] Connexion démarrée');
    print('  - phone: $phone');

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(
        phone: phone,
        password: password,
      );

      print('[AUTH PROVIDER] Connexion réussie!');
      print('  - User ID: ${user.id}');
      print('  - User Name: ${user.name}');
      print('  - User Role: ${user.role}');

      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      print('[AUTH PROVIDER] Erreur lors de la connexion: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    if (state.user != null) {
      try {
        await _authService.logout(state.user!.token);
      } catch (e) {
        // Log l'erreur mais continue la déconnexion
      }
    }
    state = AuthState();
  }

  /// Vérifier le token
  Future<void> verifyToken(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.verifyToken(token);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }
}
