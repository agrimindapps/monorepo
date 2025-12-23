import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Category of Flappy Bird achievement
enum FlappyAchievementCategory {
  beginner('Iniciante', '🌱', 'Primeiros passos'),
  scoring('Pontuação', '🎯', 'Conquistas de pontos'),
  streak('Sequência', '🔥', 'Sequências de jogos'),
  difficulty('Dificuldade', '⭐', 'Conquistas por nível'),
  gameMode('Modos', '🎮', 'Modos de jogo'),
  special('Especial', '💎', 'Conquistas raras');

  final String label;
  final String emoji;
  final String description;
  const FlappyAchievementCategory(this.label, this.emoji, this.description);
}

/// Rarity of achievement
enum FlappyAchievementRarity {
  common('Comum', Color(0xFF9E9E9E), 10),
  uncommon('Incomum', Color(0xFF4CAF50), 25),
  rare('Raro', Color(0xFF2196F3), 50),
  epic('Épico', Color(0xFF9C27B0), 100),
  legendary('Lendário', Color(0xFFFF9800), 250);

  final String label;
  final Color color;
  final int xpReward;
  const FlappyAchievementRarity(this.label, this.color, this.xpReward);
}

/// Definition of a Flappy Bird achievement
class FlappyAchievementDefinition extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final FlappyAchievementCategory category;
  final FlappyAchievementRarity rarity;
  final int target;
  final bool isSecret;

  const FlappyAchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.rarity,
    required this.target,
    this.isSecret = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        emoji,
        category,
        rarity,
        target,
        isSecret,
      ];
}

