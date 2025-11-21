# Plumber App - Architecture et Documentation

## 📱 Vue d'ensemble du projet

**Plumber App** est une application mobile Flutter permettant aux clients de trouver des plombiers et de communiquer en temps réel. Les plombiers peuvent accepter des demandes et être notés.

### Technologies utilisées
- **Frontend** : Flutter + Riverpod (gestion d'état)
- **Backend** : Firebase (Auth, Firestore, Storage)
- **Paiements** : Stripe
- **Notifications** : Firebase Messaging + Local Notifications

---

## 🏗️ Architecture

### Patterns utilisés
- **Riverpod** : Gestion d'état et injection de dépendances
- **Repository Pattern** : Services encapsulant la logique métier
- **Provider Pattern** : Accès unifié aux services via Riverpod

### Structure des dossiers

```
lib/
├── config/                    # Configuration globale
│   ├── app_router.dart       # Routes de navigation
│   ├── app_theme.dart        # Thème global
│   └── firebase_config.dart  # Configuration Firebase
│
├── constants/                 # Constantes de l'app
│   └── app_constants.dart    # Clés API, URLs, etc.
│
├── models/                    # Modèles de données
│   ├── user_model.dart       # Utilisateur
│   ├── plumber_model.dart    # Plombier
│   ├── message_model.dart    # Message
│   ├── review_model.dart     # Avis
│   └── request_model.dart    # Demande de service
│
├── services/                  # Services métier
│   ├── auth_service.dart     # Authentification Firebase
│   ├── chat_service.dart     # Gestion du chat
│   ├── plumber_service.dart  # Données des plombiers
│   ├── review_service.dart   # Gestion des avis
│   ├── service_request_service.dart  # Demandes
│   └── payment_service.dart  # Paiements Stripe
│
├── providers/                 # Riverpod Providers
│   ├── auth_provider.dart    # Authentification
│   ├── chat_provider.dart    # Chat
│   ├── plumber_provider.dart # Plombiers
│   ├── review_provider.dart  # Avis
│   └── service_request_provider.dart
│
├── screens/                   # Écrans de l'app
│   ├── auth/                 # Authentification
│   │   ├── splash_screen.dart
│   │   ├── select_user_type_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── chat/
│   │   ├── chat_list_screen.dart
│   │   └── chat_detail_screen.dart
│   ├── client/
│   │   ├── client_home_screen.dart
│   │   ├── plumber_profile_screen.dart
│   │   └── create_request_screen.dart
│   ├── plumber/
│   │   ├── plumber_home_screen.dart
│   │   ├── request_detail_screen.dart
│   │   └── my_profile_screen.dart
│   └── payment/
│       ├── payment_screen.dart
│       └── payment_history_screen.dart
│
├── widgets/                   # Widgets réutilisables
│   ├── common/
│   │   ├── custom_text_field.dart
│   │   ├── custom_button.dart
│   │   └── state_widgets.dart
│   ├── auth/
│   │   └── (Widgets d'authentification)
│   └── chat/
│       └── (Widgets de chat)
│
├── utils/                     # Utilitaires
│   ├── extensions.dart       # Extensions
│   ├── validators.dart       # Validations
│   └── helpers.dart          # Fonctions utilitaires
│
└── main.dart                 # Point d'entrée
```

---

## 🔐 Authentification

### Processus d'inscription
1. Sélection du type d'utilisateur (Client ou Plombier)
2. Remplissage du formulaire spécifique
3. Création du compte Firebase
4. Sauvegarde du profil dans Firestore

### Données sauvegardées

**Client** :
- email, fullName, phoneNumber, address
- userType: "client"

**Plombier** :
- email, fullName, phoneNumber, address
- userType: "plumber"
- specialties: ["Robinetterie", "Chauffage", ...]
- rating, totalReviews
- isAvailable, hourlRate
- bio, portfolio

---

## 💬 Chat en temps réel

### Structure Firestore

```
chatRooms/
├── {chatRoomId}
│   ├── clientId
│   ├── plumberId
│   ├── serviceRequestId
│   ├── createdAt
│   ├── lastMessage
│   └── messages/
│       ├── {messageId}
│       │   ├── senderId
│       │   ├── content
│       │   ├── timestamp
│       │   └── isRead
```

### Fonctionnalités
- Envoi de messages en temps réel
- Indicateurs de lecture
- Historique des messages
- Notifications des nouveaux messages

---

## ⭐ Système d'avis

- **Note** : 1 à 10
- **Commentaire** : Texte libre
- **Moyenne** : Calculée automatiquement
- **Affichage** : Profil du plombier

### Calcul de la note

```
moyenneNote = sommeDesNotes / nombreD'avis
```

---

## 💳 Intégration Paiements

### Intégration Stripe

1. Créer un token Stripe côté client
2. Envoyer le paiement via API backend (optionnel)
3. Sauvegarder la transaction dans Firestore

### Données de paiement

```
payments/
├── {paymentId}
│   ├── clientId
│   ├── plumberId
│   ├── amount
│   ├── currency
│   ├── status (pending, completed, failed)
│   ├── createdAt
│   └── transactionId
```

---

## 🔄 Flux utilisateur

### Client
1. **Connexion/Inscription** → sélection "Client"
2. **Accueil** → voir les plombiers disponibles
3. **Créer une demande** → description du problème
4. **Chat** → communiquer avec le plombier
5. **Paiement** → payer le service
6. **Avis** → évaluer le plombier

### Plombier
1. **Connexion/Inscription** → sélection "Plombier"
2. **Tableau de bord** → voir les demandes disponibles
3. **Accepter** → accepter une demande
4. **Chat** → communiquer avec le client
5. **Compléter** → marquer comme terminé
6. **Avis** → voir les évaluations

---

## 🔧 Mise en place

Voir [SETUP.md](./SETUP.md) pour les instructions détaillées.

### Prérequis
- Flutter 3.5+
- Dart 3.0+
- Compte Firebase
- Compte Stripe (optional)

---

## 📊 Collection Firestore complète

### Users (collections/users)
```json
{
  "id": "uid",
  "email": "user@example.com",
  "fullName": "John Doe",
  "phoneNumber": "+33612345678",
  "userType": "client|plumber",
  "profileImage": "url",
  "address": "123 Rue...",
  "isActive": true,
  "createdAt": "2024-11-17T...",
  "updatedAt": "2024-11-17T...",
  // Si plombier
  "specialties": ["Robinetterie"],
  "rating": 4.5,
  "totalReviews": 10,
  "bio": "Bio...",
  "isAvailable": true,
  "hourlRate": 50,
  "portfolio": ["url1", "url2"]
}
```

### ServiceRequests
```json
{
  "id": "id",
  "clientId": "uid",
  "plumberId": "uid|null",
  "title": "Fuite d'eau",
  "description": "Description...",
  "location": "Adresse...",
  "estimatedBudget": 150.00,
  "status": "pending|accepted|inProgress|completed",
  "images": ["url1"],
  "createdAt": "2024-11-17T...",
  "updatedAt": "2024-11-17T..."
}
```

### ChatRooms & Messages
```json
{
  "id": "{clientId}_{plumberId}_{serviceRequestId}",
  "clientId": "uid",
  "plumberId": "uid",
  "serviceRequestId": "id",
  "createdAt": "2024-11-17T...",
  "lastMessage": "Dernier message...",
  "lastMessageTime": "2024-11-17T...",
  "messages": {
    "messageId": {
      "id": "id",
      "chatRoomId": "id",
      "senderId": "uid",
      "senderName": "John",
      "senderImage": "url",
      "content": "Message...",
      "timestamp": "2024-11-17T...",
      "isRead": false
    }
  }
}
```

---

## 🚀 Prochaines étapes

1. ✅ Installer les dépendances : `flutter pub get`
2. ✅ Configurer Firebase
3. ✅ Implémenter les écrans d'authentification
4. ✅ Implémenter le chat en temps réel
5. ✅ Intégrer Stripe pour les paiements
6. ✅ Ajouter les notifications push
7. ✅ Tests et déploiement

---

## 📞 Support et ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Stripe Documentation](https://stripe.com/docs)

---

**Version** : 1.0.0  
**Dernière mise à jour** : 17 novembre 2024
