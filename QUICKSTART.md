# 🚀 Guide de démarrage rapide - Plumber App

## ✅ Étapes d'installation

### 1️⃣ Installer les dépendances
```bash
cd c:\Users\Freddy\Desktop\projet\FRIDEVS\client\App\plumber
flutter pub get
```

### 2️⃣ Configurer Firebase (OBLIGATOIRE)

#### Android
1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Créez un nouveau projet
3. Ajoutez une application Android
4. Téléchargez `google-services.json`
5. Placez-le dans `android/app/`

#### iOS
1. Ajoutez une application iOS
2. Téléchargez `GoogleService-Info.plist`
3. Ouvrez `Runner.xcodeproj` dans Xcode
4. Glissez-déposez le fichier dans le projet

### 3️⃣ Configurer la base de données

Dans la console Firebase :
1. **Firestore Database** → Créer une base de données
   - Mode : Test (pour développement)
   - Région : `europe-west1` (France)

2. **Authentication** → Email/Mot de passe
   - Activer la méthode Email/Mot de passe

3. **Cloud Storage** → Créer un bucket
   - Même région que Firestore

### 4️⃣ Mettre à jour les constantes

Éditez `lib/constants/app_constants.dart` :
```dart
static const String stripePublishableKey = 'pk_live_VOTRE_CLE'; // Stripe
```

### 5️⃣ Exécuter l'application

```bash
flutter run
```

---

## 📁 Structure des fichiers créés

```
✅ lib/
   ├── config/           ✅ Configuration (Firebase, Router, Theme)
   ├── constants/        ✅ Constantes API et Stripe
   ├── models/           ✅ Modèles (User, Plumber, Message, Review, Request)
   ├── providers/        ✅ Riverpod providers (Auth, Chat, Plumber, Review, Requests)
   ├── screens/          ✅ Écrans (Auth, Chat, Client, Plumber, Payment)
   ├── services/         ✅ Services Firebase (Auth, Chat, Plumber, Review, Payment)
   ├── utils/            ✅ Utilitaires (Validators, Extensions, Helpers)
   ├── widgets/          ✅ Widgets réutilisables (TextField, Button, State)
   └── main.dart         ✅ Point d'entrée

✅ assets/
   ├── images/           (À ajouter)
   ├── icons/            (À ajouter)
   └── fonts/            (À ajouter)

✅ Documentation
   ├── SETUP.md          ✅ Configuration détaillée
   ├── PROJECT_STRUCTURE.md ✅ Architecture complète
   └── QUICKSTART.md     ✅ Ce fichier
```

---

## 🔧 Prochaines étapes à implémenter

### Phase 1 : Authentification ⭐⭐⭐
- [ ] Écran de login
- [ ] Écran d'inscription (Client)
- [ ] Écran d'inscription (Plombier)
- [ ] Intégration Firebase Auth

### Phase 2 : Chat en temps réel ⭐⭐⭐
- [ ] Écran liste des chats
- [ ] Écran détail du chat
- [ ] Envoi de messages
- [ ] Indicateurs de lecture
- [ ] Notifications nouveaux messages

### Phase 3 : Profils et recherche ⭐⭐
- [ ] Profil utilisateur
- [ ] Profil plombier avec avis
- [ ] Recherche par spécialité
- [ ] Affichage des plombiers disponibles

### Phase 4 : Demandes de service ⭐⭐
- [ ] Créer une demande
- [ ] Voir les demandes disponibles (Plombier)
- [ ] Accepter une demande
- [ ] Historique des demandes

### Phase 5 : Système d'avis ⭐⭐
- [ ] Ajouter un avis (Client)
- [ ] Calculer la note moyenne
- [ ] Afficher les avis du plombier

### Phase 6 : Paiements 💳
- [ ] Intégration Stripe
- [ ] Écran de paiement
- [ ] Historique des transactions
- [ ] Refund

---

## 💡 Tips & Astuces

### Générer les fichiers Riverpod
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hot reload
```bash
r        # Hot reload (rapide)
R        # Hot restart (redémarrage complet)
```

### Vérifier les erreurs Firebase
- **Android** : Vérifier que `google-services.json` est au bon endroit
- **iOS** : Vérifier que `GoogleService-Info.plist` est ajouté au projet

### Utiliser les Providers
```dart
// Lire un provider
final user = ref.watch(currentUserProvider);

// Consommer en widget
ref.watch(currentUserProvider).when(
  data: (user) => Text(user.fullName),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Erreur'),
);
```

### Naviguer
```dart
// Named route
Navigator.of(context).pushNamed(AppRouter.selectUserType);

// Pop
Navigator.of(context).pop();

// Replace
Navigator.of(context).pushReplacementNamed(AppRouter.clientHome);
```

---

## 🐛 Dépannage

### Erreur : "Target of URI doesn't exist"
**Solution** : Exécutez `flutter pub get`

### Erreur Firebase : "Project not found"
**Solution** : Vérifiez que `google-services.json` est au bon endroit

### Erreur Stripe : "Invalid publishable key"
**Solution** : Vérifiez la clé dans `app_constants.dart`

---

## 📚 Ressources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [Riverpod Guide](https://riverpod.dev)
- [Stripe Flutter](https://pub.dev/packages/flutter_stripe)

---

## 🎯 Objectif final

Une application complète avec :
✅ Authentification (Client/Plombier)
✅ Chat en temps réel
✅ Profils avec avis (1-10)
✅ Demandes de service
✅ Paiements intégrés
✅ Notifications en temps réel

---

**Version** : 1.0.0  
**Créé** : 17 novembre 2024  
**Prêt à développer** : ✅ OUI

Bonne chance ! 🚀
