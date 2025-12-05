# 🔧 Configuration de l'API - Guide Complet

Ce guide explique comment configurer les URLs de l'API pour différents environnements de développement.

## 📍 Fichier de Configuration

Le fichier principal de configuration se trouve dans : `lib/config/api_config.dart`

## 🚀 Configurations Selon l'Environnement

### 1️⃣ Émulateur Android

**Configuration:**
```dart
static const String LOCAL_IP = "10.0.2.2";
```

**Pourquoi ?**
- L'émulateur Android utilise `10.0.2.2` comme adresse pour accéder au `localhost` de votre PC
- Cette configuration fonctionne automatiquement sans autre paramétrage

**URL résultante:** `http://10.0.2.2:3000`

---

### 2️⃣ Appareil Physique Android

**Configuration:**
```dart
static const String LOCAL_IP = "192.168.x.x";  // Votre IP locale
```

**Comment trouver votre IP locale ?**

**Windows:**
```bash
ipconfig
```
Cherchez "Adresse IPv4" (ex: `192.168.1.10`)

**Mac/Linux:**
```bash
ifconfig
# ou
ip addr show
```
Cherchez "inet" (ex: `192.168.1.10`)

**⚠️ Important:**
- Votre appareil et votre PC doivent être sur le même réseau WiFi
- Désactivez votre pare-feu ou autorisez les connexions sur le port 3000

**URL résultante:** `http://192.168.1.10:3000`

---

### 3️⃣ iOS Simulator

**Configuration:** Aucune modification nécessaire

Le système utilise automatiquement `localhost` pour iOS Simulator.

**URL résultante:** `http://localhost:3000`

---

### 4️⃣ Desktop (Windows/Mac/Linux)

**Configuration:** Aucune modification nécessaire

Le système utilise automatiquement `localhost` pour les plateformes desktop.

**URL résultante:** `http://localhost:3000`

---

### 5️⃣ Serveur Distant (Production)

**Configuration:**
```dart
static const bool USE_REMOTE_SERVER = true;
static const String REMOTE_SERVER_URL = "https://api.votreserveur.com";
```

**URL résultante:** `https://api.votreserveur.com`

---

## 📝 Exemple de Configuration Complète

```dart
// Dans lib/config/api_config.dart

class ApiConfig {
  // Pour développement local
  static const bool USE_REMOTE_SERVER = false;
  static const String LOCAL_IP = "192.168.1.10"; // Votre IP locale
  static const String PORT = "3000";
  
  // Pour production
  static const String REMOTE_SERVER_URL = "https://api.plumber237.com";
}
```

---

## 🔍 Vérification de la Configuration

Au démarrage de l'application, vous verrez dans les logs:

```
═══════════════════════════════════
🌐 CONFIGURATION API
═══════════════════════════════════
Mode: Développement local
Plateforme: Android
Base URL: http://192.168.1.10:3000
LOCAL_IP: 192.168.1.10
PORT: 3000
═══════════════════════════════════
```

---

## ❌ Problèmes Courants

### Erreur de connexion sur appareil physique

**Symptôme:** L'app ne se connecte pas au serveur

**Solutions:**
1. Vérifiez que `LOCAL_IP` correspond à votre IP locale
2. Assurez-vous que votre appareil et PC sont sur le même WiFi
3. Vérifiez que le serveur est bien lancé sur votre PC
4. Désactivez temporairement votre pare-feu pour tester

### Le serveur ne répond pas

**Vérifications:**
1. Le serveur Node.js est-il lancé ? (`npm start` ou `node server.js`)
2. Le serveur écoute-t-il sur le bon port ? (3000 par défaut)
3. Testez l'URL dans un navigateur sur votre PC : `http://localhost:3000`

---

## 🔄 Changement Rapide d'Environnement

Pour passer rapidement d'un environnement à un autre, modifiez uniquement `LOCAL_IP` dans `lib/config/api_config.dart`:

```dart
// Émulateur Android
static const String LOCAL_IP = "10.0.2.2";

// Appareil physique (remplacez par votre IP)
static const String LOCAL_IP = "192.168.1.10";
```

**Astuce:** Vous pouvez créer plusieurs profils en commentant/décommentant:

```dart
// Émulateur
// static const String LOCAL_IP = "10.0.2.2";

// Appareil physique
static const String LOCAL_IP = "192.168.1.10";
```

---

## 📱 Services Configurés

Les services suivants utilisent automatiquement cette configuration:

1. **ApiClient** (`lib/services/api_client.dart`)
   - Requêtes HTTP/REST
   - Authentification JWT

2. **SocketIOService** (`lib/services/socketio_service.dart`)
   - WebSocket en temps réel
   - Chat instantané

---

## ✅ Checklist de Vérification

Avant de lancer l'app sur un nouvel environnement:

- [ ] J'ai modifié `LOCAL_IP` si nécessaire
- [ ] Mon serveur est lancé
- [ ] Mon appareil/émulateur et mon PC sont sur le même réseau
- [ ] J'ai vérifié les logs de configuration au démarrage
- [ ] J'ai testé une requête simple pour confirmer la connexion

---

## 🆘 Support

Si vous rencontrez des problèmes, vérifiez les logs de l'application qui affichent:
- La plateforme détectée
- L'URL utilisée
- Les erreurs de connexion éventuelles

Pour plus d'aide, consultez la documentation du serveur backend.
