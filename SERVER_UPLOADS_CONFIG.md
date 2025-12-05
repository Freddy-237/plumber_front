# Configuration serveur pour uploads

## 📁 Structure du projet serveur

Votre code serveur actuel:
```javascript
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
```

Cela signifie:
- Si `app.js` est dans `server/src/app.js`
- Alors `uploads` doit être dans `server/uploads/`

## ✅ Solution 1: Ajuster le chemin (recommandé)

Modifiez dans votre fichier serveur principal:

```javascript
// AVANT
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// APRÈS - uploads dans le même dossier que app.js
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// OU - uploads à la racine du projet serveur
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
```

## ✅ Solution 2: Créer automatiquement le dossier

Ajoutez ce code au début de votre fichier serveur, après les imports:

```javascript
const fs = require('fs');
const path = require('path');

// Créer le dossier uploads s'il n'existe pas
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log('✅ Dossier uploads créé:', uploadsDir);
}

// Servir les fichiers uploadés
app.use('/uploads', express.static(uploadsDir));
```

## 🧪 Tester que le serveur sert les fichiers

### 1. Créer un fichier de test:

Créez manuellement un fichier `test.txt` dans le dossier `uploads/`:
```
server/
  uploads/
    test.txt   (contenu: "Hello from uploads!")
```

### 2. Démarrer le serveur:
```bash
npm run dev
```

### 3. Tester dans le navigateur:
```
http://localhost:3000/uploads/test.txt
```

Si vous voyez "Hello from uploads!", c'est bon! ✅

### 4. Tester depuis l'app Flutter:

Les images envoyées seront accessibles via:
```
http://localhost:3000/uploads/abc123-def456.jpg
```

## 🐛 Dépannage

### Le serveur démarre sur un mauvais port:

Vérifiez le fichier `.env`:
```env
PORT=3000
```

### Permission refusée:

Sous Windows, exécutez le terminal en administrateur.

### Erreur EADDRINUSE (port déjà utilisé):

```bash
# Trouver le processus
netstat -ano | findstr :3000

# Tuer le processus (remplacer PID par le numéro trouvé)
taskkill /PID [PID] /F
```

### Les images ne s'affichent toujours pas:

1. **Vérifiez les logs du serveur**:
   - Quand vous envoyez une image, le serveur doit logger la sauvegarde
   - Vérifiez que le fichier est bien créé dans `uploads/`

2. **Vérifiez l'URL dans les logs Flutter**:
   ```
   📤 Envoi image: photo.jpg (123456 bytes)
   ```

3. **Testez l'URL directement**:
   - Copiez l'URL depuis les logs Flutter
   - Collez dans un navigateur
   - L'image doit s'afficher

## 📊 Code serveur complet recommandé

```javascript
const express = require("express");
const cors = require("cors");
const fs = require('fs');
const path = require('path');
require("dotenv").config();
const http = require("http");

const app = express();
app.use(cors());
app.use(express.json());

// Créer le dossier uploads s'il n'existe pas
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log('✅ Dossier uploads créé:', uploadsDir);
}

// Servir les fichiers uploadés
app.use('/uploads', express.static(uploadsDir));
console.log('📁 Fichiers uploads servis depuis:', uploadsDir);

// Importer les routes
const authRoutes = require("./routes/auth.routes");
const chatRoutes = require("./routes/chat.routes");

app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);

const server = http.createServer(app);

const { initSocket } = require("./socket");
initSocket(server); 

const PORT = process.env.PORT || 3000;
server.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ API démarrée sur http://0.0.0.0:${PORT}`);
  console.log(`   Accessible via http://localhost:${PORT}`);
  console.log(`   Émulateur Android: http://10.0.2.2:${PORT}`);
  console.log(`📁 Uploads: ${uploadsDir}`);
});

server.on('error', (err) => {
  console.error('❌ Server error:', err);
});
```

## ✅ Checklist finale

- [ ] Dossier `uploads/` existe
- [ ] Serveur démarre sans erreur sur port 3000
- [ ] `http://localhost:3000/uploads/test.txt` fonctionne
- [ ] App Flutter se connecte à Socket.io
- [ ] Envoyer une image ne génère pas d'erreur
- [ ] L'image s'affiche dans le chat Flutter
- [ ] Vérifier fichier dans `uploads/` avec UUID dans le nom

## 🚀 Commandes utiles

```bash
# Démarrer le serveur
npm run dev

# Vérifier les ports utilisés
netstat -ano | findstr :3000

# Lister les fichiers uploads
ls uploads/

# Tester l'API
curl http://localhost:3000/uploads/test.txt
```
