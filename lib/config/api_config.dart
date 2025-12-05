import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// 🔧 Configuration centralisée des URLs API
///
/// Instructions pour configurer selon votre environnement:
///
/// 1️⃣ ÉMULATEUR ANDROID:
///    - LOCAL_IP = "10.0.2.2"
///    - L'émulateur Android utilise 10.0.2.2 pour accéder au localhost de votre PC
///
/// 2️⃣ APPAREIL PHYSIQUE (Android/iOS):
///    - LOCAL_IP = "192.168.x.x" (votre IP locale)
///    - Pour trouver votre IP:
///      • Windows: Ouvrez CMD et tapez `ipconfig` → cherchez "Adresse IPv4"
///      • Mac/Linux: Ouvrez Terminal et tapez `ifconfig` → cherchez "inet"
///    - Assurez-vous que votre appareil et votre PC sont sur le même réseau WiFi
///
/// 3️⃣ iOS SIMULATOR:
///    - LOCAL_IP = "localhost" (automatiquement géré)
///
/// 4️⃣ DESKTOP (Windows/Mac/Linux):
///    - LOCAL_IP = "localhost" (automatiquement géré)
///
/// 5️⃣ SERVEUR DISTANT:
///    - Changez USE_REMOTE_SERVER = true
///    - Définissez REMOTE_SERVER_URL avec l'URL de votre serveur
class ApiConfig {
  // 🔧 CONFIGURATION PRINCIPALE
  static const bool USE_REMOTE_SERVER =
      false; // Changer en true pour utiliser un serveur distant

  // Pour développement local (émulateur/appareil physique)
  // 🔴🔴🔴 APPAREIL PHYSIQUE: Remplacez par votre IP locale (ex: "192.168.1.42")
  // 🔴🔴🔴 Trouvez votre IP avec: ipconfig dans PowerShell
  // 🔴🔴🔴 OU utilisez "localhost" si vous avez fait: adb reverse tcp:3000 tcp:3000
  static const String LOCAL_IP =
      "172.20.10.2"; // 🔴 CHANGEZ ICI: "10.0.2.2" pour émulateur, "192.168.x.x" pour appareil physique
  static const String PORT = "3000";

  // Pour serveur distant (production)
  static const String REMOTE_SERVER_URL =
      "https://votre-serveur.com"; // 🔴 CHANGEZ ICI pour production

  /// Obtient l'URL de base selon la plateforme et la configuration
  static String getBaseUrl() {
    // Si on utilise un serveur distant
    if (USE_REMOTE_SERVER) {
      return REMOTE_SERVER_URL;
    }

    // Sinon, configuration locale selon la plateforme
    if (!kIsWeb && Platform.isAndroid) {
      // Android (émulateur ou appareil physique)
      return "http://$LOCAL_IP:$PORT";
    } else if (!kIsWeb && Platform.isWindows) {
      // Windows Desktop
      return "http://localhost:$PORT";
    } else if (!kIsWeb && Platform.isIOS) {
      // iOS Simulator
      return "http://localhost:$PORT";
    } else if (!kIsWeb && Platform.isMacOS) {
      // macOS Desktop
      return "http://localhost:$PORT";
    } else if (!kIsWeb && Platform.isLinux) {
      // Linux Desktop
      return "http://localhost:$PORT";
    } else {
      // Web ou autre
      return "http://localhost:$PORT";
    }
  }

  /// Affiche les informations de configuration
  static void printConfig() {
    debugPrint('\n═══════════════════════════════════');
    debugPrint('🌐 CONFIGURATION API');
    debugPrint('═══════════════════════════════════');
    debugPrint(
        'Mode: ${USE_REMOTE_SERVER ? "Serveur distant" : "Développement local"}');
    debugPrint('Plateforme: ${_getPlatformName()}');
    debugPrint('Base URL: ${getBaseUrl()}');
    if (!USE_REMOTE_SERVER) {
      debugPrint('LOCAL_IP: $LOCAL_IP');
      debugPrint('PORT: $PORT');
    }
    debugPrint('═══════════════════════════════════\n');

    // Aide en cas de problème de connexion
    if (!USE_REMOTE_SERVER &&
        !kIsWeb &&
        Platform.isAndroid &&
        LOCAL_IP == "10.0.2.2") {
      debugPrint('💡 ASTUCE APPAREIL PHYSIQUE:');
      debugPrint('   Vous utilisez 10.0.2.2 (émulateur)');
      debugPrint('   Pour appareil physique:');
      debugPrint(
          '   1️⃣  Exécutez le script: C:\\Users\\Freddy\\Desktop\\diagnostic_backend.ps1');
      debugPrint('   2️⃣  Il affichera votre IP locale');
      debugPrint('   3️⃣  Changez LOCAL_IP dans lib/config/api_config.dart');
      debugPrint(
          '   OU utilisez: adb reverse tcp:3000 tcp:3000 + LOCAL_IP="localhost"\n');
    }
  }

  static String _getPlatformName() {
    if (kIsWeb) return "Web";
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    if (Platform.isWindows) return "Windows";
    if (Platform.isMacOS) return "macOS";
    if (Platform.isLinux) return "Linux";
    return "Unknown";
  }
}
