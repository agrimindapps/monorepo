import 'package:equatable/equatable.dart';

import '../enums/challenge_type.dart';

/// Desafio semanal para o sistema FitQuest
class WeeklyChallenge extends Equatable {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.currentProgress,
    required this.startDate,
    required this.endDate,
    required this.xpReward,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int target;
  final int currentProgress;
  final DateTime startDate;
  final DateTime endDate;
  final int xpReward;
  final bool isCompleted;
  final DateTime? completedAt;

  /// Progresso percentual (0.0 - 1.0)
  double get progressPercent {
    if (target <= 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  /// Verifica se o desafio está ativo (dentro do período)
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isCompleted;
  }

  /// Verifica se o desafio expirou sem ser completado
  bool get isExpired {
    return DateTime.now().isAfter(endDate) && !isCompleted;
  }

  /// Dias restantes para completar
  int get daysRemaining {
    if (isCompleted || isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Cria um desafio vazio para inicialização
  factory WeeklyChallenge.empty() => WeeklyChallenge(
        id: '',
        title: '',
        description: '',
        type: ChallengeType.sessoes,
        target: 0,
        currentProgress: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        xpReward: 0,
      );

  WeeklyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? target,
    int? currentProgress,
    DateTime? startDate,
    DateTime? endDate,
    int? xpReward,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return WeeklyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'target': target,
        'currentProgress': currentProgress,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'xpReward': xpReward,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.millisecondsSinceEpoch,
      };

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChallengeType.sessoes,
      ),
      target: json['target'] as int,
      currentProgress: json['currentProgress'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int),
      xpReward: json['xpReward'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        target,
        currentProgress,
        startDate,
        endDate,
        xpReward,
        isCompleted,
        completedAt,
      ];
}
