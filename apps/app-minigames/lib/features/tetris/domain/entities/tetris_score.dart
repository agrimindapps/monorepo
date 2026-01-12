import 'package:equatable/equatable.dart';

/// Entidade que representa um score/partida de Tetris
class TetrisScore extends Equatable {
  /// ID único do score
  final String id;

  /// Pontuação obtida
  final int score;

  /// Número de linhas completadas
  final int lines;

  /// Nível alcançado
  final int level;

  /// Duração da partida
  final Duration duration;

  /// Data/hora de conclusão
  final DateTime completedAt;

  /// Total de Tetris (4 linhas de uma vez) nesta partida
  final int tetrisCount;

  /// Maior combo nesta partida
  final int maxTetrisCombo;

  /// Nome do jogador (opcional)
  final String? playerName;

  const TetrisScore({
    required this.id,
    required this.score,
    required this.lines,
    required this.level,
    required this.duration,
    required this.completedAt,
    this.tetrisCount = 0,
    this.maxTetrisCombo = 0,
    this.playerName,
  });

  /// Factory para criar um novo score
  factory TetrisScore.create({
    required int score,
    required int lines,
    required int level,
    required Duration duration,
    int tetrisCount = 0,
    int maxTetrisCombo = 0,
    String? playerName,
  }) {
    return TetrisScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      lines: lines,
      level: level,
      duration: duration,
      completedAt: DateTime.now(),
      tetrisCount: tetrisCount,
      maxTetrisCombo: maxTetrisCombo,
      playerName: playerName,
    );
  }

  /// Cria cópia com campos modificados
  TetrisScore copyWith({
    String? id,
    int? score,
    int? lines,
    int? level,
    Duration? duration,
    DateTime? completedAt,
    int? tetrisCount,
    int? maxTetrisCombo,
    String? playerName,
  }) {
    return TetrisScore(
      id: id ?? this.id,
      score: score ?? this.score,
      lines: lines ?? this.lines,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      completedAt: completedAt ?? this.completedAt,
      tetrisCount: tetrisCount ?? this.tetrisCount,
      maxTetrisCombo: maxTetrisCombo ?? this.maxTetrisCombo,
      playerName: playerName ?? this.playerName,
    );
  }

  /// Duração formatada (mm:ss)
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Data formatada
  String get formattedDate {
    return '${completedAt.day.toString().padLeft(2, '0')}/${completedAt.month.toString().padLeft(2, '0')}/${completedAt.year}';
  }

  @override
  List<Object?> get props => [
    id,
    score,
    lines,
    level,
    duration,
    completedAt,
    tetrisCount,
    maxTetrisCombo,
    playerName,
  ];

  @override
  String toString() {
    return 'TetrisScore(id: $id, score: $score, lines: $lines, level: $level, duration: $formattedDuration)';
  }
}
