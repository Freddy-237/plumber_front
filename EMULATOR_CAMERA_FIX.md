# Fix pour la caméra sur émulateur Android

## ✅ Corrections appliquées

### 1. **Permissions Android ajoutées**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### 2. **Utilisation directe de la galerie (par défaut)**
Au lieu d'afficher un dialogue caméra/galerie qui peut planter, le bouton photo ouvre maintenant **directement la galerie**.

### 3. **Meilleure gestion des erreurs**
- Timeout de 30 secondes pour éviter les blocages
- Messages d'erreur clairs
- Logs détaillés pour debug

## 🔧 Configuration de l'émulateur Android

### Option 1: Activer la caméra virtuelle

1. **Ouvrir les paramètres de l'émulateur**:
   - Cliquez sur les 3 points (`...`) dans la barre latérale de l'émulateur
   - Allez dans `Settings` > `Camera`

2. **Configurer la caméra**:
   - **Front camera**: `Emulated` ou `VirtualScene`
   - **Back camera**: `Emulated` ou `VirtualScene`
   
3. **Redémarrer l'émulateur** après les changements

### Option 2: Utiliser la webcam de votre PC

1. **Ouvrir AVD Manager** (Android Virtual Device Manager)
2. **Éditer votre émulateur**: Cliquez sur l'icône crayon ✏️
3. **Dans "Camera"**:
   - **Front**: `Webcam0` (votre webcam)
   - **Back**: `Emulated` ou `Webcam0`
4. **Appliquer et redémarrer**

### Option 3: Utiliser uniquement la galerie (RECOMMANDÉ pour émulateur)

C'est ce qui est maintenant configuré par défaut! Le bouton 📷 ouvre directement la galerie.

## 🧪 Test de l'application

### 1. Nettoyer et recompiler:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Tester l'envoi d'image:
1. Cliquez sur le bouton 📷 dans le chat
2. La galerie s'ouvre (pas de dialogue caméra/galerie)
3. Sélectionnez une image depuis votre PC ou téléchargez une image test
4. L'image est envoyée automatiquement

### 3. Ajouter des images de test dans l'émulateur:

**Méthode 1 - Via l'émulateur**:
- Glissez-déposez une image depuis votre PC vers l'écran de l'émulateur
- L'image apparaîtra dans la galerie

**Méthode 2 - Via ADB**:
```bash
# Trouver l'émulateur
adb devices

# Pousser une image
adb push "C:\chemin\vers\image.jpg" /sdcard/Pictures/

# Rafraîchir la galerie
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/image.jpg
```

## 🐛 Si la caméra plante toujours

### Solution 1: Désactiver complètement la caméra
Modifiez `chat_screen.dart` pour utiliser `_onPickPhoto()` au lieu de `_onPickPhotoWithChoice()`:
```dart
// Dans le build()
ChatInputBar(
  onPickPhoto: _onPickPhoto,  // ← Galerie uniquement
  // ...
)
```

### Solution 2: Créer un nouvel émulateur
1. Ouvrir **AVD Manager**
2. Créer un nouveau device:
   - **Device**: Pixel 6
   - **System Image**: Android 13 (API 33) ou Android 12 (API 32)
   - **Camera**: `Emulated` pour les deux
3. Démarrer le nouvel émulateur

### Solution 3: Augmenter la RAM de l'émulateur
1. AVD Manager > Edit émulateur
2. **Show Advanced Settings**
3. **RAM**: Augmenter à 4096 MB
4. **VM heap**: Augmenter à 512 MB

## 📱 Test sur appareil réel

Pour tester la vraie caméra, utilisez un appareil physique:

```bash
# Activer le mode développeur sur votre téléphone
# Activer le débogage USB
# Connecter via USB

flutter devices
flutter run -d [device-id]
```

Sur appareil réel, vous pourrez utiliser `_onPickPhotoWithChoice()` pour avoir le choix galerie/caméra.

## ✅ Checklist de dépannage

- [ ] Permissions ajoutées dans AndroidManifest.xml
- [ ] `flutter clean` exécuté
- [ ] Application recompilée
- [ ] Émulateur redémarré
- [ ] Caméra configurée sur "Emulated" dans AVD Manager
- [ ] Images de test ajoutées dans la galerie de l'émulateur
- [ ] Bouton 📷 ouvre la galerie (pas la caméra)
- [ ] Sélection d'image fonctionne sans plantage

## 🎯 Résultat attendu

- ✅ Cliquer sur 📷 → Galerie s'ouvre immédiatement
- ✅ Sélectionner image → Pas de plantage
- ✅ Image envoyée → Apparaît dans le chat
- ✅ Logs: `📤 Envoi image: photo.jpg (123456 bytes)`
- ✅ Message: `📷 Image envoyée!`

## 🔄 Alternative: Désactiver le bouton photo sur émulateur

Si les problèmes persistent, vous pouvez détecter l'émulateur et désactiver la photo:

```dart
// Dans chat_screen.dart
import 'dart:io';

bool get isEmulator {
  // Sur Android, vérifier si c'est un émulateur
  return Platform.isAndroid; // Simplification
}

ChatInputBar(
  onPickPhoto: isEmulator ? () {
    _showSnackBar('Photo non disponible sur émulateur');
  } : _onPickPhoto,
)
```
