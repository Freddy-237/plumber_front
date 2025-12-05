import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Sélectionner une image depuis la galerie
  Future<Map<String, dynamic>?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('❌ Aucune image sélectionnée');
        return null;
      }

      debugPrint('✅ Image sélectionnée: ${image.name}');
      final bytes = await image.readAsBytes();

      return {
        'fileBytes': bytes,
        'fileName': image.name,
        'mimeType': image.mimeType ?? 'image/jpeg',
      };
    } catch (e) {
      debugPrint('❌ Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<Map<String, dynamic>?> takePhoto() async {
    try {
      debugPrint('📷 Tentative d\'ouverture de la caméra...');

      final XFile? photo = await _picker
          .pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ Timeout lors de l\'ouverture de la caméra');
          throw Exception('Timeout: La caméra met trop de temps à répondre');
        },
      );

      if (photo == null) {
        debugPrint('❌ Aucune photo prise (annulé par l\'utilisateur)');
        return null;
      }

      debugPrint('✅ Photo prise: ${photo.name}');
      final bytes = await photo.readAsBytes();

      return {
        'fileBytes': bytes,
        'fileName': photo.name,
        'mimeType': photo.mimeType ?? 'image/jpeg',
      };
    } on Exception catch (e) {
      debugPrint('❌ Exception lors de la prise de photo: $e');
      rethrow;
    } catch (e) {
      debugPrint('❌ Erreur inattendue lors de la prise de photo: $e');
      throw Exception('Erreur caméra: ${e.toString()}');
    }
  }

  /// Sélectionner plusieurs images
  Future<List<Map<String, dynamic>>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        debugPrint('❌ Aucune image sélectionnée');
        return [];
      }

      debugPrint('✅ ${images.length} images sélectionnées');

      final List<Map<String, dynamic>> results = [];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        results.add({
          'fileBytes': bytes,
          'fileName': image.name,
          'mimeType': image.mimeType ?? 'image/jpeg',
        });
      }

      return results;
    } catch (e) {
      debugPrint('❌ Erreur lors de la sélection des images: $e');
      return [];
    }
  }
}
