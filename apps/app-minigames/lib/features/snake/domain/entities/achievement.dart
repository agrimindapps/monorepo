// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

/// Category of achievement
enum AchievementCategory {
  beginner('Iniciante', '🌱', 'Primeiros passos'),
  score('Pontuação', '🏆', 'Conquistas de score'),
  survival('Sobrevivência', '⏱️', 'Tempo vivo'),
  length('Tamanho', '📏', 'Tamanho da cobra'),
  powerUp('Power-Ups', '⚡', 'Uso de power-ups'),
  mode('Modos', '🎮', 'Conquistas de modo'),
  special('Especial', '⭐', 'Conquistas raras'),
  master('Mestre', '👑', 'Conquistas elite');

  final String label;
  final String emoji;
  final String description;
  const AchievementCategory(this.label, this.emoji, this.description);
}

/// Rarity of achievement
enum AchievementRarity {
  common('Comum', Color(0xFF9E9E9E), 10),
  uncommon('Incomum', Color(0xFF4CAF50), 25),
  rare('Raro', Color(0xFF2196F3), 50),
  epic('Épico', Color(0xFF9C27B0), 100),
  legendary('Lendário', Color(0xFFFF9800), 250);

  final String label;
  final Color color;
  final int xpReward;
  const AchievementRarity(this.label, this.color, this.xpReward);
}

