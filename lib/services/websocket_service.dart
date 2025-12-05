import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/message_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _userId;
  String? _conversationId;

  // Controllers pour les streams
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Getters pour les streams
  Stream<Message> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;

  /// Connecter au WebSocket
  Future<void> connect({
    required String userId,
    required String conversationId,
    String wsUrl = 'ws://10.0.2.2:3000/ws', // URL WebSocket
  }) async {
    try {
      _userId = userId;
      _conversationId = conversationId;

      // Créer la connexion WebSocket avec les paramètres
      final uri =
          Uri.parse('$wsUrl?userId=$userId&conversationId=$conversationId');
      _channel = WebSocketChannel.connect(uri);

      _isConnected = true;
      _connectionController.add(true);
      debugPrint('✅ WebSocket connected: $wsUrl');

      // Écouter les messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Gérer les messages reçus
  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data);
      final type = json['type'];

      switch (type) {
        case 'message':
          // Nouveau message reçu
          final message = Message.fromJson(json['data']);
          _messageController.add(message);
          debugPrint('📩 New message received: ${message.text}');
          break;

        case 'typing':
          // Indicateur de frappe
          _typingController.add(json['data']);
          debugPrint('⌨️ Typing indicator: ${json['data']}');
          break;

        case 'message_read':
          // Message marqué comme lu
          debugPrint('👁️ Message read: ${json['data']}');
          break;

        case 'user_joined':
          debugPrint('👋 User joined: ${json['data']}');
          break;

        case 'user_left':
          debugPrint('👋 User left: ${json['data']}');
          break;

        default:
          debugPrint('ℹ️ Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('❌ Error handling message: $e');
    }
  }

  /// Gérer les erreurs
  void _handleError(error) {
    debugPrint('❌ WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Gérer la déconnexion
  void _handleDisconnect() {
    debugPrint('🔌 WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Envoyer un message via WebSocket
  void sendMessage(Message message) {
    if (!_isConnected || _channel == null) {
      debugPrint('⚠️ Cannot send message: not connected');
      return;
    }

    try {
      final data = {
        'type': 'message',
        'data': message.toJson(),
      };
      _channel!.sink.add(jsonEncode(data));
      debugPrint('📤 Message sent via WebSocket');
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  /// Envoyer un indicateur de frappe
  void sendTypingIndicator(bool isTyping) {
    if (!_isConnected || _channel == null) return;

    try {
      final data = {
        'type': 'typing',
        'data': {
          'userId': _userId,
          'conversationId': _conversationId,
          'isTyping': isTyping,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Error sending typing indicator: $e');
    }
  }

  /// Rejoindre une conversation
  void joinConversation(String conversationId) {
    if (!_isConnected || _channel == null) return;

    try {
      final data = {
        'type': 'join',
        'data': {
          'userId': _userId,
          'conversationId': conversationId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
      _conversationId = conversationId;
      debugPrint('🚪 Joined conversation: $conversationId');
    } catch (e) {
      debugPrint('❌ Error joining conversation: $e');
    }
  }

  /// Quitter une conversation
  void leaveConversation() {
    if (!_isConnected || _channel == null) return;

    try {
      final data = {
        'type': 'leave',
        'data': {
          'userId': _userId,
          'conversationId': _conversationId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
      debugPrint('👋 Left conversation: $_conversationId');
    } catch (e) {
      debugPrint('❌ Error leaving conversation: $e');
    }
  }

  /// Déconnecter le WebSocket
  Future<void> disconnect() async {
    try {
      leaveConversation();
      await _channel?.sink.close(status.goingAway);
      _isConnected = false;
      _connectionController.add(false);
      debugPrint('🔌 WebSocket disconnected properly');
    } catch (e) {
      debugPrint('❌ Error disconnecting: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
  }
}
