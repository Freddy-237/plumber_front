import 'package:dio/dio.dart';

class ApiClient {
  // ⚠️ IMPORTANT: Change cette URL selon ton environnement
  // - Pour émulateur Android: "http://10.0.2.2:3000"
  // - Pour appareil physique: "http://[IP_DE_TON_PC]:3000" (ex: "http://192.168.1.100:3000")
  // - Pour web/desktop: "http://127.0.0.1:3000"
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:3000", // Pour émulateur Android
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  ApiClient() {
    // Ajouter un intercepteur pour logger toutes les requêtes
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('\n========== REQUEST ==========');
        print('Full URL: ${options.uri}'); // Affiche l'URL complète
        print('URL: ${options.baseUrl}${options.path}');
        print('Method: ${options.method}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        print('=============================\n');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('\n========== RESPONSE ==========');
        print('Status Code: ${response.statusCode}');
        print('Data: ${response.data}');
        print('==============================\n');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('\n========== ERROR ==========');
        print('Type: ${error.type}');
        print('Message: ${error.message}');
        print('Response: ${error.response?.data}');
        print('===========================\n');
        return handler.next(error);
      },
    ));
  }

  Dio get client => _dio;
}

final apiClient = ApiClient().client;
