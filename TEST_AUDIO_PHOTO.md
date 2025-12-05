# Test des messages audio et photo

## ✅ Corrections appliquées

### Affichage des images:
- ✅ Utilisation de `Image.network()` au lieu de `Image.file()`
- ✅ Construction automatique de l'URL complète: `http://localhost:3000/uploads/image.jpg`
- ✅ Indicateur de chargement pendant le téléchargement
- ✅ Gestion des erreurs d'affichage
- ✅ Support des attachments multiples

### Affichage des audios:
- ✅ Icône et indication "Audio" dans la bulle
- ✅ Support des attachments audio
- 🔄 Lecteur audio complet à implémenter plus tard

### Structure des messages:
- ✅ Support de la propriété `attachments[]` depuis le backend
- ✅ Détection automatique du type (image/audio) via `mime_type`
- ✅ Affichage du texte accompagnant les médias

## 🧪 Comment tester

### 1. Démarrer le serveur Node.js:
```bash
cd C:\Users\Freddy\Desktop\projet\FRIDEVS\server
npm run dev
```

Le serveur doit afficher:
```
Server listening on port 3000
```

### 2. Lancer l'app Flutter sur Windows:
```bash
flutter run -d windows
```

### 3. Envoyer une image:
1. Cliquez sur l'icône 📷 dans la barre de chat
2. Choisissez "Galerie"
3. Sélectionnez une image
4. L'image est envoyée automatiquement
5. **Vérifiez**: L'image doit s'afficher dans la bulle de message

### 4. Envoyer un audio (Android/iOS uniquement):
1. Maintenez le bouton 🎤 enfoncé
2. Parlez
3. Relâchez pour envoyer
4. **Vérifiez**: Une bulle avec icône 🎤 Audio doit apparaître

## 🔍 Vérifications côté serveur

### Fichiers sauvegardés:
Les fichiers sont sauvegardés dans:
```
server/uploads/
├── abc123-def456.jpg  (images)
├── xyz789-uvw012.aac  (audios)
└── ...
```

### Base de données:
Table `messages`:
```sql
SELECT * FROM messages ORDER BY created_at DESC LIMIT 5;
```

Table `attachments`:
```sql
SELECT a.*, m.message 
FROM attachments a 
JOIN messages m ON a.message_id = m.id 
ORDER BY m.created_at DESC;
```

## 🐛 Dépannage

### Les images ne s'affichent pas:
1. **Vérifier l'URL dans les logs**:
   - Doit être: `http://localhost:3000/uploads/image.jpg`
   - Pas: `/uploads/image.jpg` seul

2. **Vérifier que le serveur sert les fichiers statiques**:
   Dans `server.js` ou `app.js`:
   ```javascript
   app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
   ```

3. **Tester l'URL directement**:
   - Ouvrir dans un navigateur: `http://localhost:3000/uploads/[nom_fichier].jpg`
   - Si erreur 404 → Le serveur ne sert pas les fichiers
   - Si erreur CORS → Ajouter les headers CORS

### Le serveur refuse la connexion:
1. **Vérifier le port**:
   ```bash
   netstat -ano | findstr :3000
   ```

2. **Vérifier le firewall Windows**:
   - Autoriser Node.js dans le pare-feu
   - Autoriser le port 3000

### Format des messages reçus:
Le backend envoie ce format:
```json
{
  "id": "abc-123",
  "user_id": "user-456",
  "name": "John Doe",
  "message": "Voici une photo",
  "created_at": "2025-11-24T10:30:00.000Z",
  "attachments": [
    {
      "id": "att-789",
      "filename": "photo.jpg",
      "url": "/uploads/uuid-photo.jpg",
      "mime_type": "image/jpeg",
      "size": 123456
    }
  ]
}
```

## 📊 Résumé des fichiers modifiés

1. `lib/widgets/chat/chat_message_bubble.dart`:
   - Ajout de `_buildNetworkImageContent()` avec `Image.network()`
   - Ajout de `_buildNetworkAudioContent()` avec indicateur audio
   - Ajout de `_buildFileAttachment()` pour autres fichiers
   - Support des attachments multiples
   - Construction automatique de l'URL complète

2. `lib/models/message_model.dart`:
   - Classe `Attachment` avec parsing JSON
   - Propriété `attachments[]` dans Message
   - Détection automatique isImage/isAudio depuis attachments

3. `lib/services/socketio_service.dart`:
   - Méthode `sendFile()` pour fichier unique
   - Méthode `sendMultipleFiles()` pour fichiers multiples

4. `lib/providers/chat_provider.dart`:
   - Méthode `sendAudio()`
   - Méthode `sendImage()`
   - Méthode `sendMultipleImages()`

5. `lib/services/file_picker_service.dart`:
   - Service de sélection d'images
   - Support galerie et caméra

6. `lib/screens/chat_screen.dart`:
   - Intégration complète de l'envoi d'images
   - Dialogue galerie/caméra
   - Envoi automatique après sélection
