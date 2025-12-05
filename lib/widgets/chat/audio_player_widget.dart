import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import '../../constants/colors.dart';
import '../../services/api_client.dart';
import 'audio_waveform_animation.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Duration? duration;
  final Color? iconColor;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.duration,
    this.iconColor,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupPlayer();
  }

  void _setupPlayer() {
    // Écouter les changements de position
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Écouter les changements de durée
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    // Écouter l'état du player pour gérer la lecture/fin
    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        final playing = playerState.playing;
        final processingState = playerState.processingState;

        if (processingState == ProcessingState.completed) {
          // lecture terminée
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }

        setState(() {
          _isPlaying = playing;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);

        // Vérifier si l'URL est vide
        if (widget.audioUrl.isEmpty) {
          throw Exception('URL audio vide');
        }

        // Construire l'URL complète
        String fullUrl;
        if (widget.audioUrl.startsWith('http')) {
          fullUrl = widget.audioUrl;
        } else {
          // S'assurer qu'il n'y a pas de double slash
          final cleanUrl = widget.audioUrl.startsWith('/')
              ? widget.audioUrl
              : '/$widget.audioUrl';
          fullUrl = '${ApiClient.baseUrl}$cleanUrl';
        }

        debugPrint('🎵 Lecture audio: $fullUrl');
        debugPrint('🎵 URL originale: ${widget.audioUrl}');

        // Vérifier si le fichier est accessible avant de jouer
        try {
          final dio = Dio();
          final response = await dio.head(
            fullUrl,
            options: Options(
              validateStatus: (status) => status! < 500,
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

          debugPrint('🔍 Vérification fichier: ${response.statusCode}');
          debugPrint('🔍 Headers: ${response.headers}');

          if (response.statusCode == 404) {
            throw Exception('Fichier non trouvé sur le serveur (404)');
          } else if (response.statusCode != 200) {
            debugPrint(
                '⚠️ Status code: ${response.statusCode}, on tente quand même...');
          }
        } catch (e) {
          if (e.toString().contains('404') ||
              e.toString().contains('non trouvé')) {
            throw e; // Re-throw si vraiment 404
          }
          debugPrint('⚠️ Impossible de vérifier le fichier: $e');
          // On continue pour tenter la lecture
        }

        // Tenter la lecture audio avec just_audio
        debugPrint('▶️ Démarrage lecture...');
        // setUrl is a convenience helper that sets the source and prepares it
        await _audioPlayer.setUrl(fullUrl);
        await _audioPlayer.play();

        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Erreur lecture audio: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        String errorMsg = 'Impossible de lire l\'audio';
        if (e.toString().contains('Timeout')) {
          errorMsg =
              'Le serveur ne répond pas. Vérifiez que le serveur sert bien le dossier /uploads';
        } else if (e.toString().contains('MEDIA_ERROR')) {
          errorMsg = 'Fichier audio introuvable ou format non supporté';
        } else if (e.toString().contains('URL audio vide')) {
          errorMsg = 'Le fichier audio est manquant';
        } else if (e.toString().contains('Fichier non trouvé')) {
          errorMsg = 'Le fichier n\'existe pas sur le serveur';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMsg,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Fichier: ${widget.audioUrl}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.secondaryColor,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? Theme.of(context).primaryColor;
    final displayDuration = _totalDuration > Duration.zero
        ? _totalDuration
        : (widget.duration ?? Duration.zero);

    // Vérifier si l'URL est vide et afficher un message d'erreur
    if (widget.audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Fichier audio manquant',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton play/pause (style WhatsApp)
          if (_isLoading)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            )
          else
            Material(
              color: color.withOpacity(0.1),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _togglePlayPause,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),

          // Animation de forme d'onde style WhatsApp
          Expanded(
            child: AudioWaveformAnimation(
              isPlaying: _isPlaying,
              color: color.withOpacity(0.7),
              width: 150,
              height: 24,
              barCount: 35,
            ),
          ),
          const SizedBox(width: 8),

          // Durée
          Text(
            _isPlaying
                ? _formatDuration(_currentPosition)
                : _formatDuration(displayDuration),
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
