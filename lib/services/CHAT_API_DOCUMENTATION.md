# 📡 Documentation des Services Chat API

Cette documentation explique comment utiliser les services de chat pour communiquer avec le backend.

## 🏗️ Architecture

```
┌─────────────────┐
│  ChatScreen     │  ← UI Layer
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  ChatProvider   │  ← State Management (Riverpod)
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┐
         ↓                  ↓                  ↓
┌────────────────┐  ┌──────────────┐  ┌──────────────┐
│  ChatService   │  │  WebSocket   │  │  Other       │
│  (REST API)    │  │  Service     │  │  Services    │
└────────────────┘  └──────────────┘  └──────────────┘
         │                  │
         └──────┬───────────┘
                ↓
        ┌──────────────┐
        │   Backend    │
        │   Server     │
        └──────────────┘
```

---

## 📦 Services Disponibles

### 1. **ChatService** (`chat_service.dart`)
Service REST API pour les opérations CRUD sur les messages et conversations.

### 2. **WebSocketService** (`websocket_service.dart`)
Service temps réel pour la communication instantanée (messages, typing indicators, etc.).

---

## 🔧 Configuration

### URLs de Connexion

Dans `api_client.dart` et `websocket_service.dart`, configurez les URLs selon votre environnement :

```dart
// REST API
baseUrl: "http://10.0.2.2:3000"  // Émulateur Android
baseUrl: "http://192.168.1.100:3000"  // Appareil physique
baseUrl: "http://127.0.0.1:3000"  // Web/Desktop

// WebSocket
wsUrl: 'ws://10.0.2.2:3000/ws'  // Émulateur Android
wsUrl: 'ws://192.168.1.100:3000/ws'  // Appareil physique
```

---

## 📝 Utilisation du ChatService

### Récupérer les messages

```dart
final chatService = ChatService();

try {
  final messages = await chatService.getMessages('conversation_id');
  print('Messages chargés: ${messages.length}');
} catch (e) {
  print('Erreur: $e');
}
```

### Envoyer un message texte

```dart
final message = await chatService.sendTextMessage(
  conversationId: 'conv_123',
  text: 'Bonjour!',
  senderId: 'user_456',
);
```

### Envoyer un message vocal

```dart
final message = await chatService.sendAudioMessage(
  conversationId: 'conv_123',
  audioPath: '/path/to/audio.aac',
  senderId: 'user_456',
  duration: Duration(seconds: 30),
);
```

### Envoyer une image

```dart
final message = await chatService.sendImageMessage(
  conversationId: 'conv_123',
  imagePath: '/path/to/image.jpg',
  senderId: 'user_456',
);
```

### Gérer les conversations

```dart
// Récupérer toutes les conversations
final conversations = await chatService.getConversations('user_456');

// Créer une nouvelle conversation
final newConv = await chatService.createConversation(
  userId: 'user_456',
  participants: ['user_789', 'user_101'],
  title: 'Groupe Plombiers',
);
```

### Indicateurs de frappe

```dart
// Indiquer qu'on écrit
await chatService.sendTypingIndicator(
  conversationId: 'conv_123',
  userId: 'user_456',
  isTyping: true,
);

// Arrêter d'écrire
await chatService.sendTypingIndicator(
  conversationId: 'conv_123',
  userId: 'user_456',
  isTyping: false,
);
```

---

## 🔌 Utilisation du WebSocketService

### Se connecter

```dart
final wsService = WebSocketService();

await wsService.connect(
  userId: 'user_456',
  conversationId: 'conv_123',
  wsUrl: 'ws://10.0.2.2:3000/ws',
);
```

### Écouter les nouveaux messages

```dart
wsService.messageStream.listen((message) {
  print('Nouveau message: ${message.text}');
  // Mettre à jour l'UI
});
```

### Écouter les indicateurs de frappe

```dart
wsService.typingStream.listen((data) {
  final isTyping = data['isTyping'];
  final userId = data['userId'];
  print('$userId est en train d\'écrire: $isTyping');
});
```

### Écouter l'état de connexion

```dart
wsService.connectionStream.listen((isConnected) {
  if (isConnected) {
    print('✅ Connecté au WebSocket');
  } else {
    print('❌ Déconnecté du WebSocket');
  }
});
```

### Envoyer un message via WebSocket

```dart
final message = Message(
  id: 'msg_123',
  userId: 'user_456',
  userName: 'John Doe',
  text: 'Hello!',
  time: DateTime.now(),
);

wsService.sendMessage(message);
```

### Rejoindre/Quitter une conversation

```dart
// Rejoindre
wsService.joinConversation('conv_789');

// Quitter
wsService.leaveConversation();
```

### Se déconnecter

