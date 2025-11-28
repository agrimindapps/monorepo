import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Category of Sudoku achievement
enum SudokuAchievementCategory {
  beginner('Iniciante', '🌱', 'Primeiros passos'),
  speed('Velocidade', '⚡', 'Conquistas de tempo'),
  precision('Precisão', '🎯', 'Precisão e técnica'),
  streak('Sequência', '🔥', 'Sequência de vitórias'),
  difficulty('Dificuldade', '⭐', 'Conquistas por nível'),
  notes('Notas', '📝', 'Estratégia com notas'),
  special('Especial', '💎', 'Conquistas raras');

  final String label;
  final String emoji;
  final String description;
  const SudokuAchievementCategory(this.label, this.emoji, this.description);
}

/// Rarity of achievement
enum SudokuAchievementRarity {
  common('Comum', Color(0xFF9E9E9E), 10),
  uncommon('Incomum', Color(0xFF4CAF50), 25),
  rare('Raro', Color(0xFF2196F3), 50),
  epic('Épico', Color(0xFF9C27B0), 100),
  legendary('Lendário', Color(0xFFFF9800), 250);

  final String label;
  final Color color;
  final int xpReward;
  const SudokuAchievementRarity(this.label, this.color, this.xpReward);
}

/// Definition of a Sudoku achievement
class SudokuAchievementDefinition extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final SudokuAchievementCategory category;
  final SudokuAchievementRarity rarity;
  final int target;
  final bool isSecret;

  const SudokuAchievementDefinition({
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
class SudokuAchievement extends Equatable {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const SudokuAchievement({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Get the definition for this achievement
  SudokuAchievementDefinition get definition =>
      SudokuAchievementDefinitions.getById(id);

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent {
    final target = definition.target;
    if (target <= 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  /// Progress percentage as int (0 to 100)
  int get progressPercentInt => (progressPercent * 100).round();

  /// Create unlocked achievement
  SudokuAchievement unlock() => SudokuAchievement(
        id: id,
        currentProgress: definition.target,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  /// Create with updated progress
  SudokuAchievement withProgress(int progress) {
    final target = definition.target;
    final shouldUnlock = progress >= target && !isUnlocked;
    return SudokuAchievement(
      id: id,
      currentProgress: progress.clamp(0, target),
      isUnlocked: shouldUnlock || isUnlocked,
      unlockedAt: shouldUnlock ? DateTime.now() : unlockedAt,
    );
  }

  SudokuAchievement copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return SudokuAchievement(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [id, currentProgress, isUnlocked, unlockedAt];
}

/// All Sudoku achievement definitions (44 achievements)
class SudokuAchievementDefinitions {
  SudokuAchievementDefinitions._();

  static const List<SudokuAchievementDefinition> all = [
    // ==================== INICIANTE (7) ====================
    SudokuAchievementDefinition(
      id: 'first_puzzle',
      title: 'Primeiro Puzzle',
      description: 'Complete seu primeiro Sudoku',
      emoji: '🏆',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.common,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'first_note',
      title: 'Anotador',
      description: 'Use notas pela primeira vez',
      emoji: '📝',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.common,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'first_hint',
      title: 'Precisei de Ajuda',
      description: 'Use uma dica',
      emoji: '💡',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.common,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'puzzles_10',
      title: 'Praticante',
      description: 'Complete 10 puzzles',
      emoji: '🎯',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.common,
      target: 10,
    ),
    SudokuAchievementDefinition(
      id: 'puzzles_50',
      title: 'Dedicado',
      description: 'Complete 50 puzzles',
      emoji: '💪',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.uncommon,
      target: 50,
    ),
    SudokuAchievementDefinition(
      id: 'puzzles_100',
      title: 'Veterano',
      description: 'Complete 100 puzzles',
      emoji: '🎖️',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.rare,
      target: 100,
    ),
    SudokuAchievementDefinition(
      id: 'puzzles_500',
      title: 'Mestre Sudoku',
      description: 'Complete 500 puzzles',
      emoji: '👑',
      category: SudokuAchievementCategory.beginner,
      rarity: SudokuAchievementRarity.epic,
      target: 500,
    ),

    // ==================== VELOCIDADE (8) ====================
    SudokuAchievementDefinition(
      id: 'easy_5min',
      title: 'Aquecimento',
      description: 'Complete Fácil em menos de 5 minutos',
      emoji: '⏱️',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.common,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'easy_3min',
      title: 'Raio',
      description: 'Complete Fácil em menos de 3 minutos',
      emoji: '⚡',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'easy_2min',
      title: 'Relâmpago',
      description: 'Complete Fácil em menos de 2 minutos',
      emoji: '🌩️',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'medium_10min',
      title: 'Eficiente',
      description: 'Complete Médio em menos de 10 minutos',
      emoji: '🏎️',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'medium_7min',
      title: 'Veloz',
      description: 'Complete Médio em menos de 7 minutos',
      emoji: '🚀',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'hard_20min',
      title: 'Determinado',
      description: 'Complete Difícil em menos de 20 minutos',
      emoji: '💨',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'hard_15min',
      title: 'Flash',
      description: 'Complete Difícil em menos de 15 minutos',
      emoji: '⚡',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.epic,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'hard_10min',
      title: 'Speedrunner',
      description: 'Complete Difícil em menos de 10 minutos',
      emoji: '🔵',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.legendary,
      target: 1,
    ),

    // ==================== PRECISÃO (7) ====================
    SudokuAchievementDefinition(
      id: 'no_mistakes_1',
      title: 'Perfeição',
      description: 'Complete 1 puzzle sem erros',
      emoji: '✨',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'no_mistakes_5',
      title: 'Cirurgião',
      description: 'Complete 5 puzzles sem erros',
      emoji: '🎯',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.rare,
      target: 5,
    ),
    SudokuAchievementDefinition(
      id: 'no_mistakes_25',
      title: 'Infalível',
      description: 'Complete 25 puzzles sem erros',
      emoji: '💎',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.epic,
      target: 25,
    ),
    SudokuAchievementDefinition(
      id: 'no_hints_1',
      title: 'Independente',
      description: 'Complete sem usar dicas',
      emoji: '🧠',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'no_hints_10',
      title: 'Autodidata',
      description: 'Complete 10 puzzles sem dicas',
      emoji: '📚',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.rare,
      target: 10,
    ),
    SudokuAchievementDefinition(
      id: 'perfect_game',
      title: 'Jogo Perfeito',
      description: 'Complete sem erros E sem dicas',
      emoji: '🌟',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'perfect_10',
      title: 'Perfeccionista',
      description: '10 jogos perfeitos',
      emoji: '👑',
      category: SudokuAchievementCategory.precision,
      rarity: SudokuAchievementRarity.epic,
      target: 10,
    ),

    // ==================== STREAK (5) ====================
    SudokuAchievementDefinition(
      id: 'streak_3',
      title: 'Aquecendo',
      description: 'Complete 3 puzzles seguidos',
      emoji: '🔥',
      category: SudokuAchievementCategory.streak,
      rarity: SudokuAchievementRarity.common,
      target: 3,
    ),
    SudokuAchievementDefinition(
      id: 'streak_5',
      title: 'Em Chamas',
      description: 'Complete 5 puzzles seguidos',
      emoji: '🔥',
      category: SudokuAchievementCategory.streak,
      rarity: SudokuAchievementRarity.uncommon,
      target: 5,
    ),
    SudokuAchievementDefinition(
      id: 'streak_10',
      title: 'Imbatível',
      description: 'Complete 10 puzzles seguidos',
      emoji: '💪',
      category: SudokuAchievementCategory.streak,
      rarity: SudokuAchievementRarity.rare,
      target: 10,
    ),
    SudokuAchievementDefinition(
      id: 'streak_25',
      title: 'Lenda',
      description: 'Complete 25 puzzles seguidos',
      emoji: '👑',
      category: SudokuAchievementCategory.streak,
      rarity: SudokuAchievementRarity.epic,
      target: 25,
    ),
    SudokuAchievementDefinition(
      id: 'streak_50',
      title: 'Imortal',
      description: 'Complete 50 puzzles seguidos',
      emoji: '🏆',
      category: SudokuAchievementCategory.streak,
      rarity: SudokuAchievementRarity.legendary,
      target: 50,
    ),

    // ==================== DIFICULDADE (7) ====================
    SudokuAchievementDefinition(
      id: 'easy_complete',
      title: 'Iniciante',
      description: 'Complete um puzzle Fácil',
      emoji: '🌟',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.common,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'medium_complete',
      title: 'Intermediário',
      description: 'Complete um puzzle Médio',
      emoji: '⭐',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'hard_complete',
      title: 'Expert',
      description: 'Complete um puzzle Difícil',
      emoji: '🌠',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'all_difficulties',
      title: 'Explorador',
      description: 'Complete todas as dificuldades',
      emoji: '🗺️',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.rare,
      target: 3,
    ),
    SudokuAchievementDefinition(
      id: 'easy_master',
      title: 'Mestre Fácil',
      description: 'Complete 50 puzzles Fácil',
      emoji: '🏅',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.uncommon,
      target: 50,
    ),
    SudokuAchievementDefinition(
      id: 'medium_master',
      title: 'Mestre Médio',
      description: 'Complete 25 puzzles Médio',
      emoji: '🥇',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.rare,
      target: 25,
    ),
    SudokuAchievementDefinition(
      id: 'hard_master',
      title: 'Mestre Difícil',
      description: 'Complete 10 puzzles Difícil',
      emoji: '🏆',
      category: SudokuAchievementCategory.difficulty,
      rarity: SudokuAchievementRarity.epic,
      target: 10,
    ),

    // ==================== NOTAS (4) ====================
    SudokuAchievementDefinition(
      id: 'notes_100',
      title: 'Organizador',
      description: 'Coloque 100 notas no total',
      emoji: '📝',
      category: SudokuAchievementCategory.notes,
      rarity: SudokuAchievementRarity.common,
      target: 100,
    ),
    SudokuAchievementDefinition(
      id: 'notes_500',
      title: 'Estrategista',
      description: 'Coloque 500 notas no total',
      emoji: '📊',
      category: SudokuAchievementCategory.notes,
      rarity: SudokuAchievementRarity.uncommon,
      target: 500,
    ),
    SudokuAchievementDefinition(
      id: 'notes_1000',
      title: 'Mestre das Notas',
      description: 'Coloque 1000 notas no total',
      emoji: '📚',
      category: SudokuAchievementCategory.notes,
      rarity: SudokuAchievementRarity.rare,
      target: 1000,
    ),
    SudokuAchievementDefinition(
      id: 'minimalist',
      title: 'Minimalista',
      description: 'Complete Hard usando menos de 10 notas',
      emoji: '✏️',
      category: SudokuAchievementCategory.notes,
      rarity: SudokuAchievementRarity.epic,
      target: 1,
    ),

    // ==================== ESPECIAL (6) ====================
    SudokuAchievementDefinition(
      id: 'cells_1000',
      title: 'Trabalhador',
      description: 'Preencha 1000 células no total',
      emoji: '⛏️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.rare,
      target: 1000,
    ),
    SudokuAchievementDefinition(
      id: 'cells_10000',
      title: 'Incansável',
      description: 'Preencha 10000 células no total',
      emoji: '🏗️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.epic,
      target: 10000,
    ),
    SudokuAchievementDefinition(
      id: 'hints_100',
      title: 'Estudante',
      description: 'Use 100 dicas no total',
      emoji: '💡',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.uncommon,
      target: 100,
    ),
    SudokuAchievementDefinition(
      id: 'hard_perfect',
      title: 'Elite',
      description: 'Complete Hard sem erros',
      emoji: '💎',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.legendary,
      target: 1,
      isSecret: true,
    ),
    SudokuAchievementDefinition(
      id: 'hard_no_hints',
      title: 'Gênio',
      description: 'Complete Hard sem dicas',
      emoji: '🧠',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.epic,
      target: 1,
      isSecret: true,
    ),
    SudokuAchievementDefinition(
      id: 'ultimate',
      title: 'Lenda Suprema',
      description: 'Complete Hard < 10min, sem erros, sem dicas',
      emoji: '🌟',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.legendary,
      target: 1,
      isSecret: true,
    ),

    // ==================== GAME MODES (10) ====================
    SudokuAchievementDefinition(
      id: 'time_attack_easy',
      title: 'Contra o Relógio',
      description: 'Complete TimeAttack no Fácil',
      emoji: '⏱️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.uncommon,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'time_attack_hard',
      title: 'Mestre do Tempo',
      description: 'Complete TimeAttack no Difícil',
      emoji: '⏰',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.epic,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'hardcore_survivor',
      title: 'Sobrevivente',
      description: 'Complete Hardcore sem perder nenhuma vida',
      emoji: '💀',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.legendary,
      target: 1,
      isSecret: true,
    ),
    SudokuAchievementDefinition(
      id: 'hardcore_complete',
      title: 'Desafiante',
      description: 'Complete um puzzle no modo Hardcore',
      emoji: '☠️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'speed_run_complete',
      title: 'Corredor',
      description: 'Complete um Speed Run',
      emoji: '🏃',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.rare,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'speed_run_15min',
      title: 'Velocista',
      description: 'Complete Speed Run em menos de 15 minutos',
      emoji: '🚀',
      category: SudokuAchievementCategory.speed,
      rarity: SudokuAchievementRarity.epic,
      target: 1,
    ),
    SudokuAchievementDefinition(
      id: 'zen_master',
      title: 'Mestre Zen',
      description: 'Complete 10 puzzles no modo Zen',
      emoji: '🧘',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.rare,
      target: 10,
    ),
    SudokuAchievementDefinition(
      id: 'undo_master',
      title: 'Segunda Chance',
      description: 'Use undo 100 vezes no total',
      emoji: '↩️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.uncommon,
      target: 100,
    ),
    SudokuAchievementDefinition(
      id: 'all_modes',
      title: 'Explorador de Modos',
      description: 'Complete ao menos um puzzle em cada modo',
      emoji: '🗺️',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.epic,
      target: 5,
    ),
    SudokuAchievementDefinition(
      id: 'hardcore_hard',
      title: 'Lendário',
      description: 'Complete Hardcore no modo Difícil',
      emoji: '💎',
      category: SudokuAchievementCategory.special,
      rarity: SudokuAchievementRarity.legendary,
      target: 1,
      isSecret: true,
    ),
  ];

  /// Get achievement by ID
  static SudokuAchievementDefinition getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => throw ArgumentError('Achievement not found: $id'),
    );
  }

  /// Get achievements by category
  static List<SudokuAchievementDefinition> getByCategory(
    SudokuAchievementCategory category,
  ) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<SudokuAchievementDefinition> getByRarity(
    SudokuAchievementRarity rarity,
  ) {
    return all.where((a) => a.rarity == rarity).toList();
  }

  /// Get secret achievements
  static List<SudokuAchievementDefinition> get secrets {
    return all.where((a) => a.isSecret).toList();
  }

  /// Get non-secret achievements
  static List<SudokuAchievementDefinition> get nonSecrets {
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
