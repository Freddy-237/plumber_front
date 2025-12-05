# 📂 Structure du Chat - Refactorisation

Le code du chat a été refactorisé pour une meilleure organisation et maintenabilité.

## 📁 Nouvelle Architecture

### **Widgets** (`lib/widgets/chat/`)

#### `chat_avatar.dart`
Widget réutilisable pour afficher les avatars des utilisateurs avec badge pour les plombiers.

```dart
ChatAvatar(
  name: 'John Doe',
  isMe: false,
  role: 'plumber', // Optionnel, affiche le badge
  avatarUrl: 'https://...',
  radius: 20.0,
)
```

#### `chat_message_bubble.dart`
Bulle de message qui gère l'affichage de tous les types de contenu (texte, image, audio).

```dart
ChatMessageBubble(
  message: message,
  isMe: true,
  authorRole: 'plumber',
)
```

#### `chat_typing_indicator.dart`
Indicateur d'écriture animé.

```dart
ChatTypingIndicator()
```

#### `chat_app_bar.dart`
En-tête personnalisé du chat.

```dart
ChatAppBar(
  title: 'Groupe Plombiers',
  subtitle: '12 en ligne',
  onMorePressed: () {},
)
```

#### `chat_input_bar.dart`
Barre de saisie avec boutons pour envoyer texte, audio et photos.

```dart
ChatInputBar(
  controller: textController,
  onSendMessage: () {},
  onRecordAudio: () {},
  onPickPhoto: () {},
  isRecording: false,
  onTextChanged: (text) {},
)
```

#### `audio_player_widget.dart`
Lecteur audio interactif avec barre de progression.

```dart
AudioPlayerWidget(
  audioPath: '/path/to/audio.aac',
  duration: Duration(seconds: 30),
  iconColor: Colors.white,
)
```

---

### **Services** (`lib/services/`)

#### `audio_recorder_service.dart`
Service d'enregistrement audio avec `flutter_sound`.

**Méthodes:**
- `initialize()` - Initialise le recorder
- `dispose()` - Nettoie les ressources
- `requestPermission()` - Demande la permission micro
- `startRecording()` - Démarre l'enregistrement
- `stopRecording()` - Arrête et retourne `{path, duration}`
- `cancelRecording()` - Annule l'enregistrement

**Propriétés:**
- `isInitialized` - État d'initialisation
- `isRecording` - État d'enregistrement
- `recordingPath` - Chemin du fichier en cours

#### `image_picker_service.dart`
Service de sélection d'images avec `image_picker`.

**Méthodes:**
- `showImageSourceDialog(context)` - Affiche le choix caméra/galerie
- `pickImage({source, maxWidth, maxHeight, imageQuality})` - Sélectionne une image

---

### **Screens** (`lib/screens/`)

#### `chat_screen.dart` (Refactorisé)
Screen principal simplifié qui orchestre les widgets et services.

**Responsabilités:**
- Gestion de l'état local (controllers, scrolling)
- Coordination entre widgets et services
- Interaction avec le provider (chat_provider)
- Navigation et feedback utilisateur

**Taille:** ~200 lignes (vs ~600 avant)

---

## 🎯 Avantages de la Refactorisation

### ✅ **Maintenabilité**
- Code divisé en modules spécialisés
- Facile à localiser et modifier
- Responsabilités clairement définies

### ✅ **Réutilisabilité**
- Widgets indépendants réutilisables ailleurs
- Services testables isolément
- Composants découplés

### ✅ **Lisibilité**
- Fichiers plus courts et focalisés
- Hiérarchie claire
- Imports explicites

### ✅ **Testabilité**
- Services isolés facilement mockables
- Widgets testables indépendamment
- Logique métier séparée de l'UI

### ✅ **Collaboration**
- Plusieurs développeurs peuvent travailler sur différents fichiers
- Moins de conflits Git
- Code review plus simple

---

## 📦 Dépendances Utilisées

```yaml
flutter_sound: ^9.2.0          # Enregistrement audio
audioplayers: ^6.4.0           # Lecture audio
image_picker: ^1.1.0           # Sélection d'images
permission_handler: ^10.4.0    # Gestion des permissions
path_provider: ^2.0.0          # Accès aux dossiers système
```

---

## 🔄 Migration depuis l'ancienne version

L'ancienne version monolithique de `chat_screen.dart` (578 lignes) a été divisée en :
- 7 widgets modulaires
- 2 services spécialisés
- 1 screen principal simplifié (~200 lignes)

**Total:** 9 fichiers au lieu d'1, mais chacun avec une responsabilité claire et <200 lignes.
