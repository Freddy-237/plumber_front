import 'package:flutter/material.dart';
import '../screens/loading_screen.dart';
import '../screens/home_page.dart';
import '../screens/auth_selection_screen.dart';
import '../screens/client_login_screen.dart';
import '../screens/client_register_screen.dart';
import '../screens/plumber_login_screen.dart';
import '../screens/plumber_register_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  // Route names
  static const String loading = '/';
  static const String home = '/home';
  static const String authSelection = '/auth-selection';
  static const String main = '/main';
  static const String clientLogin = '/client-login';
  static const String clientRegister = '/client-register';
  static const String plumberLogin = '/plumber-login';
  static const String plumberRegister = '/plumber-register';
  static const String chat = '/chat';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case authSelection:
        return MaterialPageRoute(builder: (_) => const AuthSelectionScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case clientLogin:
        return MaterialPageRoute(builder: (_) => const ClientLoginScreen());

      case clientRegister:
        return MaterialPageRoute(builder: (_) => const ClientRegisterScreen());

      case plumberLogin:
        return MaterialPageRoute(builder: (_) => const PlumberLoginScreen());

      case plumberRegister:
        return MaterialPageRoute(builder: (_) => const PlumberRegisterScreen());

      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToAuthSelection(BuildContext context) {
    Navigator.pushReplacementNamed(context, authSelection);
  }

  static void navigateToMain(BuildContext context) {
    Navigator.pushReplacementNamed(context, main);
  }

  static void navigateToClientLogin(BuildContext context) {
    Navigator.pushNamed(context, clientLogin);
  }

  static void navigateToClientRegister(BuildContext context) {
    Navigator.pushNamed(context, clientRegister);
  }

  static void navigateToPlumberLogin(BuildContext context) {
    Navigator.pushNamed(context, plumberLogin);
  }

  static void navigateToPlumberRegister(BuildContext context) {
    Navigator.pushNamed(context, plumberRegister);
  }

  static void navigateToChat(BuildContext context) {
    Navigator.pushNamed(context, chat);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
