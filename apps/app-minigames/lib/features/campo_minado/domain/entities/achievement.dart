import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Category of Campo Minado achievement
enum CampoMinadoAchievementCategory {
  beginner('Iniciante', '🌱', 'Primeiros passos'),
  speed('Velocidade', '⚡', 'Conquistas de tempo'),
  precision('Precisão', '🎯', 'Precisão e técnica'),
  streak('Sequência', '🔥', 'Sequência de vitórias'),
  difficulty('Dificuldade', '⭐', 'Conquistas por nível'),
  special('Especial', '💎', 'Conquistas raras');

  final String label;
  final String emoji;
  final String description;
  const CampoMinadoAchievementCategory(this.label, this.emoji, this.description);
}

/// Rarity of achievement
enum CampoMinadoAchievementRarity {
  common('Comum', Color(0xFF9E9E9E), 10),
  uncommon('Incomum', Color(0xFF4CAF50), 25),
  rare('Raro', Color(0xFF2196F3), 50),
  epic('Épico', Color(0xFF9C27B0), 100),
  legendary('Lendário', Color(0xFFFF9800), 250);

  final String label;
  final Color color;
  final int xpReward;
  const CampoMinadoAchievementRarity(this.label, this.color, this.xpReward);
}

/// Definition of a Campo Minado achievement
class CampoMinadoAchievementDefinition extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final CampoMinadoAchievementCategory category;
  final CampoMinadoAchievementRarity rarity;
  final int target;
  final bool isSecret;

  const CampoMinadoAchievementDefinition({
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
class CampoMinadoAchievement extends Equatable {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const CampoMinadoAchievement({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Get the definition for this achievement
  CampoMinadoAchievementDefinition get definition =>
      CampoMinadoAchievementDefinitions.getById(id);

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent {
    final target = definition.target;
    if (target <= 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  /// Progress percentage as int (0 to 100)
  int get progressPercentInt => (progressPercent * 100).round();

  /// Create unlocked achievement
  CampoMinadoAchievement unlock() => CampoMinadoAchievement(
        id: id,
        currentProgress: definition.target,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  /// Create with updated progress
  CampoMinadoAchievement withProgress(int progress) {
    final target = definition.target;
    final shouldUnlock = progress >= target && !isUnlocked;
    return CampoMinadoAchievement(
      id: id,
      currentProgress: progress.clamp(0, target),
      isUnlocked: shouldUnlock || isUnlocked,
      unlockedAt: shouldUnlock ? DateTime.now() : unlockedAt,
    );
  }

  CampoMinadoAchievement copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return CampoMinadoAchievement(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [id, currentProgress, isUnlocked, unlockedAt];
}

/// All Campo Minado achievement definitions
class CampoMinadoAchievementDefinitions {
  CampoMinadoAchievementDefinitions._();

  static const List<CampoMinadoAchievementDefinition> all = [
    // ==================== INICIANTE (6) ====================
    CampoMinadoAchievementDefinition(
      id: 'first_win',
      title: 'Primeira Vitória',
      description: 'Vença seu primeiro jogo',
      emoji: '🏆',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.common,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'first_flag',
      title: 'Detector de Minas',
      description: 'Marque sua primeira bandeira',
      emoji: '🚩',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.common,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'games_10',
      title: 'Praticante',
      description: 'Jogue 10 partidas',
      emoji: '🎯',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.common,
      target: 10,
    ),
    CampoMinadoAchievementDefinition(
      id: 'games_50',
      title: 'Dedicado',
      description: 'Jogue 50 partidas',
      emoji: '💪',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 50,
    ),
    CampoMinadoAchievementDefinition(
      id: 'games_100',
      title: 'Veterano',
      description: 'Jogue 100 partidas',
      emoji: '🎖️',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 100,
    ),
    CampoMinadoAchievementDefinition(
      id: 'games_500',
      title: 'Maratonista',
      description: 'Jogue 500 partidas',
      emoji: '🏃',
      category: CampoMinadoAchievementCategory.beginner,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 500,
    ),

    // ==================== VELOCIDADE (6) ====================
    CampoMinadoAchievementDefinition(
      id: 'beginner_30s',
      title: 'Raio',
      description: 'Complete Iniciante em menos de 30 segundos',
      emoji: '⚡',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'beginner_20s',
      title: 'Relâmpago',
      description: 'Complete Iniciante em menos de 20 segundos',
      emoji: '🌩️',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'intermediate_120s',
      title: 'Veloz',
      description: 'Complete Intermediário em menos de 2 minutos',
      emoji: '🏎️',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'intermediate_90s',
      title: 'Turbo',
      description: 'Complete Intermediário em menos de 90 segundos',
      emoji: '🚀',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'expert_300s',
      title: 'Flash',
      description: 'Complete Expert em menos de 5 minutos',
      emoji: '💨',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'expert_180s',
      title: 'Sonic',
      description: 'Complete Expert em menos de 3 minutos',
      emoji: '🔵',
      category: CampoMinadoAchievementCategory.speed,
      rarity: CampoMinadoAchievementRarity.legendary,
      target: 1,
    ),

    // ==================== PRECISÃO (5) ====================
    CampoMinadoAchievementDefinition(
      id: 'no_wrong_flags',
      title: 'Cirurgião',
      description: 'Complete sem bandeiras erradas',
      emoji: '🎯',
      category: CampoMinadoAchievementCategory.precision,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'perfect_flags',
      title: 'Mestre das Bandeiras',
      description: 'Use exatamente o número de minas em bandeiras',
      emoji: '🏁',
      category: CampoMinadoAchievementCategory.precision,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'first_click_safe',
      title: 'Sortudo',
      description: 'Revele 5 ou mais células no primeiro clique',
      emoji: '🍀',
      category: CampoMinadoAchievementCategory.precision,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'chord_master_50',
      title: 'Chord Iniciante',
      description: 'Use chord click 50 vezes',
      emoji: '🎹',
      category: CampoMinadoAchievementCategory.precision,
      rarity: CampoMinadoAchievementRarity.common,
      target: 50,
    ),
    CampoMinadoAchievementDefinition(
      id: 'chord_master_200',
      title: 'Chord Expert',
      description: 'Use chord click 200 vezes',
      emoji: '🎼',
      category: CampoMinadoAchievementCategory.precision,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 200,
    ),

    // ==================== STREAK (4) ====================
    CampoMinadoAchievementDefinition(
      id: 'streak_3',
      title: 'Aquecendo',
      description: 'Vença 3 jogos seguidos',
      emoji: '🔥',
      category: CampoMinadoAchievementCategory.streak,
      rarity: CampoMinadoAchievementRarity.common,
      target: 3,
    ),
    CampoMinadoAchievementDefinition(
      id: 'streak_5',
      title: 'Em Chamas',
      description: 'Vença 5 jogos seguidos',
      emoji: '🔥',
      category: CampoMinadoAchievementCategory.streak,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 5,
    ),
    CampoMinadoAchievementDefinition(
      id: 'streak_10',
      title: 'Imbatível',
      description: 'Vença 10 jogos seguidos',
      emoji: '💪',
      category: CampoMinadoAchievementCategory.streak,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 10,
    ),
    CampoMinadoAchievementDefinition(
      id: 'streak_25',
      title: 'Lenda Viva',
      description: 'Vença 25 jogos seguidos',
      emoji: '👑',
      category: CampoMinadoAchievementCategory.streak,
      rarity: CampoMinadoAchievementRarity.legendary,
      target: 25,
    ),

    // ==================== DIFICULDADE (5) ====================
    CampoMinadoAchievementDefinition(
      id: 'win_beginner',
      title: 'Iniciante Completo',
      description: 'Vença no modo Iniciante',
      emoji: '🌟',
      category: CampoMinadoAchievementCategory.difficulty,
      rarity: CampoMinadoAchievementRarity.common,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'win_intermediate',
      title: 'Intermediário Completo',
      description: 'Vença no modo Intermediário',
      emoji: '⭐',
      category: CampoMinadoAchievementCategory.difficulty,
      rarity: CampoMinadoAchievementRarity.uncommon,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'win_expert',
      title: 'Expert Completo',
      description: 'Vença no modo Expert',
      emoji: '🌠',
      category: CampoMinadoAchievementCategory.difficulty,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 1,
    ),
    CampoMinadoAchievementDefinition(
      id: 'win_all_difficulties',
      title: 'Explorador',
      description: 'Vença em todas as dificuldades',
      emoji: '🗺️',
      category: CampoMinadoAchievementCategory.difficulty,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 3,
    ),
    CampoMinadoAchievementDefinition(
      id: 'master_expert',
      title: 'Mestre Expert',
      description: 'Vença 10 vezes no Expert',
      emoji: '🏅',
      category: CampoMinadoAchievementCategory.difficulty,
      rarity: CampoMinadoAchievementRarity.legendary,
      target: 10,
    ),

    // ==================== ESPECIAL/SECRETO (4) ====================
    CampoMinadoAchievementDefinition(
      id: 'lucky_first_click',
      title: 'Super Sortudo',
      description: 'Revele 15 ou mais células no primeiro clique',
      emoji: '🎰',
      category: CampoMinadoAchievementCategory.special,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 1,
      isSecret: true,
    ),
    CampoMinadoAchievementDefinition(
      id: 'total_cells_1000',
      title: 'Minerador',
      description: 'Revele 1000 células no total',
      emoji: '⛏️',
      category: CampoMinadoAchievementCategory.special,
      rarity: CampoMinadoAchievementRarity.rare,
      target: 1000,
    ),
    CampoMinadoAchievementDefinition(
      id: 'total_cells_10000',
      title: 'Escavador Mestre',
      description: 'Revele 10000 células no total',
      emoji: '🏗️',
      category: CampoMinadoAchievementCategory.special,
      rarity: CampoMinadoAchievementRarity.epic,
      target: 10000,
    ),
    CampoMinadoAchievementDefinition(
      id: 'total_wins_100',
      title: 'Centurião',
      description: 'Vença 100 partidas no total',
      emoji: '💯',
      category: CampoMinadoAchievementCategory.special,
      rarity: CampoMinadoAchievementRarity.legendary,
      target: 100,
    ),
  ];

  /// Get achievement by ID
  static CampoMinadoAchievementDefinition getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => throw ArgumentError('Achievement not found: $id'),
    );
  }

  /// Get achievements by category
  static List<CampoMinadoAchievementDefinition> getByCategory(
    CampoMinadoAchievementCategory category,
  ) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<CampoMinadoAchievementDefinition> getByRarity(
    CampoMinadoAchievementRarity rarity,
  ) {
    return all.where((a) => a.rarity == rarity).toList();
  }

  /// Get secret achievements
  static List<CampoMinadoAchievementDefinition> get secrets {
    return all.where((a) => a.isSecret).toList();
  }

  /// Get non-secret achievements
  static List<CampoMinadoAchievementDefinition> get nonSecrets {
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
