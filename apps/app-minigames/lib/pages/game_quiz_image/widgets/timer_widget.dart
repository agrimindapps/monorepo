// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class TimerWidget extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const TimerWidget({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula a proporção de tempo restante
    final progress = timeLeft / totalTime;

    // Determina a cor com base no tempo restante
    final color = _getColorForProgress(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto com tempo restante
        Row(
          children: [
            const Icon(Icons.timer, size: 18),
            const SizedBox(width: 5),
            Text(
              '$timeLeft s',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Barra de progresso
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: GameColors.timeBarBackground,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(double progress) {
    // Vermelho quando menos de 20% do tempo
    if (progress < 0.2) {
      return Colors.red;
    }
    // Laranja quando menos de 50% do tempo
    else if (progress < 0.5) {
      return Colors.orange;
    }
    // Verde para o resto do tempo
    else {
      return GameColors.timeBarForeground;
    }
  }
}
