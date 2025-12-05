# Guide d'envoi d'audios et d'images via Socket.io

## ✅ Fonctionnalités implémentées

### 1. **Envoi d'audio** 🎤
- Enregistrement audio via le microphone
- Conversion en fichier AAC
- Envoi via Socket.io avec bytes du fichier
- Sauvegarde côté serveur dans `/uploads`
- Stockage en base de données dans la table `attachments`

### 2. **Envoi d'images** 📷
- Sélection depuis la galerie
- Capture via la caméra
- Compression automatique (max 1920x1920, qualité 85%)
- Envoi via Socket.io avec bytes du fichier
- Support JPEG, PNG, GIF, WebP

### 3. **Support des pièces jointes multiples** 📎
- Le backend accepte plusieurs fichiers dans un seul message
- Le modèle `Message` inclut la liste `attachments`
- Chaque attachment contient: id, filename, url, mimeType, size

## 📁 Fichiers modifiés/créés

### Services créés:
1. **`lib/services/file_picker_service.dart`** - Service de sélection d'images
   - `pickImage()` - Galerie
   - `takePhoto()` - Caméra
   - `pickMultipleImages()` - Sélection multiple

2. **`lib/services/socketio_service.dart`** - Méthodes ajoutées:
   - `sendMessage(text)` - Texte simple
   - `sendFile(fileBytes, fileName, mimeType, message)` - Fichier unique
   - `sendMultipleFiles(files, message)` - Fichiers multiples

### Providers mis à jour:
3. **`lib/providers/chat_provider.dart`** - Méthodes ajoutées:
   - `sendAudio(audioBytes, fileName, message)` - Envoi audio
   - `sendImage(imageBytes, fileName, message)` - Envoi image
   - `sendMultipleImages(images, message)` - Envoi multiple images

### Modèles mis à jour:
4. **`lib/models/message_model.dart`**:
   - Classe `Attachment` créée avec: id, filename, url, mimeType, size
   - Propriété `attachments` ajoutée au modèle `Message`
   - Parsing automatique des attachments depuis JSON
   - Détection automatique audio/image depuis attachments

### Screens mis à jour:
5. **`lib/screens/chat_screen.dart`**:
   - Import `dart:io` pour File
   - Utilisation de `FilePickerService`
   - Méthode `_onPickPhoto()` complète avec dialogue galerie/caméra
   - Méthode `_stopAndSendRecording()` avec envoi réel via Socket.io

## 🔧 Utilisation

### Envoyer un message avec audio:
```dart
await ref.read(chatProvider.notifier).sendAudio(
  audioBytes: audioBytes,      // List<int>
  fileName: 'audio_123.aac',
  message: 'Écoutez ça!',      // Optionnel
);
```

### Envoyer un message avec image:
```dart
await ref.read(chatProvider.notifier).sendImage(
  imageBytes: imageBytes,      // List<int>
  fileName: 'photo_123.jpg',
  message: 'Regardez!',        // Optionnel
);
```

### Envoyer plusieurs images:
```dart
await ref.read(chatProvider.notifier).sendMultipleImages(
  images: [
    {'fileBytes': bytes1, 'fileName': 'img1.jpg', 'mimeType': 'image/jpeg'},
    {'fileBytes': bytes2, 'fileName': 'img2.png', 'mimeType': 'image/png'},
  ],
  message: 'Voici les photos',  // Optionnel
);
```

## 🗄️ Structure de la base de données

### Table `messages`:
```sql
CREATE TABLE messages (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36),
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table `attachments`:
```sql
CREATE TABLE attachments (
  id VARCHAR(36) PRIMARY KEY,
  message_id VARCHAR(36),
  filename VARCHAR(255),
  url VARCHAR(500),
  mime_type VARCHAR(100),
  size INT,
  FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);
```

## 📡 Payload Socket.io

### Message texte simple:
```json
{
  "message": "Hello!"
}
```

### Message avec fichier unique:
```json
{
  "message": "Écoutez ça",
  "file": {
    "name": "audio.aac",
    "type": "audio/aac",
    "size": 45678,
    "buffer": {
      "type": "Buffer",
      "data": [255, 216, 255, ...]
    }
  }
}
```

### Message avec fichiers multiples:
```json
{
  "message": "Voici les photos",
  "files": [
    {
      "name": "photo1.jpg",
      "type": "image/jpeg",
      "size": 123456,
      "buffer": {"type": "Buffer", "data": [...]}
    },
    {
      "name": "photo2.png",
      "type": "image/png",
      "size": 234567,
      "buffer": {"type": "Buffer", "data": [...]}
    }
  ]
}
```

## 🔒 Sécurité

- ✅ Authentification JWT vérifiée côté serveur
- ✅ Validation de la taille des fichiers côté serveur
- ✅ Validation des types MIME
- ✅ Sauvegarde sécurisée avec UUID pour les noms de fichiers
- ✅ Protection contre les injections SQL (parameterized queries)

## 🚀 Prochaines étapes

1. **Affichage des images/audios dans le chat**:
   - Créer des widgets pour afficher les images dans les bulles de message
   - Créer un lecteur audio pour les messages audio
   - Gérer le téléchargement et le cache des médias

2. **Optimisations**:
   - Compression côté client avant envoi
   - Thumbnail/preview pour les images
   - Indicateur de progression lors de l'upload
   - Retry automatique en cas d'échec

3. **Fonctionnalités supplémentaires**:
   - Envoi de vidéos
   - Envoi de documents (PDF, etc.)
   - Géolocalisation
   - Messages vocaux avec forme d'onde

## 🐛 Démarrage du serveur

**IMPORTANT**: Votre serveur Node.js doit écouter sur toutes les interfaces:

```javascript
const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on port ${PORT}`);
});
```

**Configuration actuelle de l'app Flutter**:
- **Android emulator**: `http://10.0.2.2:3000`
- **Windows desktop**: `http://localhost:3000`
- **iOS simulator**: `http://localhost:3000`

Pour tester simultanément sur Android et Windows:
1. Changer Windows vers `http://[VOTRE_IP_WIFI]:3000`
2. Démarrer serveur avec `0.0.0.0` binding
3. Autoriser port 3000 dans le pare-feu Windows
