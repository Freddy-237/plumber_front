import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'api_client.dart';

class ChatService {
  final Dio _dio = apiClient;

  // ==================== Messages ====================

  /// Récupérer tous les messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await _dio.get('/api/chat/messages');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['messages'] ?? []);
        return data.map((json) => Message.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } on DioException catch (e) {
      debugPrint('Error getting messages: ${e.message}');
      rethrow;
    }
  }

  /// Envoyer un message texte
  Future<Message> sendTextMessage({
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat/send',
        data: {
          'message': text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Créer un message à partir de la réponse
        return Message(
          id: response.data['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '', // Sera rempli par le serveur
          userName: '', // Sera rempli après rechargement
          text: text,
          time: DateTime.now(),
        );
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      debugPrint('Error sending message: ${e.message}');
      rethrow;
    }
  }

  /// Envoyer un message vocal
  Future<Message> sendAudioMessage({
    required String conversationId,
    required String audioPath,
    required String senderId,
    required Duration duration,
  }) async {
    try {
      // Détecter l'extension du fichier
      final extension = audioPath.split('.').last.toLowerCase();
      final filename =
          'audio_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Préparer le multipart
      final formData = FormData.fromMap({
        'senderId': senderId,
        'type': 'audio',
        'duration': duration.inSeconds,
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: filename,
        ),
      });

      final response = await _dio.post(
        '/conversations/$conversationId/messages',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Message.fromJson(response.data['message']);
      }
      throw Exception('Failed to send audio message');
    } on DioException catch (e) {
      debugPrint('Error sending audio: ${e.message}');
      rethrow;
    }
  }

  /// Envoyer une image
  Future<Message> sendImageMessage({
    required String conversationId,
    required String imagePath,
    required String senderId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'senderId': senderId,
        'type': 'image',
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/conversations/$conversationId/messages',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Message.fromJson(response.data['message']);
      }
      throw Exception('Failed to send image');
    } on DioException catch (e) {
      debugPrint('Error sending image: ${e.message}');
      rethrow;
    }
  }

  // ==================== Conversations ====================

  /// Récupérer toutes les conversations de l'utilisateur
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/conversations');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['conversations'] ?? []);
      }
      throw Exception('Failed to load conversations');
    } on DioException catch (e) {
      debugPrint('Error getting conversations: ${e.message}');
      rethrow;
    }
  }

  /// Créer une nouvelle conversation
  Future<Map<String, dynamic>> createConversation({
    required String userId,
    required List<String> participants,
    String? title,
  }) async {
    try {
      final response = await _dio.post(
        '/conversations',
        data: {
          'createdBy': userId,
          'participants': participants,
          'title': title,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['conversation'];
      }
      throw Exception('Failed to create conversation');
    } on DioException catch (e) {
      debugPrint('Error creating conversation: ${e.message}');
      rethrow;
    }
  }

  // ==================== Typing Indicator ====================

  /// Indiquer qu'un utilisateur est en train d'écrire
  Future<void> sendTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _dio.post(
        '/conversations/$conversationId/typing',
        data: {
          'userId': userId,
          'isTyping': isTyping,
        },
      );
    } on DioException catch (e) {
      debugPrint('Error sending typing indicator: ${e.message}');
      // Ne pas throw pour ne pas bloquer l'interface
    }
  }

  // ==================== Message Status ====================

  /// Marquer un message comme lu
  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _dio.put(
        '/conversations/$conversationId/messages/$messageId/read',
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      debugPrint('Error marking message as read: ${e.message}');
    }
  }

  /// Marquer tous les messages d'une conversation comme lus
  Future<void> markAllMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _dio.put(
        '/conversations/$conversationId/messages/read-all',
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      debugPrint('Error marking all messages as read: ${e.message}');
    }
  }

  // ==================== File Download ====================

  /// Télécharger un fichier (audio ou image)
  Future<String> downloadFile({
    required String fileUrl,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    try {
      await _dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: onProgress,
      );
      return savePath;
    } on DioException catch (e) {
      debugPrint('Error downloading file: ${e.message}');
      rethrow;
    }
  }

  // ==================== Search ====================

  /// Rechercher des messages dans une conversation
  Future<List<Message>> searchMessages({
    required String conversationId,
    required String query,
  }) async {
    try {
      final response = await _dio.get(
        '/conversations/$conversationId/messages/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['messages'] ?? [];
        return data.map((json) => Message.fromJson(json)).toList();
      }
      throw Exception('Failed to search messages');
    } on DioException catch (e) {
      debugPrint('Error searching messages: ${e.message}');
      rethrow;
    }
  }

  // ==================== Delete Message ====================

  /// Supprimer un message
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _dio.delete(
        '/conversations/$conversationId/messages/$messageId',
      );
    } on DioException catch (e) {
      debugPrint('Error deleting message: ${e.message}');
      rethrow;
    }
  }
}
