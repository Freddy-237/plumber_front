import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message_model.dart';
import '../config/api_config.dart';

class SocketIOService {
  IO.Socket? _socket;
  bool _isConnected = false;

  // Configuration de l'URL selon la plateforme
  static String getServerUrl() => ApiConfig.getBaseUrl();

  // Controllers pour les streams
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<List<Message>> _historyController =
      StreamController<List<Message>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters pour les streams
  Stream<Message> get messageStream => _messageController.stream;
  Stream<List<Message>> get historyStream => _historyController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  bool get isConnected => _isConnected;

  /// Connecter au serveur Socket.io avec authentification JWT
  Future<void> connect({
    required String token,
    String? serverUrl,
  }) async {
    try {
      final url = serverUrl ?? getServerUrl();
      debugPrint('\n🔌 Connexion Socket.io...');
      debugPrint('  - URL: $url');
      debugPrint('  - Token: ${token.substring(0, 20)}...');

      // Décoder le token pour voir l'userId (debug)
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Ajouter padding si nécessaire
          var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
          while (normalized.length % 4 != 0) {
            normalized += '=';
          }
          final decoded = utf8.decode(base64Decode(normalized));
          debugPrint('  - Token payload: $decoded');
        }
      } catch (e) {
        debugPrint('  - Impossible de décoder le token: $e');
      }