/// Player's achievement state
class FlappyAchievement extends Equatable {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const FlappyAchievement({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Get the definition for this achievement
  FlappyAchievementDefinition get definition =>
      FlappyAchievementDefinitions.getById(id);

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent {
    final target = definition.target;
    if (target <= 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  /// Progress percentage as int (0 to 100)
  int get progressPercentInt => (progressPercent * 100).round();

  /// Create unlocked achievement
  FlappyAchievement unlock() => FlappyAchievement(
        id: id,
        currentProgress: definition.target,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  /// Create with updated progress
  FlappyAchievement withProgress(int progress) {
    final target = definition.target;
    final shouldUnlock = progress >= target && !isUnlocked;
    return FlappyAchievement(
      id: id,
      currentProgress: progress.clamp(0, target),
      isUnlocked: shouldUnlock || isUnlocked,
      unlockedAt: shouldUnlock ? DateTime.now() : unlockedAt,
    );
  }

  FlappyAchievement copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return FlappyAchievement(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [id, currentProgress, isUnlocked, unlockedAt];
}

/// All Flappy Bird achievement definitions (35 achievements)
class FlappyAchievementDefinitions {
  FlappyAchievementDefinitions._();

  static const List<FlappyAchievementDefinition> all = [
    // ==================== INICIANTE (6) ====================
    FlappyAchievementDefinition(
      id: 'first_game',
      title: 'Primeiro Voo',
      description: 'Complete seu primeiro jogo',
      emoji: '🐣',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.common,
      target: 1,
    ),
    FlappyAchievementDefinition(
      id: 'first_pipe',
      title: 'Primeiros Passos',
      description: 'Passe 1 pipe',
      emoji: '🚀',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.common,
      target: 1,
    ),
    FlappyAchievementDefinition(
      id: 'pipes_5',
      title: 'Decolando',
      description: 'Passe 5 pipes em uma partida',
      emoji: '✈️',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.common,
      target: 5,
    ),
    FlappyAchievementDefinition(
      id: 'games_10',
      title: 'Praticante',
      description: 'Jogue 10 partidas',
      emoji: '🎯',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.common,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'games_50',
      title: 'Dedicado',
      description: 'Jogue 50 partidas',
      emoji: '💪',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.uncommon,
      target: 50,
    ),
    FlappyAchievementDefinition(
      id: 'games_100',
      title: 'Veterano',
      description: 'Jogue 100 partidas',
      emoji: '🎖️',
      category: FlappyAchievementCategory.beginner,
      rarity: FlappyAchievementRarity.rare,
      target: 100,
    ),

    // ==================== PONTUAÇÃO (8) ====================
    FlappyAchievementDefinition(
      id: 'score_10',
      title: 'Bronze',
      description: 'Alcance 10 pontos',
      emoji: '🥉',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.common,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'score_25',
      title: 'Prata',
      description: 'Alcance 25 pontos',
      emoji: '🥈',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.uncommon,
      target: 25,
    ),
    FlappyAchievementDefinition(
      id: 'score_50',
      title: 'Ouro',
      description: 'Alcance 50 pontos',
      emoji: '🥇',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.rare,
      target: 50,
    ),
    FlappyAchievementDefinition(
      id: 'score_75',
      title: 'Platina',
      description: 'Alcance 75 pontos',
      emoji: '💠',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.epic,
      target: 75,
    ),
    FlappyAchievementDefinition(
      id: 'score_100',
      title: 'Diamante',
      description: 'Alcance 100 pontos',
      emoji: '💎',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.legendary,
      target: 100,
    ),
    FlappyAchievementDefinition(
      id: 'total_score_500',
      title: 'Acumulador',
      description: 'Acumule 500 pontos total',
      emoji: '📊',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.rare,
      target: 500,
    ),
    FlappyAchievementDefinition(
      id: 'total_score_1000',
      title: 'Milionário',
      description: 'Acumule 1000 pontos total',
      emoji: '💰',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.epic,
      target: 1000,
    ),
    FlappyAchievementDefinition(
      id: 'total_pipes_500',
      title: 'Maratonista',
      description: 'Passe 500 pipes no total',
      emoji: '🏃',
      category: FlappyAchievementCategory.scoring,
      rarity: FlappyAchievementRarity.rare,
      target: 500,
    ),

    // ==================== STREAK (5) ====================
    FlappyAchievementDefinition(
      id: 'streak_3',
      title: 'Aquecendo',
      description: '3 partidas seguidas com 5+ pontos',
      emoji: '🔥',
      category: FlappyAchievementCategory.streak,
      rarity: FlappyAchievementRarity.common,
      target: 3,
    ),
    FlappyAchievementDefinition(
      id: 'streak_5',
      title: 'Em Chamas',
      description: '5 partidas seguidas com 10+ pontos',
      emoji: '🔥',
      category: FlappyAchievementCategory.streak,
      rarity: FlappyAchievementRarity.uncommon,
      target: 5,
    ),
    FlappyAchievementDefinition(
      id: 'streak_10',
      title: 'Consistente',
      description: '10 partidas seguidas sem 0 pontos',
      emoji: '💪',
      category: FlappyAchievementCategory.streak,
      rarity: FlappyAchievementRarity.rare,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'beat_highscore_5',
      title: 'Superação',
      description: 'Supere seu high score 5 vezes',
      emoji: '📈',
      category: FlappyAchievementCategory.streak,
      rarity: FlappyAchievementRarity.epic,
      target: 5,
    ),
    FlappyAchievementDefinition(
      id: 'beat_highscore_10',
      title: 'Lenda',
      description: 'Supere seu high score 10 vezes',
      emoji: '👑',
      category: FlappyAchievementCategory.streak,
      rarity: FlappyAchievementRarity.legendary,
      target: 10,
    ),

    // ==================== DIFICULDADE (6) ====================
    FlappyAchievementDefinition(
      id: 'easy_10',
      title: 'Easy Peasy',
      description: '10 pontos no Easy',
      emoji: '🌟',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.common,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'medium_10',
      title: 'Médio Completo',
      description: '10 pontos no Medium',
      emoji: '⭐',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.uncommon,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'hard_10',
      title: 'Hardcore',
      description: '10 pontos no Hard',
      emoji: '🌠',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.rare,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'easy_50',
      title: 'Easy Master',
      description: '50 pontos no Easy',
      emoji: '🏅',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.uncommon,
      target: 50,
    ),
    FlappyAchievementDefinition(
      id: 'medium_25',
      title: 'Medium Master',
      description: '25 pontos no Medium',
      emoji: '🥇',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.rare,
      target: 25,
    ),
    FlappyAchievementDefinition(
      id: 'hard_15',
      title: 'Hard Master',
      description: '15 pontos no Hard',
      emoji: '🏆',
      category: FlappyAchievementCategory.difficulty,
      rarity: FlappyAchievementRarity.epic,
      target: 15,
    ),

    // ==================== MODOS DE JOGO (4) ====================
    FlappyAchievementDefinition(
      id: 'time_attack_survive',
      title: 'Sobrevivente',
      description: 'Sobreviva no Time Attack',
      emoji: '⏱️',
      category: FlappyAchievementCategory.gameMode,
      rarity: FlappyAchievementRarity.uncommon,
      target: 1,
    ),
    FlappyAchievementDefinition(
      id: 'speed_run_50',
      title: 'Velocista',
      description: '50 pontos no Speed Run',
      emoji: '🏎️',
      category: FlappyAchievementCategory.gameMode,
      rarity: FlappyAchievementRarity.rare,
      target: 50,
    ),
    FlappyAchievementDefinition(
      id: 'night_mode_25',
      title: 'Coruja',
      description: '25 pontos no Night Mode',
      emoji: '🦉',
      category: FlappyAchievementCategory.gameMode,
      rarity: FlappyAchievementRarity.rare,
      target: 25,
    ),
    FlappyAchievementDefinition(
      id: 'hardcore_mode_10',
      title: 'Destemido',
      description: '10 pontos no Hardcore Mode',
      emoji: '💀',
      category: FlappyAchievementCategory.gameMode,
      rarity: FlappyAchievementRarity.epic,
      target: 10,
    ),

    // ==================== ESPECIAL (6) ====================
    FlappyAchievementDefinition(
      id: 'close_call_10',
      title: 'Por um Fio',
      description: 'Quase colida 10 vezes',
      emoji: '😰',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.uncommon,
      target: 10,
    ),
    FlappyAchievementDefinition(
      id: 'total_flaps_1000',
      title: 'Batedor de Asas',
      description: 'Execute 1000 flaps',
      emoji: '🦅',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.rare,
      target: 1000,
    ),
    FlappyAchievementDefinition(
      id: 'play_time_30min',
      title: 'Maratona',
      description: 'Jogue por 30 minutos total',
      emoji: '⏰',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.rare,
      target: 1800, // 30 minutes in seconds
    ),
    FlappyAchievementDefinition(
      id: 'powerup_collector',
      title: 'Colecionador',
      description: 'Colete 50 power-ups',
      emoji: '🎁',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.rare,
      target: 50,
    ),
    FlappyAchievementDefinition(
      id: 'perfect_hard',
      title: 'Pássaro Perfeito',
      description: '50 pontos no Hard',
      emoji: '🌟',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.legendary,
      target: 50,
      isSecret: true,
    ),
    FlappyAchievementDefinition(
      id: 'shield_save',
      title: 'Vida Extra',
      description: 'Seja salvo pelo Shield',
      emoji: '🛡️',
      category: FlappyAchievementCategory.special,
      rarity: FlappyAchievementRarity.uncommon,
      target: 1,
      isSecret: true,
    ),
  ];

  /// Get achievement by ID
  static FlappyAchievementDefinition getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => throw ArgumentError('Achievement not found: $id'),
    );
  }

  /// Get achievements by category
  static List<FlappyAchievementDefinition> getByCategory(
    FlappyAchievementCategory category,
  ) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<FlappyAchievementDefinition> getByRarity(
    FlappyAchievementRarity rarity,
  ) {
    return all.where((a) => a.rarity == rarity).toList();
  }

  /// Get secret achievements
  static List<FlappyAchievementDefinition> get secrets {
    return all.where((a) => a.isSecret).toList();
  }

  /// Get non-secret achievements
  static List<FlappyAchievementDefinition> get nonSecrets {
    return all.where((a) => !a.isSecret).toList();
  }

  /// Total XP available from all achievements
  static int get totalXpAvailable {
    return all.fold<int>(0, (sum, a) => sum + a.rarity.xpReward);
  }

  /// Total achievement count
  static int get totalCount => all.length;

  /// Check if ID exists
  static bool exists(String id) {
    return all.any((a) => a.id == id);
  }
}

/// Helper class to combine achievement with its definition
class FlappyAchievementWithDefinition {
  final FlappyAchievement achievement;
  final FlappyAchievementDefinition definition;

  FlappyAchievementWithDefinition({
    required this.achievement,
    required this.definition,
  });

  factory FlappyAchievementWithDefinition.fromAchievement(
    FlappyAchievement achievement,
  ) {
    return FlappyAchievementWithDefinition(
      achievement: achievement,
      definition: achievement.definition,
    );
  }
}
