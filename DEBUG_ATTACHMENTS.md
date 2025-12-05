# Vérification du flux des attachments

## 📋 Checklist de debug

### 1. Vérifier que le serveur Socket.io envoie les attachments

Dans votre `socket.js`, après la sauvegarde des attachments, vérifiez que `messageObj` les contient:

```javascript
const messageObj = {
  id,
  user_id: user.id,
  name: user.name,
  role: user.role,
  profile_picture: user.profile_picture,
  message: text,
  created_at: new Date().toISOString(),
  attachments: attachments  // ← VÉRIFIER QUE C'EST LÀ
};

console.log('📤 Envoi newMessage avec attachments:', attachments.length);
io.to("global-chat").emit("newMessage", messageObj);
```

### 2. Vérifier les logs côté Flutter

Quand un message avec image arrive, vous devriez voir:
```
📩 Nouveau message reçu
  - Data: {id: ..., attachments: [{...}]}
  - Message: ...
  - Auteur: ...
```

### 3. Vérifier le parsing du modèle Message

Dans `lib/models/message_model.dart`, le parsing doit extraire les attachments:

```dart
factory Message.fromJson(Map<String, dynamic> json) {
  // Parser les attachments si présents
  List<Attachment> attachments = [];
  if (json['attachments'] != null && json['attachments'] is List) {
    attachments = (json['attachments'] as List)
        .map((att) => Attachment.fromJson(att as Map<String, dynamic>))
        .toList();
  }
  
  print('📦 Message parsé avec ${attachments.length} attachments');
  // ...
}
```

### 4. Test complet

1. **Envoi d'une image**:
   ```
   Flutter: 📤 Envoi image: photo.jpg (123456 bytes)
   Flutter: ✅ Fichier envoyé
   ```

2. **Serveur reçoit et sauvegarde**:
   ```
   Server: Client connecté: socket-123 (user abc-456)
   Server: Fichier sauvegardé: /uploads/uuid-photo.jpg
   Server: Attachment inséré en DB: att-id-789
   Server: 📤 Envoi newMessage avec attachments: 1
   ```

3. **Flutter reçoit**:
   ```
   Flutter: 📩 Nouveau message reçu
   Flutter: 📦 Message parsé avec 1 attachments
   Flutter: Attachment: {id: att-789, url: /uploads/..., mime_type: image/jpeg}
   ```

4. **Affichage**:
   ```
   Flutter: 🖼️ Construction image URL: http://localhost:3000/uploads/uuid-photo.jpg
   Flutter: ✅ Image chargée
   ```

## 🔧 Corrections possibles

### Si les attachments ne sont pas dans newMessage

Vérifiez que dans `socket.js`, AVANT d'émettre `newMessage`, vous ajoutez les attachments:

```javascript
// Après la boucle for (const f of files)
if (attachments.length > 0) {
  messageObj.attachments = attachments;  // ← IMPORTANT
}

console.log('Émission newMessage:', JSON.stringify(messageObj));
io.to("global-chat").emit("newMessage", messageObj);
```

### Si les attachments sont null/undefined

Dans `Message.fromJson`, ajoutez des logs:

```dart
factory Message.fromJson(Map<String, dynamic> json) {
  print('🔍 JSON reçu: ${json.keys}');
  print('🔍 Attachments dans JSON: ${json['attachments']}');
  
  List<Attachment> attachments = [];
  if (json['attachments'] != null && json['attachments'] is List) {
    print('✅ Parsing ${(json['attachments'] as List).length} attachments');
    attachments = (json['attachments'] as List)
        .map((att) {
          print('   - Attachment: ${att['url']}');
          return Attachment.fromJson(att as Map<String, dynamic>);
        })
        .toList();
  } else {
    print('❌ Pas d\'attachments ou type invalide');
  }
  // ...
}
```

### Si l'image ne s'affiche pas

Dans `chat_message_bubble.dart`, ajoutez des logs:

```dart
Widget _buildNetworkImageContent(String imageUrl) {
  final fullUrl = imageUrl.startsWith('http') 
      ? imageUrl 
      : '${ApiClient.baseUrl}$imageUrl';
  
  print('🖼️ Chargement image: $fullUrl');
  
  return ClipRRect(
    // ...
    child: Image.network(
      fullUrl,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Erreur image: $error');
        print('   URL: $fullUrl');
        // ...
      },
    ),
  );
}
```

## 🧪 Test manuel rapide

### Console serveur:
```bash
npm run dev
```

Vous devriez voir:
```
✅ API démarrée sur http://0.0.0.0:3000
📁 Uploads: /path/to/uploads
```

### Console Flutter:
```bash
flutter run -d windows
```

### Envoi d'une image:
1. Cliquez sur 📷
2. Sélectionnez une image

### Vérifications:
1. **Terminal serveur**: Un fichier UUID est créé dans `uploads/`
2. **Base de données**: Nouvelle ligne dans `attachments` table
3. **Console Flutter**: Message avec attachments reçu
4. **UI Flutter**: Image s'affiche dans la bulle

## 🔍 SQL pour vérifier

```sql
-- Derniers messages avec attachments
SELECT 
  m.id,
  m.message,
  m.created_at,
  u.name,
  a.filename,
  a.url,
  a.mime_type
FROM messages m
JOIN users u ON u.id = m.user_id
LEFT JOIN attachments a ON a.message_id = m.id
ORDER BY m.created_at DESC
LIMIT 10;
```

Si vous voyez les attachments en DB mais pas dans Flutter, le problème est dans l'émission Socket.io.

Si vous ne voyez PAS les attachments en DB, le problème est dans la sauvegarde côté serveur.
