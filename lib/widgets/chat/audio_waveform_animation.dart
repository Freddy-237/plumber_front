import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animation de forme d'onde audio style WhatsApp
class AudioWaveformAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double width;
  final double height;
  final int barCount;

  const AudioWaveformAnimation({
    super.key,
    required this.isPlaying,
    required this.color,
    this.width = 100,
    this.height = 24,
    this.barCount = 30,
  });

  @override
  State<AudioWaveformAnimation> createState() => _AudioWaveformAnimationState();
}

class _AudioWaveformAnimationState extends State<AudioWaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    _initializeBarHeights();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  void _initializeBarHeights() {
    final random = math.Random();
    _barHeights.clear();
    for (int i = 0; i < widget.barCount; i++) {
      // Créer un pattern varié mais harmonieux
      final height = 0.3 + (random.nextDouble() * 0.7);
      _barHeights.add(height);
    }
  }

  @override
  void didUpdateWidget(AudioWaveformAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _WaveformPainter(
            barHeights: _barHeights,
            color: widget.color,
            animationValue: _controller.value,
            isPlaying: widget.isPlaying,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final double animationValue;
  final bool isPlaying;

  _WaveformPainter({
    required this.barHeights,
    required this.color,
    required this.animationValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final barWidth = 2.5;
    final spacing =
        (size.width - (barHeights.length * barWidth)) / (barHeights.length - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < barHeights.length; i++) {
      final x = i * (barWidth + spacing);

      // Animation sinusoïdale pour donner l'impression de mouvement
      final wave = isPlaying
          ? math.sin((animationValue * 2 * math.pi) + (i * 0.5)) * 0.3 + 0.7
          : 1.0;

      final barHeight = barHeights[i] * size.height * wave;

      // Dessiner une barre centrée verticalement
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.color != color;
  }
}
