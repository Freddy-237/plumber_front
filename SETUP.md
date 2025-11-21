# Configuration Firebase

Pour mettre en place votre application, vous devez configurer Firebase :

## Étapes de configuration Firebase

1. **Créer un projet Firebase**
   - Allez sur [Firebase Console](https://console.firebase.google.com)
   - Créez un nouveau projet
   - Activez Google Analytics (optionnel)

2. **Ajouter des applications (iOS/Android)**
   - Pour Android : Téléchargez le fichier `google-services.json`
   - Pour iOS : Téléchargez le fichier `GoogleService-Info.plist`

3. **Activer l'authentification**
   - Authentification → Activer Email/Mot de passe

4. **Créer la base de données Firestore**
   - Firestore Database → Créer une base de données
   - Mode de démarrage : Commencer en mode test
   - Emplacement : Choisir votre région

5. **Activer Cloud Storage**
   - Cloud Storage → Créer un bucket
   - Emplacement : Même région que Firestore

## Installations locales

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers avec build_runner (pour Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Exécuter l'application
flutter run
```

## Configuration Stripe

1. **Obtenir les clés Stripe**
   - Allez sur [Stripe Dashboard](https://dashboard.stripe.com)
   - Récupérez votre clé publique

2. **Mettre à jour les constantes**
   - Modifiez `lib/constants/app_constants.dart`
   - Ajoutez votre clé Stripe publique

## Structure du projet

```
lib/
├── config/          # Configuration (Firebase, Router, Theme)
├── constants/       # Constantes de l'application
├── models/          # Modèles de données
├── providers/       # Providers Riverpod
├── screens/         # Écrans de l'application
│   ├── auth/
│   ├── chat/
│   ├── client/
│   ├── plumber/
│   └── payment/
├── services/        # Services (Firebase, Chat, etc.)
├── utils/           # Utilitaires
├── widgets/         # Widgets réutilisables
└── main.dart        # Point d'entrée
```

## Fonctionnalités à implémenter

- [ ] Authentification (Client/Plombier)
- [ ] Chat en temps réel
- [ ] Profils utilisateur
- [ ] Système d'avis (1-10)
- [ ] Demandes de service
- [ ] Intégration Stripe pour les paiements
- [ ] Notifications en temps réel
- [ ] Historique des transactions

## Support

Pour plus d'informations, consultez la documentation :
- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [Riverpod](https://riverpod.dev)
- [Stripe](https://stripe.com/docs)
