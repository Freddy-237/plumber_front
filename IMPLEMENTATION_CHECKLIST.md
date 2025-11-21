# 📋 Checklist d'implémentation - Plumber App

## 🎯 Phase 1 : Authentification (PRIORITÉ ⭐⭐⭐)

### À implémenter
- [ ] **login_screen.dart** - Écran de connexion
  - Email & Mot de passe
  - Bouton "Se connecter"
  - Lien "S'inscrire"
  - Intégration AuthService
  
- [ ] **register_screen.dart** - Écran d'inscription (générique)
  - Recevra le userType en argument
  - Affichera différents champs selon le type
  - Validation complète
  - Intégration AuthService

### Fichiers utiles
- `lib/services/auth_service.dart` - registerUser(), loginUser()
- `lib/utils/validators.dart` - validateEmail(), validatePassword()
- `lib/widgets/common/custom_text_field.dart` - Input fields
- `lib/widgets/common/custom_button.dart` - Boutons
- `lib/providers/auth_provider.dart` - Providers Riverpod

---

## 💬 Phase 2 : Chat (PRIORITÉ ⭐⭐⭐)

### À implémenter
- [ ] **chat_detail_screen.dart** - Détail du chat
  - Liste des messages
  - Input pour envoyer
  - Indicateur de lecture
  - Affichage en temps réel
  
- [ ] **message_bubble.dart** - Widget pour afficher un message
  - Style différent sender/receiver
  - Timestamp
  - Statut de lecture

### Fichiers utiles
- `lib/services/chat_service.dart` - sendMessage(), getMessages()
- `lib/models/message_model.dart` - Structure Message
- `lib/providers/chat_provider.dart` - chatMessagesProvider
- `lib/widgets/common/state_widgets.dart` - Loading, Error, Empty

---

## 👤 Phase 3 : Profils (PRIORITÉ ⭐⭐)

### À implémenter
- [ ] **plumber_profile_screen.dart** - Afficher profil plombier
  - Infos de base
  - Photo
  - Spécialités
  - Avis (rating)
  - Bouton "Contacter"
  
- [ ] **my_profile_screen.dart** - Mon profil
  - Édition des données
  - Upload photo
  - Ajouter spécialités (Plombier)
  - Voir mes avis
  
- [ ] **plumber_card.dart** - Widget pour afficher plombier en liste

### Fichiers utiles
- `lib/models/plumber_model.dart` - Données plombier
- `lib/providers/plumber_provider.dart` - plumberProvider
- `lib/providers/review_provider.dart` - plumberReviewsProvider
- `lib/services/plumber_service.dart` - updatePlumberProfile()

---

## 🔧 Phase 4 : Demandes de service (PRIORITÉ ⭐⭐)

### À implémenter
- [ ] **create_request_screen.dart** - Créer une demande
  - Titre & description
  - Location
  - Budget estimé
  - Upload photos
  - Valider & créer
  
- [ ] **request_detail_screen.dart** - Voir détail demande
  - Infos complètes
  - Photos
  - Statut
  - Boutons d'action (Accepter si Plombier)
  
- [ ] **request_card.dart** - Widget pour afficher demande

### Fichiers utiles
- `lib/models/request_model.dart` - ServiceRequest
- `lib/services/service_request_service.dart` - CRUD demandes
- `lib/providers/service_request_provider.dart` - Providers

---

## ⭐ Phase 5 : Système d'avis (PRIORITÉ ⭐⭐)

### À implémenter
- [ ] **add_review_screen.dart** - Ajouter un avis
  - RatingBar (1-10)
  - Commentaire
  - Valider & envoyer
  
- [ ] **reviews_list_widget.dart** - Afficher les avis
  - Liste des avis
  - Moyenne calculée
  - Avatar client + texte

### Fichiers utiles
- `lib/models/review_model.dart` - Review
- `lib/services/review_service.dart` - addReview()
- `lib/providers/review_provider.dart` - reviewsProvider

---

## 💳 Phase 6 : Paiements (PRIORITÉ ⭐)

### À implémenter
- [ ] **payment_screen.dart** - Écran de paiement
  - Montant
  - Email
  - Intégration Stripe (CardField)
  - Bouton payer
  
- [ ] **payment_history_screen.dart** - Historique paiements
  - Liste transactions
  - Statut
  - Montant
  - Date

### Fichiers utiles
- `lib/services/payment_service.dart` - Intégration Stripe
- `lib/constants/app_constants.dart` - STRIPE_PUBLISHABLE_KEY
- Package : `flutter_stripe`

---

## 🔔 Phase 7 : Notifications (PRIORITÉ ⭐)

### À implémenter
- [ ] Firebase Messaging setup
- [ ] Local Notifications
- [ ] Handle notifications en foreground/background

### Fichiers utiles
- `flutter_local_notifications`
- `firebase_messaging`

---

## 🏠 Phase 8 : Navigation & Intégration

### À implémenter
- [ ] Mettre à jour `AppRouter` avec toutes les routes
- [ ] Intégrer Go Router pour navigation complète
- [ ] Gérer l'état de connexion (Splash → Login/Home)
- [ ] NavBar pour chaque type d'utilisateur

### Fichiers à mettre à jour
- `lib/config/app_router.dart`
- `lib/main.dart`
- `lib/screens/auth/splash_screen.dart`

---

## 📋 Template pour implémenter un écran

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports nécessaires
import 'package:plumber/providers/index.dart';
import 'package:plumber/widgets/common/state_widgets.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utiliser les providers
    final state = ref.watch(someProvider);

    return state.when(
      data: (data) => Scaffold(
        appBar: AppBar(title: const Text('Title')),
        body: Column(
          children: [
            // UI ici
          ],
        ),
      ),
      loading: () => const LoadingWidget(),
      error: (err, stack) => ErrorWidget(message: err.toString()),
    );
  }
}
```

---

## 🧪 Tests à faire après chaque écran

- [ ] Vérifier que les validations marchent
- [ ] Tester la navigation
- [ ] Vérifier les erreurs Firebase
- [ ] Tester avec différentes tailles d'écran
- [ ] Vérifier les performances

---

## 🚀 Ordre d'implémentation recommandé

1. **Login/Register** → De base pour tester
2. **ChatList + ChatDetail** → Cœur de l'app
3. **ClientHome** → Afficher plombiers disponibles
4. **PlumberProfile** → Détails plombier + avis
5. **CreateRequest** → Clients créent demandes
6. **RequestList** → Plombiers voient demandes
7. **Payments** → Finaliser une demande
8. **Reviews** → Évaluer le service
9. **Navigation** → Intégrer tout ensemble

---

## ⏱️ Estimation temps

| Composant | Temps estimé |
|-----------|-------------|
| Login/Register | 3h |
| Chat | 4h |
| Profils | 3h |
| Demandes | 3h |
| Avis | 2h |
| Paiements | 3h |
| Notifications | 2h |
| Navigation & Polish | 2h |
| **TOTAL** | **~22h** |

---

## 💡 Tips

1. **Riverpod** - Utilisez `ref.watch()` dans les ConsumerWidget
2. **FireStore** - Commencez en mode Test pour développer
3. **Images** - Utilisez `image_picker` pour uploads
4. **Validation** - Utilisez les validateurs dans `utils/`
5. **UI** - Réutilisez les widgets de `widgets/common/`
6. **Erreurs** - Mettez des try-catch dans les services
7. **States** - Gérez Loading/Error/Data avec `.when()`

---

**Créé** : 17 novembre 2024  
**Statut** : ✅ Prêt pour commencer
