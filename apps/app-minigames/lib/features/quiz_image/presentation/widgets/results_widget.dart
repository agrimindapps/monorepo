import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget that displays quiz results with score and celebration animation
class ResultsWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int highScore;
  final VoidCallback onRestart;

  const ResultsWidget({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.highScore,
    required this.onRestart,
  });

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Color> _celebrationColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // If score is good, start animation
    if (widget.score / widget.totalQuestions >= 0.7) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate success percentage
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    final String message = _getMessageForScore(percentage);

    return Stack(
      children: [
        // Celebration effect for high scores
        if (percentage >= 70)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CelebrationPainter(
                  colors: _celebrationColors,
                  progress: _animationController.value,
                ),
              );
            },
          ),

        // Main content
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Score circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorForScore(percentage),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _getColorForScore(percentage).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.score}/${widget.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Score message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _getColorForScore(percentage),
                ),
              ),
              const SizedBox(height: 24),

              // High score badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Melhor pontuação: ${widget.highScore}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Play again button
              ElevatedButton(
                onPressed: widget.onRestart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Jogar Novamente'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForScore(int percentage) {
    if (percentage < 50) {
      return Colors.red.shade700;
    } else if (percentage < 70) {
      return Colors.amber.shade700;
    } else if (percentage < 90) {
      return Colors.blue.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  String _getMessageForScore(int percentage) {
    if (percentage < 50) {
      return 'Continue praticando!';
    } else if (percentage < 70) {
      return 'Bom trabalho!';
    } else if (percentage < 90) {
      return 'Muito bom!';
    } else {
      return 'Excelente!';
    }
  }
}

/// Custom painter for celebration effect
class CelebrationPainter extends CustomPainter {
  final List<Color> colors;
  final double progress;
  final math.Random random = math.Random(42);

  CelebrationPainter({required this.colors, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const int particleCount = 50;

    for (int i = 0; i < particleCount; i++) {
      final color = colors[i % colors.length];
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final baseSize = 4.0 + random.nextDouble() * 8.0;

      // Particle movement based on animation progress
      final x = baseX + math.sin((progress * 2 * math.pi) + i) * 50;
      final y =
          baseY - progress * (size.height * 0.3) * (1 + random.nextDouble());

      // Variable size for pulsating effect
      final particleSize =
          baseSize * (1.0 + math.sin(progress * 2 * math.pi) * 0.2);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.7 - progress * 0.3)
        ..style = PaintingStyle.fill;

      // Draw particle
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
