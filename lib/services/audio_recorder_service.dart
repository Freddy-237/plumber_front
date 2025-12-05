import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  RecorderController? _recorderController;
  bool _isRecording = false;
  DateTime? _recordStart;
  String? _recordingPath;

  bool get isInitialized => true;
  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;

  Future<void> initialize() async {
    debugPrint('✅ AudioRecorder initialisé');
  }

  Future<void> dispose() async {
    _recorderController?.dispose();
    _recorderController = null;
  }

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (!await hasPermission()) {
      throw Exception('Permission microphone refusée');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _recordingPath = '${tempDir.path}/audio_$timestamp.m4a';

    debugPrint('🎙️ Démarrage enregistrement: $_recordingPath');

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    await _recorderController!.record(path: _recordingPath!);

    _isRecording = true;
    _recordStart = DateTime.now();
    debugPrint('✅ Enregistrement démarré');

    // Basic runtime check: wait a short time and verify file is being written.
    try {
      final file = File(_recordingPath!);
      const int attempts = 6; // ~3 seconds
      int i = 0;
      while (i < attempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (await file.exists()) {
          final len = await file.length();
          debugPrint('📄 Enregistrement: fichier existe, taille=${len} bytes');
          if (len > 0) break;
        } else {
          debugPrint(
              '📄 Enregistrement: fichier non trouvé (tentative ${i + 1})');
        }
        i++;
      }
      if (!await file.exists() || await file.length() == 0) {
        debugPrint('⚠️ Aucune donnée audio écrite après démarrage.');
      }
    } catch (e) {
      debugPrint('⚠️ Erreur pendant les vérifications d\'enregistrement: $e');
    }
  }

  Future<Map<String, dynamic>> stopRecording() async {
    if (!_isRecording) {
      throw Exception('Aucun enregistrement en cours');
    }

    debugPrint('⏹️ Arrêt enregistrement...');
    final path = await _recorderController?.stop();

    final start = _recordStart ?? DateTime.now();
    final duration = DateTime.now().difference(start);

    _isRecording = false;

    if (path != null && await File(path).exists()) {
      final file = File(path);
      final len = await file.length();
      final result = {
        'path': path,
        'duration': duration,
        'bytes': len,
      };

      debugPrint('✅ Enregistrement sauvegardé: $path (taille=${len} bytes)');
      debugPrint('⏱️ Durée: ${duration.inSeconds}s');

      _recordStart = null;
      _recordingPath = null;
      _recorderController?.dispose();
      _recorderController = null;

      if (len == 0) {
        debugPrint(
            '⚠️ Le fichier audio est vide. Vérifiez les permissions et le format.');
      }

      return result;
    } else {
      throw Exception('Fichier audio introuvable');
    }
  }

  void cancelRecording() {
    _isRecording = false;
    _recordStart = null;
    _recordingPath = null;
    _recorderController?.dispose();
    _recorderController = null;
  }
}
