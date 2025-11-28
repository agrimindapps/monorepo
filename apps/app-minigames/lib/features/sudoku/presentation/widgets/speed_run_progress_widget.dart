import 'package:flutter/material.dart';

/// Widget displaying SpeedRun progress
class SpeedRunProgressWidget extends StatelessWidget {
  final int completed;
  final int total;
  final Duration totalTime;
  final Duration? currentPuzzleTime;

  const SpeedRunProgressWidget({
    super.key,
    required this.completed,
    required this.total,
    required this.totalTime,
    this.currentPuzzleTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.speed, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Speed Run',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Puzzle progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (index) {
              final isCompleted = index < completed;
              final isCurrent = index == completed;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildProgressDot(isCompleted, isCurrent),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Progress text
          Text(
            'Puzzle ${completed + 1} de $total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),

          // Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeColumn(
                'Total',
                _formatDuration(totalTime),
                Colors.purple,
              ),
              if (currentPuzzleTime != null)
                _buildTimeColumn(
                  'Atual',
                  _formatDuration(currentPuzzleTime!),
                  Colors.grey.shade700,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(bool isCompleted, bool isCurrent) {
    Color color;
    IconData? icon;

    if (isCompleted) {
      color = Colors.green;
      icon = Icons.check;
    } else if (isCurrent) {
      color = Colors.purple;
      icon = Icons.play_arrow;
    } else {
      color = Colors.grey.shade300;
      icon = null;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 18)
          : null,
    );
  }

  Widget _buildTimeColumn(String label, String time, Color color) {
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Compact SpeedRun progress for stats bar
class SpeedRunStatWidget extends StatelessWidget {
  final int completed;
  final int total;
  final Duration totalTime;

  const SpeedRunStatWidget({
    super.key,
    required this.completed,
    required this.total,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = totalTime.inMinutes;
    final seconds = totalTime.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.speed, size: 20, color: Colors.purple),
        const SizedBox(height: 4),
        Text(
          '${completed + 1}/$total',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          timeString,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// SpeedRun completion summary
class SpeedRunSummaryWidget extends StatelessWidget {
  final int puzzlesCompleted;
  final Duration totalTime;
  final List<Duration> puzzleTimes;

  const SpeedRunSummaryWidget({
    super.key,
    required this.puzzlesCompleted,
    required this.totalTime,
    this.puzzleTimes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final avgTime = puzzlesCompleted > 0
        ? Duration(seconds: totalTime.inSeconds ~/ puzzlesCompleted)
        : Duration.zero;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Speed Run Completo!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Puzzles', '$puzzlesCompleted', Icons.grid_3x3),
              _buildStat('Total', _formatDuration(totalTime), Icons.timer),
              _buildStat('Média', _formatDuration(avgTime), Icons.speed),
            ],
          ),

          // Best time badge
          if (puzzleTimes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Melhor puzzle: ${_formatDuration(_findBestTime())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Duration _findBestTime() {
    if (puzzleTimes.isEmpty) return Duration.zero;
    return puzzleTimes.reduce((a, b) => a < b ? a : b);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
