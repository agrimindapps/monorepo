// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Modelo para perfil de jogador com dados persistentes
class PlayerProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  DateTime lastPlayed;
  
  // Estatísticas do jogador
  int totalGamesPlayed;
  int totalScore;
  int bestScore;
  int totalWordsCompleted;
  Map<WordCategory, int> categoryProgress;
  Map<Difficulty, int> difficultyProgress;
  
  // Configurações personalizadas
  Difficulty preferredDifficulty;
  WordCategory preferredCategory;
  bool soundEnabled;
  bool animationsEnabled;
  
  // Conquistas e marcos
  List<String> achievements;
  Map<String, DateTime> milestones;
  
  PlayerProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? lastPlayed,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.totalWordsCompleted = 0,
    Map<WordCategory, int>? categoryProgress,
    Map<Difficulty, int>? difficultyProgress,
    this.preferredDifficulty = Difficulty.normal,
    this.preferredCategory = WordCategory.fruits,
    this.soundEnabled = true,
    this.animationsEnabled = true,
    List<String>? achievements,
    Map<String, DateTime>? milestones,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastPlayed = lastPlayed ?? DateTime.now(),
       categoryProgress = categoryProgress ?? {},
       difficultyProgress = difficultyProgress ?? {},
       achievements = achievements ?? [],
       milestones = milestones ?? {};

  /// Serializa o perfil para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'bestScore': bestScore,
      'totalWordsCompleted': totalWordsCompleted,
      'categoryProgress': categoryProgress.map((k, v) => MapEntry(k.name, v)),
      'difficultyProgress': difficultyProgress.map((k, v) => MapEntry(k.name, v)),
      'preferredDifficulty': preferredDifficulty.name,
      'preferredCategory': preferredCategory.name,
      'soundEnabled': soundEnabled,
      'animationsEnabled': animationsEnabled,
      'achievements': achievements,
      'milestones': milestones.map((k, v) => MapEntry(k, v.toIso8601String())),
      'version': '1.0.0',
    };
  }

  /// Deserializa o perfil de JSON
  static PlayerProfile fromJson(Map<String, dynamic> json) {
    // Validação de versão
    if (json['version'] != '1.0.0') {
      throw ArgumentError('Versão do perfil incompatível: ${json['version']}');
    }

    return PlayerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      totalGamesPlayed: (json['totalGamesPlayed'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toInt(),
      bestScore: (json['bestScore'] as num).toInt(),
      totalWordsCompleted: (json['totalWordsCompleted'] as num).toInt(),
      categoryProgress: _parseEnumMap<WordCategory>(
        json['categoryProgress'] as Map<String, dynamic>? ?? {},
        WordCategory.values,
      ),
      difficultyProgress: _parseEnumMap<Difficulty>(
        json['difficultyProgress'] as Map<String, dynamic>? ?? {},
        Difficulty.values,
      ),
      preferredDifficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['preferredDifficulty'],
        orElse: () => Difficulty.normal,
      ),
      preferredCategory: WordCategory.values.firstWhere(
        (c) => c.name == json['preferredCategory'],
        orElse: () => WordCategory.fruits,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      animationsEnabled: json['animationsEnabled'] as bool? ?? true,
      achievements: List<String>.from(json['achievements'] ?? []),
      milestones: _parseMilestones(json['milestones'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Helper para parsear enum maps
  static Map<T, int> _parseEnumMap<T extends Enum>(
    Map<String, dynamic> json,
    List<T> enumValues,
  ) {
    final result = <T, int>{};
    for (final entry in json.entries) {
      final enumValue = enumValues.cast<T?>().firstWhere(
        (e) => e?.toString().split('.').last == entry.key,
        orElse: () => null,
      );
      if (enumValue != null) {
        result[enumValue] = (entry.value as num).toInt();
      }
    }
    return result;
  }

  /// Helper para parsear milestones
  static Map<String, DateTime> _parseMilestones(Map<String, dynamic> json) {
    final result = <String, DateTime>{};
    for (final entry in json.entries) {
      try {
        result[entry.key] = DateTime.parse(entry.value as String);
      } catch (e) {
        // Ignora milestones com formato inválido
      }
    }
    return result;
  }

  /// Atualiza estatísticas após um jogo
  void updateAfterGame({
    required int gameScore,
    required WordCategory category,
    required Difficulty difficulty,
    required bool completed,
  }) {
    lastPlayed = DateTime.now();
    totalGamesPlayed++;
    totalScore += gameScore;
    
    if (gameScore > bestScore) {
      bestScore = gameScore;
      milestones['best_score_achieved'] = DateTime.now();
    }
    
    if (completed) {
      totalWordsCompleted++;
      categoryProgress[category] = (categoryProgress[category] ?? 0) + 1;
      difficultyProgress[difficulty] = (difficultyProgress[difficulty] ?? 0) + 1;
      
      // Verifica conquistas
      _checkAchievements();
    }
  }

  /// Verifica e adiciona conquistas
  void _checkAchievements() {
    // Primeira palavra completada
    if (totalWordsCompleted == 1 && !achievements.contains('first_word')) {
      achievements.add('first_word');
      milestones['first_word'] = DateTime.now();
    }
    
    // 10 palavras completadas
    if (totalWordsCompleted >= 10 && !achievements.contains('word_master_10')) {
      achievements.add('word_master_10');
      milestones['word_master_10'] = DateTime.now();
    }
    
    // 100 palavras completadas
    if (totalWordsCompleted >= 100 && !achievements.contains('word_master_100')) {
      achievements.add('word_master_100');
      milestones['word_master_100'] = DateTime.now();
    }
    
    // Todas as categorias jogadas
    if (categoryProgress.length >= WordCategory.values.length && 
        !achievements.contains('category_explorer')) {
      achievements.add('category_explorer');
      milestones['category_explorer'] = DateTime.now();
    }
    
    // Score alto
    if (bestScore >= 1000 && !achievements.contains('high_scorer')) {
      achievements.add('high_scorer');
      milestones['high_scorer'] = DateTime.now();
    }
  }

  /// Calcula nível do jogador baseado na experiência
  int get level => (totalWordsCompleted / 10).floor() + 1;

  /// Calcula progresso para o próximo nível
  double get levelProgress {
    final currentLevelWords = (level - 1) * 10;
    final nextLevelWords = level * 10;
    final progress = (totalWordsCompleted - currentLevelWords) / (nextLevelWords - currentLevelWords);
    return progress.clamp(0.0, 1.0);
  }

  /// Obtém categoria favorita (mais jogada)
  WordCategory? get favoriteCategory {
    if (categoryProgress.isEmpty) return null;
    
    return categoryProgress.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Obtém dificuldade mais jogada
  Difficulty? get mostPlayedDifficulty {
    if (difficultyProgress.isEmpty) return null;
    
    return difficultyProgress.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Calcula taxa de sucesso geral
  double get successRate {
    if (totalGamesPlayed == 0) return 0.0;
    return totalWordsCompleted / totalGamesPlayed;
  }

  /// Obtém estatísticas resumidas
  Map<String, dynamic> getStatsSummary() {
    return {
      'level': level,
      'levelProgress': levelProgress,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWordsCompleted': totalWordsCompleted,
      'bestScore': bestScore,
      'successRate': successRate,
      'favoriteCategory': favoriteCategory?.name,
      'achievementsCount': achievements.length,
      'daysSinceCreated': DateTime.now().difference(createdAt).inDays,
    };
  }

  /// Valida se o perfil é válido
  bool isValid() {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           totalGamesPlayed >= 0 && 
           totalScore >= 0 && 
           bestScore >= 0 && 
           totalWordsCompleted >= 0;
  }

  /// Cria uma cópia do perfil com modificações
  PlayerProfile copyWith({
    String? name,
    String? avatarUrl,
    Difficulty? preferredDifficulty,
    WordCategory? preferredCategory,
    bool? soundEnabled,
    bool? animationsEnabled,
  }) {
    return PlayerProfile(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastPlayed: lastPlayed,
      totalGamesPlayed: totalGamesPlayed,
      totalScore: totalScore,
      bestScore: bestScore,
      totalWordsCompleted: totalWordsCompleted,
      categoryProgress: Map.from(categoryProgress),
      difficultyProgress: Map.from(difficultyProgress),
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      preferredCategory: preferredCategory ?? this.preferredCategory,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      achievements: List.from(achievements),
      milestones: Map.from(milestones),
    );
  }

  @override
  String toString() => 'PlayerProfile(id: $id, name: $name, level: $level)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
