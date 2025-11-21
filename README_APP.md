# 🔧 Plumber App - Application de mise en relation Plombier/Client

Une application Flutter moderne permettant aux clients de trouver des plombiers, de communiquer en temps réel, et de payer directement via l'app.

## 🎯 Fonctionnalités

- ✅ **Authentification** - Inscription/Connexion pour Clients et Plombiers
- ✅ **Chat en temps réel** - Conversation instantanée avec Firebase Firestore
- ✅ **Profils** - Profils détaillés avec photos et informations
- ✅ **Système d'avis** - Notations de 1 à 10 pour les plombiers
- ✅ **Demandes de service** - Clients peuvent poster des demandes
- ✅ **Disponibilité** - Plombiers peuvent se marquer disponibles
- ✅ **Paiements** - Intégration Stripe pour paiement in-app
- ✅ **Notifications** - Notifications push Firebase

## 🏗️ Architecture

```
Frontend: Flutter + Riverpod (State Management)
         ↓
Backend:  Firebase (Auth + Firestore + Storage + Messaging)
         ↓
Paiements: Stripe API
```

### Stack technique
- **Framework** : Flutter 3.5+
- **State Management** : Riverpod 2.4
- **Base de données** : Firebase Firestore
- **Authentification** : Firebase Auth
- **Stockage** : Firebase Storage
- **Paiements** : Stripe
- **Notifications** : Firebase Messaging + Local Notifications

## 📁 Structure du projet

```
lib/
├── config/              # Configuration globale
├── constants/           # Constantes et clés API
├── models/              # Modèles de données (5)
├── services/            # Services métier (6)
├── providers/           # Riverpod providers (5)
├── screens/             # Écrans de l'application
├── widgets/             # Widgets réutilisables
├── utils/               # Utilitaires (validators, extensions)
└── main.dart            # Point d'entrée

assets/                 # Images et ressources
├── images/
├── icons/
└── fonts/
```

## 🚀 Démarrage rapide

### Prérequis
- Flutter 3.5+
- Dart 3.0+
- Git
- Compte Firebase
- (Optionnel) Compte Stripe

### Installation

1. **Cloner le projet**
```bash
cd c:\Users\Freddy\Desktop\projet\FRIDEVS\client\App\plumber
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase** (voir SETUP.md)
```
- Créer un projet Firebase
- Ajouter google-services.json (Android)
- Ajouter GoogleService-Info.plist (iOS)
- Configurer Firestore Database
- Activer Authentication
```

4. **Lancer l'application**
```bash
flutter run
```

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| **QUICKSTART.md** | 🚀 Guide de démarrage rapide |
| **SETUP.md** | 🔧 Configuration détaillée Firebase |
| **PROJECT_STRUCTURE.md** | 🏗️ Architecture complète |
| **SETUP_COMPLETE.md** | 📊 Résumé des fichiers créés |

## 🎨 Modèles de données

### User (Base)
```
- id, email, fullName, phoneNumber
- userType (client/plumber)
- profileImage, address
- isActive, createdAt, updatedAt
```

### Plumber (extends User)
```
+ specialties: ["Robinetterie", "Chauffage", ...]
+ rating: 4.5 (moyenne)
+ totalReviews: 10
+ bio, isAvailable, hourlRate
+ portfolio: [image_urls]
```

### Message
```
- chatRoomId, senderId, senderName
- content, timestamp
- isRead
```

### ServiceRequest
```
- clientId, plumberId (optionnel)
- title, description, location
- estimatedBudget
- status (pending/accepted/inProgress/completed)
- images
```

### Review
```
- plumberId, clientId, clientName
- rating (1-10), comment
- createdAt
```

## 🔐 Flux d'authentification

```
┌─────────────────┐
│  SplashScreen   │
└────────┬────────┘
         │
         ↓ Firebase Auth Check
    ┌────────────────────┐
    │ SelectUserTypeScreen│
    └────────┬────────┬──┘
             │        │
      ┌──────┘        └──────┐
      ↓                      ↓
┌──────────┐          ┌─────────────┐
│ Register │          │ Register    │
│ Client   │          │ Plumber     │
└──────┬───┘          └────┬────────┘
       │                   │
       └───────┬───────────┘
               ↓
       ┌──────────────────┐
       │ Firestore Save   │
       │ Auth Create      │
       └────────┬─────────┘
                ↓
       ┌──────────────────┐
       │  Home Screen     │
       │  Client/Plumber  │
       └──────────────────┘
```

## 💬 Chat en temps réel

- Créé automatiquement lors de l'acceptation d'une demande
- Structure : `{clientId}_{plumberId}_{serviceRequestId}`
- Listeners Firestore pour mises à jour instantanées
- Indicateurs de lecture
- Historique persistant

## ⭐ Système d'avis

1. Client finit le service
2. Client laisse un avis (1-10)
3. Service recalcule la moyenne du plombier
4. Affichée sur le profil du plombier

## 💳 Intégration Paiements

1. Sélectionner un service/montant
2. Entrer les détails de la carte (Stripe)
3. Créer le paiement Firebase
4. Confirmation et historique

## 🛣️ Roadmap

### Phase 1 - MVP (Semaine 1-2) 🔴 EN COURS
- [x] Structure du projet
- [ ] Authentification complète
- [ ] Chat fonctionnel
- [ ] Profils de base

### Phase 2 - Fonctionnalités (Semaine 3-4)
- [ ] Demandes de service
- [ ] Système d'avis
- [ ] Paiements Stripe
- [ ] Notifications push

### Phase 3 - Polish (Semaine 5)
- [ ] UI/UX refinement
- [ ] Performance optimization
- [ ] Tests et debugging
- [ ] Préparer le déploiement

## 🧪 Tests

```bash
# Analyzer
flutter analyze

# Format
dart format lib/

# Tests unitaires (à ajouter)
flutter test

# Tests d'intégration (à ajouter)
```

## 📦 Distribution

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🐛 Dépannage

### "Target of URI doesn't exist"
→ `flutter pub get` + `flutter pub run build_runner build --delete-conflicting-outputs`

### Erreur Firebase
→ Vérifier `google-services.json` et `GoogleService-Info.plist`

### Riverpod errors
→ Regénérer avec `flutter pub run build_runner build --delete-conflicting-outputs`

## 🤝 Contribution

Le projet est prêt pour développement ! Consultez les fichiers TODO pour les prochaines étapes.

## 📞 Support

- Consultez la documentation dans les fichiers .md
- Cherchez `TODO` dans le code pour les étapes suivantes

## 📄 Licence

MIT License - Libre d'utilisation

## 🙏 Crédits

- **Framework** : Flutter
- **Backend** : Firebase
- **Paiements** : Stripe
- **État** : Riverpod

---

**Status** : ✅ Prêt pour développement  
**Version** : 1.0.0  
**Créé** : 17 novembre 2024  

**Prochaine étape** : Lisez `QUICKSTART.md` pour commencer ! 🚀
