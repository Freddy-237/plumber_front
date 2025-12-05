# 🔧 Correction serveur - Erreur "Duplicate entry '' for key 'PRIMARY'"

## ⚠️ Problème urgent
Lors de l'envoi d'images via Socket.io, le serveur retourne :
```
❌ Erreur serveur: {error: Duplicate entry '' for key 'PRIMARY'}
```

**Impact** : Les utilisateurs **ne peuvent pas envoyer d'images** dans le chat.

## 🔍 Cause racine
Le serveur génère un **ID vide** (`''`) au lieu d'un **UUID valide** lors de la création d'un attachment en base de données.

## ✅ Solution (URGENT)

### Étape 1 : Installer uuid
```bash
cd server  # ou le dossier de votre serveur Node.js
npm install uuid
```

### Étape 2 : Modifier le handler Socket.io

**Fichier à modifier** : `server/socket.js` ou `server/sockets/messageHandler.js`

**AVANT (bugué)** :
```javascript
socket.on('sendMessage', async (data) => {
  // ...
  if (data.file) {
    const attachment = {
      id: '',  // ❌ ERREUR: ID vide
      message_id: messageId,
      // ...
    };
    await db.query('INSERT INTO attachments ...', [attachment]);
  }
});
```

**APRÈS (corrigé)** :
```javascript
const { v4: uuidv4 } = require('uuid');

socket.on('sendMessage', async (data) => {
  try {
    console.log('📨 Message reçu:', {
      hasFile: !!data.file,
      fileName: data.file?.name,
      fileType: data.file?.type
    });

    // Générer l'ID du message
    const messageId = uuidv4();
    console.log('✅ Message ID:', messageId);
    
    // Si un fichier est attaché
    if (data.file && data.file.buffer) {
      const file = data.file;
      
      // ✅ IMPORTANT: Générer un UUID valide pour l'attachment
      const attachmentId = uuidv4();
      console.log('✅ Attachment ID:', attachmentId);
      
      // Sauvegarder le fichier sur le disque
      const fileExtension = path.extname(file.name);
      const fileName = `${uuidv4()}${fileExtension}`;
      const filePath = path.join(__dirname, '../uploads', fileName);
      
      await fs.promises.writeFile(
        filePath, 
        Buffer.from(file.buffer.data)
      );
      console.log('✅ Fichier sauvegardé:', fileName);
      
      // Déterminer le type
      const attachmentType = file.type.startsWith('image') ? 'image' : 'audio';
      
      // Insérer l'attachment avec l'UUID valide
      await db.query(
        `INSERT INTO attachments 
         (id, message_id, file_path, file_type, file_size, mime_type) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          attachmentId,              // ✅ UUID valide
          messageId,
          `/uploads/${fileName}`,
          attachmentType,
          file.size,
          file.type
        ]
      );
      console.log('✅ Attachment créé en base');
    }
    
    // Sauvegarder le message
    await db.query(
      'INSERT INTO messages (id, message, user_id, ...) VALUES (?,...)',
      [messageId, data.message || '', userId, ...]
    );
    
    // Émettre le nouveau message aux clients
    io.to(conversationId).emit('newMessage', {
      id: messageId,
      message: data.message || '',
      // ...
    });
    
    console.log('✅ Message diffusé');
    
  } catch (error) {
    console.error('❌ Erreur sendMessage:', error);
    socket.emit('error', { error: error.message });
  }
});
```

### Étape 3 : Vérifier la structure de la table

```sql
-- Vérifier que la colonne id est bien configurée
DESCRIBE attachments;

-- Si nécessaire, modifier la table
ALTER TABLE attachments 
  MODIFY id VARCHAR(36) NOT NULL;
```

### Étape 4 : Redémarrer le serveur

```bash
# Arrêter le serveur (Ctrl+C)
# Puis relancer
npm start
# ou
node server.js
```

## 🧪 Test

1. **Côté client** : L'app affichera maintenant les erreurs en SnackBar rouge
2. **Envoyer une image** dans le chat
3. **Logs attendus côté serveur** :
```
📨 Message reçu: { hasFile: true, fileName: 'image.jpg', fileType: 'image/jpeg' }
✅ Message ID: 9340828f-479d-496f-b4d2-945203364a99
✅ Attachment ID: 7f8e9d6c-5b4a-3c2d-1e0f-9a8b7c6d5e4f
✅ Fichier sauvegardé: 7f8e9d6c-5b4a-3c2d-1e0f-9a8b7c6d5e4f.jpg
✅ Attachment créé en base
✅ Message diffusé
```

## ✅ Checklist finale

- [ ] `npm install uuid` exécuté
- [ ] `const { v4: uuidv4 } = require('uuid');` ajouté en haut du fichier
- [ ] `const attachmentId = uuidv4();` utilisé avant chaque insertion
- [ ] Logs de debug ajoutés
- [ ] Serveur redémarré
- [ ] Test d'envoi d'image réussi
- [ ] Plus d'erreur "Duplicate entry"

---

**Note** : Le code **client Flutter est déjà correct** et n'a pas besoin de modifications. Il affiche maintenant les erreurs serveur en SnackBar pour aider au diagnostic.