```dart
await wsService.disconnect();
```

---

## 🎯 Utilisation avec le Provider

Le `ChatProvider` intègre automatiquement les deux services :

### Connexion à une conversation

```dart
// Dans le widget
ref.read(chatProvider.notifier).connectToConversation('conv_123');
```

### Envoyer des messages

```dart
// Message texte
ref.read(chatProvider.notifier).sendMessage('Bonjour!');

// Message vocal
ref.read(chatProvider.notifier).sendAudio(
  duration: Duration(seconds: 30),
  audioUrl: '/path/to/audio.aac',
);

// Image
ref.read(chatProvider.notifier).sendImage('/path/to/image.jpg');
```

### Indicateur de frappe

```dart
// Commencer à écrire
ref.read(chatProvider.notifier).setTyping(true);

// Arrêter d'écrire
ref.read(chatProvider.notifier).setTyping(false);
```

### Observer l'état

```dart
final chat = ref.watch(chatProvider);

if (chat.isLoading) {
  return CircularProgressIndicator();
}

if (chat.error != null) {
  return Text('Erreur: ${chat.error}');
}

if (!chat.isConnected) {
  return Text('Déconnecté');
}

// Afficher les messages
return ListView.builder(
  itemCount: chat.messages.length,
  itemBuilder: (context, index) {
    final message = chat.messages[index];
    return MessageBubble(message: message);
  },
);
```

---

## 🔐 Format des Messages

### Structure JSON attendue du backend

```json
{
  "id": "msg_123",
  "userId": "user_456",
  "userName": "John Doe",
  "text": "Bonjour!",
  "type": "text",
  "createdAt": "2025-11-22T10:30:00Z",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

### Message Audio

```json
{
  "id": "msg_124",
  "userId": "user_456",
  "userName": "John Doe",
  "text": "[Message vocal]",
  "type": "audio",
  "audioUrl": "https://example.com/audio.aac",
  "audioDuration": 30,
  "createdAt": "2025-11-22T10:31:00Z"
}
```

### Message Image

```json
{
  "id": "msg_125",
  "userId": "user_456",
  "userName": "John Doe",
  "text": "[Photo]",
  "type": "image",
  "imageUrl": "https://example.com/image.jpg",
  "createdAt": "2025-11-22T10:32:00Z"
}
```

---

## 🚨 Gestion des Erreurs

### Intercepter les erreurs

```dart
try {
  await chatService.sendTextMessage(...);
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Non autorisé - rediriger vers login
  } else if (e.response?.statusCode == 404) {
    // Conversation non trouvée
  } else if (e.type == DioExceptionType.connectionTimeout) {
    // Timeout
  } else {
    // Autre erreur
  }
}
```

### Observer les erreurs dans le provider

```dart
ref.listen<ChatState>(chatProvider, (previous, next) {
  if (next.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.error!)),
    );
  }
});
```

---

## 🧪 Mode Développement

### Logs détaillés

Les logs sont automatiquement activés dans `api_client.dart` :

```
========== REQUEST ==========
URL: http://10.0.2.2:3000/conversations/123/messages
Method: POST
Headers: {...}
Data: {...}
=============================

========== RESPONSE ==========
Status Code: 201
Data: {...}
==============================
```

### Simuler des délais

```dart
await Future.delayed(Duration(seconds: 2));
```

---

## 📊 Endpoints Backend Requis

Le backend doit implémenter les endpoints suivants :

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/conversations/:id/messages` | Récupérer les messages |
| POST | `/conversations/:id/messages` | Envoyer un message |
| GET | `/users/:id/conversations` | Récupérer les conversations |
| POST | `/conversations` | Créer une conversation |
| POST | `/conversations/:id/typing` | Indicateur de frappe |
| PUT | `/conversations/:id/messages/:msgId/read` | Marquer comme lu |
| DELETE | `/conversations/:id/messages/:msgId` | Supprimer un message |
| WS | `/ws?userId=X&conversationId=Y` | WebSocket temps réel |

---

## ✅ Checklist d'Intégration

- [ ] Configurer les URLs (REST + WebSocket)
- [ ] Tester la connexion à l'API
- [ ] Tester l'envoi de messages texte
- [ ] Tester l'envoi d'audio
- [ ] Tester l'envoi d'images
- [ ] Tester la connexion WebSocket
- [ ] Tester la réception de messages en temps réel
- [ ] Tester les indicateurs de frappe
- [ ] Gérer les erreurs de connexion
- [ ] Gérer la reconnexion automatique
- [ ] Tester sur émulateur et appareil physique

---

## 🔗 Ressources

- [Dio Documentation](https://pub.dev/packages/dio)
- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)
- [Riverpod Documentation](https://riverpod.dev/)
