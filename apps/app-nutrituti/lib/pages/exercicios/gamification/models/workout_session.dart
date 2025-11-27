import 'package:equatable/equatable.dart';

import '../enums/exercicio_categoria.dart';

/// Sessão de treino ativa para o sistema FitQuest
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.id,
    required this.exerciseType,
    required this.categoria,
    required this.startTime,
    this.endTime,
    this.pausedDuration = Duration.zero,
    this.isActive = true,
    this.isPaused = false,
    this.estimatedCalories = 0,
    this.pauseStartTime,
  });

  final String id;
  final String exerciseType;
  final ExercicioCategoria categoria;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration pausedDuration;
  final bool isActive;
  final bool isPaused;
  final int estimatedCalories;
  final DateTime? pauseStartTime;

  /// Duração efetiva do treino (excluindo pausas)
  Duration get effectiveDuration {
    final totalDuration = (endTime ?? DateTime.now()).difference(startTime);
    final currentPauseDuration = isPaused && pauseStartTime != null
        ? DateTime.now().difference(pauseStartTime!)
        : Duration.zero;
    return totalDuration - pausedDuration - currentPauseDuration;
  }

  /// Duração em minutos
  int get durationMinutes => effectiveDuration.inMinutes;

  /// Duração em segundos
  int get durationSeconds => effectiveDuration.inSeconds;

  /// Calcula calorias baseado na duração e categoria
  int calculateCalories() {
    final minutes = effectiveDuration.inMinutes;
    return (minutes * categoria.caloriasPorMinuto).round();
  }

  /// Cria uma sessão vazia
  factory WorkoutSession.empty() => WorkoutSession(
        id: '',
        exerciseType: '',
        categoria: ExercicioCategoria.outro,
        startTime: DateTime.now(),
        isActive: false,
      );

  /// Inicia uma nova sessão
  factory WorkoutSession.start({
    required String id,
    required String exerciseType,
    required ExercicioCategoria categoria,
  }) =>
      WorkoutSession(
        id: id,
        exerciseType: exerciseType,
        categoria: categoria,
        startTime: DateTime.now(),
        isActive: true,
        isPaused: false,
      );

  WorkoutSession copyWith({
    String? id,
    String? exerciseType,
    ExercicioCategoria? categoria,
    DateTime? startTime,
    DateTime? endTime,
    Duration? pausedDuration,
    bool? isActive,
    bool? isPaused,
    int? estimatedCalories,
    DateTime? pauseStartTime,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      categoria: categoria ?? this.categoria,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      pauseStartTime: pauseStartTime ?? this.pauseStartTime,
    );
  }

  /// Pausa a sessão
  WorkoutSession pause() {
    if (!isActive || isPaused) return this;
    return copyWith(
      isPaused: true,
      pauseStartTime: DateTime.now(),
    );
  }

  /// Retoma a sessão
  WorkoutSession resume() {
    if (!isActive || !isPaused || pauseStartTime == null) return this;
    final additionalPauseDuration = DateTime.now().difference(pauseStartTime!);
    return copyWith(
      isPaused: false,
      pausedDuration: pausedDuration + additionalPauseDuration,
      pauseStartTime: null,
    );
  }

  /// Finaliza a sessão
  WorkoutSession finish() {
    if (!isActive) return this;
    final session = isPaused ? resume() : this;
    return session.copyWith(
      isActive: false,
      endTime: DateTime.now(),
      estimatedCalories: session.calculateCalories(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseType': exerciseType,
        'categoria': categoria.name,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch,
        'pausedDuration': pausedDuration.inMilliseconds,
        'isActive': isActive,
        'isPaused': isPaused,
        'estimatedCalories': estimatedCalories,
        'pauseStartTime': pauseStartTime?.millisecondsSinceEpoch,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      exerciseType: json['exerciseType'] as String,
      categoria: ExercicioCategoria.fromName(json['categoria'] as String),
      startTime:
          DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: json['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int)
          : null,
      pausedDuration:
          Duration(milliseconds: json['pausedDuration'] as int? ?? 0),
      isActive: json['isActive'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      estimatedCalories: json['estimatedCalories'] as int? ?? 0,
      pauseStartTime: json['pauseStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['pauseStartTime'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exerciseType,
        categoria,
        startTime,
        endTime,
        pausedDuration,
        isActive,
        isPaused,
        estimatedCalories,
        pauseStartTime,
      ];
}
