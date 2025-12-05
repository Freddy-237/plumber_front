import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/socketio_service.dart';
import 'auth_provider.dart';

class ChatState {
  final List<Map<String, String?>> users;
  final String currentUserId;
  final String? currentConversationId;
  final List<Message> messages;
  final bool isTyping;
  final String? typingUserId; // ID de l'utilisateur en train d'écrire
  final String? typingUserName; // Nom de l'utilisateur en train d'écrire
  final bool isLoading;
  final bool isConnected;
  final String? error;

  ChatState({
    required this.users,
    required this.currentUserId,
    this.currentConversationId,
    required this.messages,
    this.isTyping = false,
    this.typingUserId,
    this.typingUserName,
    this.isLoading = false,
    this.isConnected = false,
    this.error,
  });

  ChatState copyWith({
    List<Map<String, String?>>? users,
    String? currentUserId,
    String? currentConversationId,
    List<Message>? messages,
    bool? isTyping,
    String? typingUserId,
    String? typingUserName,
    bool? isLoading,
    bool? isConnected,
    String? error,
  }) {
    return ChatState(
      users: users ?? this.users,
      currentUserId: currentUserId ?? this.currentUserId,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
      typingUserName: typingUserName ?? this.typingUserName,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SocketIOService _socketService = SocketIOService();
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(ChatState(
          users: [],
          currentUserId: 'default_user',
          messages: [],
        )) {
    _initializeSocketIO();
  }

  // ==================== Initialization ====================

  void _initializeSocketIO() {
    // Écouter les nouveaux messages
    _socketService.messageStream.listen((message) {
      _addMessageToState(message);
    });

    // Écouter l'historique initial
    _socketService.historyStream.listen((history) {
      debugPrint('📜 Historique reçu: ${history.length} messages');
      state = state.copyWith(messages: history);
    });

    // Écouter les erreurs
    _socketService.errorStream.listen((error) {
      debugPrint('❌ Erreur Socket.io: $error');
      state = state.copyWith(error: error);
    });

    // Écouter l'état de connexion
    _socketService.connectionStream.listen((isConnected) {
      state = state.copyWith(isConnected: isConnected);

      // Demander l'historique dès que la connexion est établie
      if (isConnected) {
        debugPrint('✅ Socket.io connecté! Demande de l\'historique...');
        _socketService.requestHistory();
      }
    });

    // Écouter les événements de typing
    _socketService.typingStream.listen((typingData) {
      final userId = typingData['userId'] as String?;
      final userName = typingData['userName'] as String?;
      final isTyping = typingData['isTyping'] as bool? ?? false;

      // Ne pas afficher si c'est l'utilisateur actuel qui écrit
      if (userId != null && userId != state.currentUserId) {
        if (isTyping && userName != null) {
          state = state.copyWith(
            isTyping: true,
            typingUserId: userId,
            typingUserName: userName,
          );
        } else {
          state = state.copyWith(
            isTyping: false,
            typingUserId: null,
            typingUserName: null,
          );
        }
      }
    });
  }

  // ==================== Connection Management ====================

  Future<void> connectToConversation() async {
    try {
      state = state.copyWith(isLoading: true);

      // Récupérer le token de l'utilisateur connecté
      final authState = _ref.read(authStateProvider);
      if (authState.user == null || authState.user!.token.isEmpty) {
        throw Exception('Utilisateur non authentifié');
      }

      final token = authState.user!.token;
      final userId = authState.user!.id;
      final userName = authState.user!.name;
      final userRole =
          authState.user!.role == UserType.plumber ? 'plumber' : 'client';
      debugPrint('🔌 Connexion Socket.io avec token');
      debugPrint('  - User ID: $userId');
      debugPrint('  - User Name: $userName');
      debugPrint('  - User Role: $userRole');

      // Mettre à jour le currentUserId et ajouter l'utilisateur dans la liste
      state = state.copyWith(
        currentUserId: userId,
        users: [
          {
            'id': userId,
            'name': userName,
            'role': userRole,
            'avatar': authState.user!.profilePicture,
          }
        ],
      );

      // Connecter au serveur Socket.io avec le token
      await _socketService.connect(token: token);

      // Charger l'historique des messages depuis la DB
      await loadMessages();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Error connecting to conversation: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de se connecter: $e',
      );
    }
  }

  Future<void> disconnectFromConversation() async {
    await _socketService.disconnect();
    state = state.copyWith(
      currentConversationId: null,
      isConnected: false,
    );
  }

  // ==================== Message Loading ====================

  Future<void> loadMessages() async {
    try {
      debugPrint('\n📚 Attente de l\'historique via Socket.io...');
      // L'historique sera demandé automatiquement quand Socket.io se connecte
      // via le listener connectionStream dans _initializeSocketIO()

      // Attendre un peu pour laisser le temps à la connexion de s'établir
      await Future.delayed(const Duration(milliseconds: 2000));

      debugPrint('✅ Attente terminée');
      debugPrint('   Nombre de messages reçus: ${state.messages.length}\n');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des messages: $e\n');
      state = state.copyWith(
        error: 'Impossible de charger les messages: $e',
      );
    }
  } // ==================== Send Messages ====================

  Future<void> sendMessage(String text, {String? replyToMessageId}) async {
    try {
      // Envoyer via Socket.io (le serveur sauvegarde en DB et broadcast)
      _socketService.sendMessage(text, replyToMessageId: replyToMessageId);
      debugPrint('📤 Message envoyé via Socket.io');
    } catch (e) {
      debugPrint('Error sending message: $e');
      state = state.copyWith(error: 'Impossible d\'envoyer le message: $e');
    }
  }

  /// Envoyer un fichier audio
  Future<void> sendAudio({
    required List<int> audioBytes,
    required String fileName,
    String? message,
  }) async {
    try {
      // Détecter le type MIME basé sur l'extension du fichier
      String mimeType = 'audio/mpeg'; // MP3 par défaut
      if (fileName.toLowerCase().endsWith('.mp3')) {
        mimeType = 'audio/mpeg';
      } else if (fileName.toLowerCase().endsWith('.aac')) {
        mimeType = 'audio/aac';
      } else if (fileName.toLowerCase().endsWith('.m4a')) {
        mimeType = 'audio/mp4';
      } else if (fileName.toLowerCase().endsWith('.wav')) {
        mimeType = 'audio/wav';
      }

      await _socketService.sendFile(
        fileBytes: audioBytes,
        fileName: fileName,
        mimeType: mimeType,
        message: message,
      );
      debugPrint('📤 Audio envoyé via Socket.io');
    } catch (e) {
      debugPrint('Error sending audio: $e');
      state = state.copyWith(error: 'Impossible d\'envoyer l\'audio: $e');
    }
  }

  /// Envoyer une image
  Future<void> sendImage({
    required List<int> imageBytes,
    required String fileName,
    String? message,
    String? replyToMessageId,
  }) async {
    try {
      // Détecter le type MIME basé sur l'extension
      String mimeType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      await _socketService.sendFile(
        fileBytes: imageBytes,
        fileName: fileName,
        mimeType: mimeType,
        message: message,
        replyToMessageId: replyToMessageId,
      );
      debugPrint('📤 Image envoyée via Socket.io');
    } catch (e) {
      debugPrint('Error sending image: $e');
      state = state.copyWith(error: 'Impossible d\'envoyer l\'image: $e');
    }
  }

  /// Envoyer plusieurs fichiers (images multiples)
  Future<void> sendMultipleImages({
    required List<Map<String, dynamic>> images,
    String? message,
    String? replyToMessageId,
  }) async {
    try {
      await _socketService.sendMultipleFiles(
        files: images,
        message: message,
        replyToMessageId: replyToMessageId,
      );
      debugPrint('📤 ${images.length} images envoyées via Socket.io');
    } catch (e) {
      debugPrint('Error sending images: $e');
      state = state.copyWith(error: 'Impossible d\'envoyer les images: $e');
    }
  }

  // ==================== Typing Indicator ====================

  void setTyping(bool typing) {
    state = state.copyWith(isTyping: typing);
    // Socket.io peut gérer le typing indicator si nécessaire
  }

  /// Émettre que l'utilisateur est en train d'écrire
  void emitTyping() {
    _socketService.emitTyping();
  }

  /// Émettre que l'utilisateur a arrêté d'écrire
  void emitStoppedTyping() {
    _socketService.emitStoppedTyping();
  }

  /// Effacer l'erreur actuelle
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ==================== Helper Methods ====================

  void _addMessageToState(Message message) {
    // Vérifier si le message existe déjà pour éviter les doublons
    final messageExists = state.messages.any((msg) => msg.id == message.id);

    if (!messageExists) {
      state = state.copyWith(
        messages: [...state.messages, message],
      );
      debugPrint(
          '✅ Message ajouté: ${message.text.substring(0, message.text.length > 30 ? 30 : message.text.length)}...');
    } else {
      debugPrint('⚠️ Message déjà présent, ignoré: ${message.id}');
    }
  }

  void _replaceMessage(String oldId, Message newMessage) {
    final updatedMessages = state.messages.map((msg) {
      return msg.id == oldId ? newMessage : msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  String _getCurrentUserName() {
    final user = state.users.firstWhere(
      (u) => u['id'] == state.currentUserId,
      orElse: () => {'name': 'Unknown'},
    );
    return user['name'] ?? 'Unknown';
  }

  String? _getCurrentUserAvatar() {
    final user = state.users.firstWhere(
      (u) => u['id'] == state.currentUserId,
      orElse: () => {},
    );
    return user['avatar'];
  }

  void setCurrentUser(String id) {
    state = state.copyWith(currentUserId: id);
  }

  // ==================== Cleanup ====================

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