      // Configuration Socket.io
      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Forcer WebSocket
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .setAuth({'token': token}) // 🔑 Authentification JWT
            .build(),
      );

      // Événement de connexion réussie
      _socket!.onConnect((_) {
        _isConnected = true;
        _connectionController.add(true);
        debugPrint('✅ Socket.io connecté!');
        debugPrint('✅ Socket ID: ${_socket!.id}');

        // Demander l'historique automatiquement après connexion
        debugPrint('📚 Demande automatique de l\'historique...');
        Future.delayed(Duration(milliseconds: 500), () {
          if (_isConnected && _socket != null) {
            _socket!.emit('getHistory');
            debugPrint('✅ getHistory émis automatiquement');
          }
        });
      });

      // Événement de déconnexion
      _socket!.onDisconnect((_) {
        _isConnected = false;
        _connectionController.add(false);
        debugPrint('🔌 Socket.io déconnecté');
      });

      // Événement d'erreur de connexion
      _socket!.onConnectError((error) {
        _isConnected = false;
        _connectionController.add(false);
        debugPrint('❌ Erreur de connexion Socket.io: $error');
        _errorController.add('Erreur de connexion: $error');
      });

      // Événement: Recevoir l'historique initial
      _socket!.on('chatHistory', (data) {
        debugPrint('\n📜 Historique reçu!');
        debugPrint('📜 Type de data: ${data.runtimeType}');
        debugPrint('📜 Data: $data');

        try {
          if (data == null) {
            debugPrint('⚠️ Data null, historique vide');
            _historyController.add([]);
            return;
          }

          if (data is! List) {
            debugPrint(
                '❌ Data n\'est pas une List, c\'est: ${data.runtimeType}');
            return;
          }

          debugPrint('📜 Nombre de messages: ${data.length}');

          final List<Message> history = (data as List)
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();

          debugPrint('✅ Historique parsé: ${history.length} messages');
          _historyController.add(history);
        } catch (e, stackTrace) {
          debugPrint('❌ Erreur parsing historique: $e');
          debugPrint('❌ Stack: $stackTrace');
        }
      });

      // Événement: Nouveau message
      _socket!.on('newMessage', (data) {
        debugPrint('\n📩 Nouveau message reçu');
        debugPrint('  - Data brut: ${jsonEncode(data)}');
        if (data is Map && data.containsKey('attachments')) {
          debugPrint(
              '  - Attachments dans data: ${jsonEncode(data['attachments'])}');
          debugPrint(
              '  - Nombre d\'attachments: ${data['attachments'].length}');
        } else {
          debugPrint('  - ⚠️ AUCUN attachments dans le JSON reçu');
        }
        try {
          final message = Message.fromJson(data as Map<String, dynamic>);
          _messageController.add(message);
          debugPrint('  - Message: ${message.text}');
          debugPrint('  - Auteur: ${message.userName}');
          debugPrint(
              '  - Attachments parsés: ${message.attachments.length} (images: ${message.attachments.where((a) => a.isImage).length})');
        } catch (e) {
          debugPrint('❌ Erreur parsing message: $e');
        }
      });

      // Événement: Erreur serveur
      _socket!.on('errorMessage', (data) {
        debugPrint('❌ Erreur serveur: $data');
        String errorMsg = 'Erreur inconnue';

        if (data is Map) {
          // Extraction du message d'erreur
          if (data['message'] != null) {
            errorMsg = data['message'];
          } else if (data['error'] != null) {
            errorMsg = data['error'];
            // Si c'est une erreur de clé primaire, afficher un message plus clair
            if (errorMsg.contains('Duplicate entry') &&
                errorMsg.contains('PRIMARY')) {
              errorMsg =
                  'Erreur serveur: problème de génération d\'ID. Contactez l\'administrateur.';
            }
          }
        } else if (data is String) {
          errorMsg = data;
        }

        _errorController.add(errorMsg);
      });

      // Événement: Utilisateur en train d'écrire
      _socket!.on('userTyping', (data) {
        debugPrint('✍️ ${data['userName']} est en train d\'écrire...');
        _typingController.add({
          'userId': data['userId'],
          'userName': data['userName'],
          'isTyping': true,
        });
      });

      // Événement: Utilisateur a arrêté d'écrire
      _socket!.on('userStoppedTyping', (data) {
        debugPrint('✍️ Utilisateur ${data['userId']} a arrêté d\'écrire');
        _typingController.add({
          'userId': data['userId'],
          'isTyping': false,
        });
      });

      // Événement: Erreur du serveur (format générique 'error')
      _socket!.on('error', (data) {
        debugPrint('❌ Erreur serveur (error event): $data');
        String errorMsg = 'Erreur inconnue';

        if (data is Map) {
          if (data['error'] != null) {
            errorMsg = data['error'].toString();
            // Détecter l'erreur de clé primaire
            if (errorMsg.contains('Duplicate entry') &&
                errorMsg.contains('PRIMARY')) {
              errorMsg =
                  'Erreur serveur: ID invalide lors de la sauvegarde. Le serveur doit générer un UUID valide.';
            }
          } else if (data['message'] != null) {
            errorMsg = data['message'];
            // Détecter erreur de token invalide
            if (errorMsg.contains('Invalid token') ||
                errorMsg.contains('invalid signature') ||
                errorMsg.contains('jwt expired')) {
              errorMsg =
                  '🔑 Token expiré ou invalide. Veuillez vous reconnecter.';
            }
          }
        } else if (data is String) {
          errorMsg = data;
          // Détecter erreur de token invalide
          if (errorMsg.contains('Invalid token') ||
              errorMsg.contains('invalid signature') ||
              errorMsg.contains('jwt expired')) {
            errorMsg =
                '🔑 Token expiré ou invalide. Veuillez vous reconnecter.';
          }
        }

        _errorController.add(errorMsg);
      });

      // Événement: Erreur générale
      _socket!.onError((error) {
        debugPrint('❌ Socket.io error: $error');
        _errorController.add('Erreur: $error');
      });

      // Connecter
      _socket!.connect();
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion Socket.io: $e');
      _isConnected = false;
      _connectionController.add(false);
      _errorController.add('Erreur de connexion: $e');
      rethrow;
    }
  }

  /// Demander explicitement l'historique des messages
  void requestHistory() {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Impossible de demander l\'historique: non connecté');
      return;
    }

    try {
      debugPrint('\n📚 Demande de l\'historique au serveur...');
      _socket!.emit('getHistory');
      debugPrint('✅ Demande envoyée');
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande d\'historique: $e');
    }
  }

  /// Envoyer un message texte via Socket.io
  void sendMessage(String text, {String? replyToMessageId}) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Impossible d\'envoyer: non connecté');
      _errorController.add('Non connecté au serveur');
      return;
    }

    try {
      debugPrint('\n📤 Envoi message Socket.io');
      debugPrint('  - Message: $text');
      if (replyToMessageId != null) {
        debugPrint('  - En réponse à: $replyToMessageId');
      }

      // Émettre l'événement 'sendMessage' avec le payload
      _socket!.emit('sendMessage', {
        'message': text,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      });

      debugPrint('✅ Message envoyé');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi: $e');
      _errorController.add('Erreur d\'envoi: $e');
    }
  }

  /// Envoyer un fichier (audio/image) via Socket.io
  Future<void> sendFile({
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
    String? message,
    String? replyToMessageId,
  }) async {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Impossible d\'envoyer: non connecté');
      _errorController.add('Non connecté au serveur');
      return;
    }

    try {
      debugPrint('\n📤 Envoi fichier Socket.io');
      debugPrint('  - Nom: $fileName');
      debugPrint('  - Type: $mimeType');
      debugPrint('  - Taille: ${fileBytes.length} bytes');
      if (message != null && message.isNotEmpty) {
        debugPrint('  - Message: $message');
      }
      if (replyToMessageId != null) {
        debugPrint('  - En réponse à: $replyToMessageId');
      }

      // Préparer le payload avec le fichier
      final payload = {
        'message': message ?? '',
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        'file': {
          'name': fileName,
          'type': mimeType,
          'size': fileBytes.length,
          'buffer': {
            'type': 'Buffer',
            'data': fileBytes,
          }
        }
      };

      // Émettre l'événement 'sendMessage' avec le fichier
      _socket!.emit('sendMessage', payload);

      debugPrint('✅ Fichier envoyé');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi du fichier: $e');
      _errorController.add('Erreur d\'envoi du fichier: $e');
    }
  }

  /// Envoyer plusieurs fichiers via Socket.io
  Future<void> sendMultipleFiles({
    required List<Map<String, dynamic>> files,
    String? message,
    String? replyToMessageId,
  }) async {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Impossible d\'envoyer: non connecté');
      _errorController.add('Non connecté au serveur');
      return;
    }

    try {
      debugPrint('\n📤 Envoi de ${files.length} fichiers Socket.io');
      if (message != null && message.isNotEmpty) {
        debugPrint('  - Message: $message');
      }
      if (replyToMessageId != null) {
        debugPrint('  - En réponse à: $replyToMessageId');
      }

      // Préparer le payload avec plusieurs fichiers
      final payload = {
        'message': message ?? '',
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        'files': files.map((file) {
          return {
            'name': file['fileName'],
            'type': file['mimeType'],
            'size': (file['fileBytes'] as List<int>).length,
            'buffer': {
              'type': 'Buffer',
              'data': file['fileBytes'],
            }
          };
        }).toList(),
      };

      // Émettre l'événement 'sendMessage' avec les fichiers
      _socket!.emit('sendMessage', payload);

      debugPrint('✅ Fichiers envoyés');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi des fichiers: $e');
      _errorController.add('Erreur d\'envoi des fichiers: $e');
    }
  }

  /// Émettre que l'utilisateur est en train d'écrire
  void emitTyping() {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('userTyping');
    } catch (e) {
      debugPrint('❌ Erreur émission typing: $e');
    }
  }

  /// Émettre que l'utilisateur a arrêté d'écrire
  void emitStoppedTyping() {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('userStoppedTyping');
    } catch (e) {
      debugPrint('❌ Erreur émission stopped typing: $e');
    }
  }

  /// Déconnecter
  Future<void> disconnect() async {
    try {
      debugPrint('🔌 Déconnexion Socket.io...');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      _connectionController.add(false);
      debugPrint('✅ Socket.io déconnecté');
    } catch (e) {
      debugPrint('❌ Erreur déconnexion: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    disconnect();
    _messageController.close();
    _historyController.close();
    _errorController.close();
    _connectionController.close();
  }
}