/// Definition of an achievement
class AchievementDefinition extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int target;
  final bool isSecret;

  const AchievementDefinition({
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
class Achievement extends Equatable {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Get the definition for this achievement
  AchievementDefinition get definition => AchievementDefinitions.getById(id);

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent {
    final target = definition.target;
    if (target <= 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  /// Progress percentage as int (0 to 100)
  int get progressPercentInt => (progressPercent * 100).round();

  /// Create unlocked achievement
  Achievement unlock() => Achievement(
        id: id,
        currentProgress: definition.target,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  /// Create with updated progress
  Achievement withProgress(int progress) {
    final target = definition.target;
    final shouldUnlock = progress >= target && !isUnlocked;
    return Achievement(
      id: id,
      currentProgress: progress.clamp(0, target),
      isUnlocked: shouldUnlock || isUnlocked,
      unlockedAt: shouldUnlock ? DateTime.now() : unlockedAt,
    );
  }

  Achievement copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [id, currentProgress, isUnlocked, unlockedAt];
}

/// All achievement definitions
class AchievementDefinitions {
  AchievementDefinitions._();

  static const List<AchievementDefinition> all = [
    // ==================== INICIANTE (8) ====================
    AchievementDefinition(
      id: 'first_food',
      title: 'Primeira Refeição',
      description: 'Coma sua primeira comida',
      emoji: '🍎',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.common,
      target: 1,
    ),
    AchievementDefinition(
      id: 'first_game',
      title: 'Bem-Vindo',
      description: 'Complete sua primeira partida',
      emoji: '👋',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.common,
      target: 1,
    ),
    AchievementDefinition(
      id: 'first_power_up',
      title: 'Power Up!',
      description: 'Colete seu primeiro power-up',
      emoji: '⚡',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.common,
      target: 1,
    ),
    AchievementDefinition(
      id: 'games_10',
      title: 'Praticante',
      description: 'Jogue 10 partidas',
      emoji: '🎯',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.common,
      target: 10,
    ),
    AchievementDefinition(
      id: 'games_50',
      title: 'Dedicado',
      description: 'Jogue 50 partidas',
      emoji: '💪',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.uncommon,
      target: 50,
    ),
    AchievementDefinition(
      id: 'games_100',
      title: 'Viciado',
      description: 'Jogue 100 partidas',
      emoji: '🔥',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.rare,
      target: 100,
    ),
    AchievementDefinition(
      id: 'games_500',
      title: 'Maratonista',
      description: 'Jogue 500 partidas',
      emoji: '🏃',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.epic,
      target: 500,
    ),
    AchievementDefinition(
      id: 'play_time_60',
      title: 'Uma Hora',
      description: 'Jogue por 1 hora no total',
      emoji: '⏰',
      category: AchievementCategory.beginner,
      rarity: AchievementRarity.uncommon,
      target: 3600,
    ),

    // ==================== PONTUAÇÃO (6) ====================
    AchievementDefinition(
      id: 'score_25',
      title: 'Bom Começo',
      description: 'Alcance 25 pontos em uma partida',
      emoji: '🌟',
      category: AchievementCategory.score,
      rarity: AchievementRarity.common,
      target: 25,
    ),
    AchievementDefinition(
      id: 'score_50',
      title: 'Meio Centenário',
      description: 'Alcance 50 pontos em uma partida',
      emoji: '⭐',
      category: AchievementCategory.score,
      rarity: AchievementRarity.uncommon,
      target: 50,
    ),
    AchievementDefinition(
      id: 'score_100',
      title: 'Centurião',
      description: 'Alcance 100 pontos em uma partida',
      emoji: '💯',
      category: AchievementCategory.score,
      rarity: AchievementRarity.rare,
      target: 100,
    ),
    AchievementDefinition(
      id: 'score_200',
      title: 'Bicentenário',
      description: 'Alcance 200 pontos em uma partida',
      emoji: '🏅',
      category: AchievementCategory.score,
      rarity: AchievementRarity.epic,
      target: 200,
    ),
    AchievementDefinition(
      id: 'score_500',
      title: 'Lenda',
      description: 'Alcance 500 pontos em uma partida',
      emoji: '👑',
      category: AchievementCategory.score,
      rarity: AchievementRarity.legendary,
      target: 500,
    ),
    AchievementDefinition(
      id: 'total_score_1000',
      title: 'Acumulador',
      description: 'Acumule 1000 pontos no total',
      emoji: '💰',
      category: AchievementCategory.score,
      rarity: AchievementRarity.rare,
      target: 1000,
    ),

    // ==================== SOBREVIVÊNCIA (5) ====================
    AchievementDefinition(
      id: 'survive_30',
      title: 'Sobrevivente',
      description: 'Sobreviva 30 segundos em uma partida',
      emoji: '🛡️',
      category: AchievementCategory.survival,
      rarity: AchievementRarity.common,
      target: 30,
    ),
    AchievementDefinition(
      id: 'survive_60',
      title: 'Resistente',
      description: 'Sobreviva 1 minuto em uma partida',
      emoji: '⏱️',
      category: AchievementCategory.survival,
      rarity: AchievementRarity.uncommon,
      target: 60,
    ),
    AchievementDefinition(
      id: 'survive_120',
      title: 'Perseverante',
      description: 'Sobreviva 2 minutos em uma partida',
      emoji: '🏋️',
      category: AchievementCategory.survival,
      rarity: AchievementRarity.rare,
      target: 120,
    ),
    AchievementDefinition(
      id: 'survive_300',
      title: 'Imortal',
      description: 'Sobreviva 5 minutos em uma partida',
      emoji: '♾️',
      category: AchievementCategory.survival,
      rarity: AchievementRarity.epic,
      target: 300,
    ),
    AchievementDefinition(
      id: 'no_death_10_food',
      title: 'Início Perfeito',
      description: 'Coma 10 comidas sem morrer',
      emoji: '✨',
      category: AchievementCategory.survival,
      rarity: AchievementRarity.uncommon,
      target: 10,
    ),

    // ==================== TAMANHO (4) ====================
    AchievementDefinition(
      id: 'length_10',
      title: 'Crescendo',
      description: 'Alcance tamanho 10',
      emoji: '📏',
      category: AchievementCategory.length,
      rarity: AchievementRarity.common,
      target: 10,
    ),
    AchievementDefinition(
      id: 'length_25',
      title: 'Cobra Grande',
      description: 'Alcance tamanho 25',
      emoji: '🐍',
      category: AchievementCategory.length,
      rarity: AchievementRarity.uncommon,
      target: 25,
    ),
    AchievementDefinition(
      id: 'length_50',
      title: 'Píton',
      description: 'Alcance tamanho 50',
      emoji: '🦎',
      category: AchievementCategory.length,
      rarity: AchievementRarity.rare,
      target: 50,
    ),
    AchievementDefinition(
      id: 'length_100',
      title: 'Anaconda',
      description: 'Alcance tamanho 100',
      emoji: '🐲',
      category: AchievementCategory.length,
      rarity: AchievementRarity.legendary,
      target: 100,
    ),

    // ==================== POWER-UPS (8) ====================
    AchievementDefinition(
      id: 'power_ups_10',
      title: 'Colecionador',
      description: 'Colete 10 power-ups',
      emoji: '📦',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.common,
      target: 10,
    ),
    AchievementDefinition(
      id: 'power_ups_50',
      title: 'Acumulador de Power',
      description: 'Colete 50 power-ups',
      emoji: '🎁',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.uncommon,
      target: 50,
    ),
    AchievementDefinition(
      id: 'power_ups_100',
      title: 'Power Maniac',
      description: 'Colete 100 power-ups',
      emoji: '💎',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.rare,
      target: 100,
    ),
    AchievementDefinition(
      id: 'use_all_power_ups',
      title: 'Diversificado',
      description: 'Use todos os 6 tipos de power-up',
      emoji: '🌈',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.uncommon,
      target: 6,
    ),
    AchievementDefinition(
      id: 'ghost_master',
      title: 'Fantasma',
      description: 'Use Ghost Mode 10 vezes',
      emoji: '👻',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.uncommon,
      target: 10,
    ),
    AchievementDefinition(
      id: 'shield_master',
      title: 'Escudeiro',
      description: 'Use Shield 10 vezes',
      emoji: '🛡️',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.uncommon,
      target: 10,
    ),
    AchievementDefinition(
      id: 'speed_demon',
      title: 'Velocista',
      description: 'Use Speed Boost 10 vezes',
      emoji: '🚀',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.uncommon,
      target: 10,
    ),
    AchievementDefinition(
      id: 'double_points_master',
      title: 'Dobrador',
      description: 'Ganhe 100 pontos com Double Points ativo',
      emoji: '⭐',
      category: AchievementCategory.powerUp,
      rarity: AchievementRarity.rare,
      target: 100,
    ),

    // ==================== MODOS DE JOGO (6) ====================
    AchievementDefinition(
      id: 'win_classic',
      title: 'Clássico',
      description: 'Alcance 25 pontos no modo Classic',
      emoji: '🐍',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.common,
      target: 25,
    ),
    AchievementDefinition(
      id: 'win_survival',
      title: 'Sobrevivente Pro',
      description: 'Alcance 50 pontos no Survival',
      emoji: '⚡',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.rare,
      target: 50,
    ),
    AchievementDefinition(
      id: 'win_time_attack',
      title: 'Contra o Relógio',
      description: 'Alcance 30 pontos no Time Attack',
      emoji: '⏱️',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.uncommon,
      target: 30,
    ),
    AchievementDefinition(
      id: 'win_endless',
      title: 'Infinito',
      description: 'Alcance 100 pontos no Endless',
      emoji: '♾️',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.rare,
      target: 100,
    ),
    AchievementDefinition(
      id: 'win_hard',
      title: 'Hardcore',
      description: 'Alcance 50 pontos no Hard',
      emoji: '💀',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.epic,
      target: 50,
    ),
    AchievementDefinition(
      id: 'all_modes_played',
      title: 'Explorador',
      description: 'Jogue todos os 4 modos',
      emoji: '🗺️',
      category: AchievementCategory.mode,
      rarity: AchievementRarity.uncommon,
      target: 4,
    ),

    // ==================== ESPECIAL (5) ====================
    AchievementDefinition(
      id: 'close_call',
      title: 'Por um Fio',
      description: 'Escape de colisão usando Shield',
      emoji: '😅',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      target: 1,
      isSecret: true,
    ),
    AchievementDefinition(
      id: 'triple_power_up',
      title: 'Triplo Power',
      description: 'Tenha 3 power-ups ativos ao mesmo tempo',
      emoji: '🔥',
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      target: 1,
      isSecret: true,
    ),
    AchievementDefinition(
      id: 'comeback',
      title: 'Comeback',
      description: 'Recupere de 1 segmento para 10+ no Endless',
      emoji: '💪',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      target: 1,
      isSecret: true,
    ),
    AchievementDefinition(
      id: 'no_power_up_50',
      title: 'Purista',
      description: 'Alcance 50 pontos sem usar power-ups',
      emoji: '🧘',
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      target: 50,
      isSecret: true,
    ),
    AchievementDefinition(
      id: 'speed_run',
      title: 'Speed Runner',
      description: 'Alcance 25 pontos em menos de 30 segundos',
      emoji: '⚡',
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      target: 1,
      isSecret: true,
    ),

    // ==================== MESTRE (3) ====================
    AchievementDefinition(
      id: 'all_achievements',
      title: 'Completista',
      description: 'Desbloqueie todas as outras conquistas',
      emoji: '🏆',
      category: AchievementCategory.master,
      rarity: AchievementRarity.legendary,
      target: 1,
      isSecret: true,
    ),
    AchievementDefinition(
      id: 'level_50',
      title: 'Deus das Cobras',
      description: 'Alcance o nível 50',
      emoji: '👑',
      category: AchievementCategory.master,
      rarity: AchievementRarity.legendary,
      target: 50,
    ),
    AchievementDefinition(
      id: 'total_food_1000',
      title: 'Glutão',
      description: 'Coma 1000 comidas no total',
      emoji: '🍽️',
      category: AchievementCategory.master,
      rarity: AchievementRarity.legendary,
      target: 1000,
    ),
  ];

  /// Get achievement by ID
  static AchievementDefinition getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => throw ArgumentError('Achievement not found: $id'),
    );
  }

  /// Get achievements by category
  static List<AchievementDefinition> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<AchievementDefinition> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }

  /// Get secret achievements
  static List<AchievementDefinition> get secrets {
    return all.where((a) => a.isSecret).toList();
  }

  /// Get non-secret achievements
  static List<AchievementDefinition> get nonSecrets {
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
