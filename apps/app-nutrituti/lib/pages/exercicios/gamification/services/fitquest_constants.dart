import '../enums/challenge_type.dart';
import '../models/achievement_definition.dart';

/// Constantes de gamificação para o sistema FitQuest
class FitQuestConstants {
  FitQuestConstants._();

  // ============================================================================
  // XP E NÍVEIS
  // ============================================================================

  /// XP base por minuto de exercício
  static const int xpPerMinute = 2;

  /// XP por 10 calorias queimadas
  static const int xpPer10Calories = 1;

  /// Bônus máximo de streak (50%)
  static const double maxStreakBonusPercent = 0.5;

  /// Bônus de streak por dia (10%)
  static const double streakBonusPerDay = 0.1;

  /// Limites de XP para cada nível
  static const Map<int, int> levelXpThresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2100,
    8: 2800,
    9: 3600,
    10: 4500,
  };

  /// Títulos para cada nível
  static const Map<int, String> levelTitles = {
    1: 'Iniciante',
    2: 'Aprendiz',
    3: 'Praticante',
    4: 'Dedicado',
    5: 'Guerreiro',
    6: 'Atleta',
    7: 'Veterano',
    8: 'Mestre',
    9: 'Campeão',
    10: 'Lenda Fitness',
  };

  // ============================================================================
  // STREAKS
  // ============================================================================

  /// Horas máximas entre treinos para manter streak
  static const int maxHoursBetweenWorkouts = 36;

  // ============================================================================
  // DESAFIOS SEMANAIS
  // ============================================================================

  /// XP base para desafios semanais
  static const int baseChallengeXp = 50;

  /// Multiplicador de XP por nível do usuário
  static const double challengeXpMultiplier = 0.1;

  /// Templates de desafios semanais
  static const List<Map<String, dynamic>> challengeTemplates = [
    // Minutos
    {
      'type': ChallengeType.minutos,
      'title': '🏋️ Semana Ativa',
      'description': 'Acumule {target} minutos de exercício',
      'baseTarget': 60,
      'levelMultiplier': 1.2,
      'xpReward': 75,
    },
    {
      'type': ChallengeType.minutos,
      'title': '⏱️ Hora do Treino',
      'description': 'Complete {target} minutos nesta semana',
      'baseTarget': 90,
      'levelMultiplier': 1.15,
      'xpReward': 100,
    },
    // Calorias
    {
      'type': ChallengeType.calorias,
      'title': '🔥 Queima Total',
      'description': 'Queime {target} calorias',
      'baseTarget': 500,
      'levelMultiplier': 1.3,
      'xpReward': 80,
    },
    {
      'type': ChallengeType.calorias,
      'title': '🌋 Vulcão em Erupção',
      'description': 'Elimine {target} calorias com exercícios',
      'baseTarget': 800,
      'levelMultiplier': 1.25,
      'xpReward': 120,
    },
    // Sessões
    {
      'type': ChallengeType.sessoes,
      'title': '📊 Frequência Máxima',
      'description': 'Complete {target} sessões de treino',
      'baseTarget': 3,
      'levelMultiplier': 1.1,
      'xpReward': 60,
    },
    {
      'type': ChallengeType.sessoes,
      'title': '💪 Treino Constante',
      'description': 'Realize {target} treinos nesta semana',
      'baseTarget': 5,
      'levelMultiplier': 1.15,
      'xpReward': 100,
    },
    // Streak
    {
      'type': ChallengeType.streak,
      'title': '📅 Sequência Perfeita',
      'description': 'Mantenha {target} dias consecutivos',
      'baseTarget': 3,
      'levelMultiplier': 1.0,
      'xpReward': 80,
    },
    {
      'type': ChallengeType.streak,
      'title': '🔥 Fogo Contínuo',
      'description': 'Alcance {target} dias de streak',
      'baseTarget': 5,
      'levelMultiplier': 1.0,
      'xpReward': 150,
    },
  ];

  // ============================================================================
  // CONQUISTAS
  // ============================================================================

  /// Lista completa de conquistas disponíveis
  static const List<AchievementDefinition> achievements = [
    // Consistência (Streak)
    AchievementDefinition(
      id: 'streak_3',
      title: '🔥 Esquentando',
      description: '3 dias consecutivos',
      type: AchievementType.streak,
      target: 3,
      xpReward: 30,
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: 'streak_7',
      title: '🔥 Semana de Fogo',
      description: '7 dias consecutivos',
      type: AchievementType.streak,
      target: 7,
      xpReward: 100,
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: 'streak_14',
      title: '⭐ Duas Semanas',
      description: '14 dias consecutivos',
      type: AchievementType.streak,
      target: 14,
      xpReward: 250,
      emoji: '⭐',
    ),
    AchievementDefinition(
      id: 'streak_30',
      title: '🌟 Mês Dedicado',
      description: '30 dias consecutivos',
      type: AchievementType.streak,
      target: 30,
      xpReward: 500,
      emoji: '🌟',
    ),
    AchievementDefinition(
      id: 'streak_60',
      title: '💎 Dois Meses',
      description: '60 dias consecutivos',
      type: AchievementType.streak,
      target: 60,
      xpReward: 1000,
      emoji: '💎',
    ),
    AchievementDefinition(
      id: 'streak_100',
      title: '👑 Centenário',
      description: '100 dias consecutivos',
      type: AchievementType.streak,
      target: 100,
      xpReward: 2000,
      emoji: '👑',
    ),

    // Volume (Contagem de treinos)
    AchievementDefinition(
      id: 'workouts_1',
      title: '🎯 Primeiro Passo',
      description: 'Complete seu primeiro treino',
      type: AchievementType.count,
      target: 1,
      xpReward: 10,
      emoji: '🎯',
    ),
    AchievementDefinition(
      id: 'workouts_10',
      title: '🎯 Primeiros Passos',
      description: '10 treinos completados',
      type: AchievementType.count,
      target: 10,
      xpReward: 50,
      emoji: '🎯',
    ),
    AchievementDefinition(
      id: 'workouts_25',
      title: '💪 Comprometido',
      description: '25 treinos completados',
      type: AchievementType.count,
      target: 25,
      xpReward: 100,
      emoji: '💪',
    ),
    AchievementDefinition(
      id: 'workouts_50',
      title: '💪 Meio Centenário',
      description: '50 treinos completados',
      type: AchievementType.count,
      target: 50,
      xpReward: 200,
      emoji: '💪',
    ),
    AchievementDefinition(
      id: 'workouts_100',
      title: '🏆 Centurião',
      description: '100 treinos completados',
      type: AchievementType.count,
      target: 100,
      xpReward: 500,
      emoji: '🏆',
    ),
    AchievementDefinition(
      id: 'workouts_250',
      title: '🏅 Dedicação Extrema',
      description: '250 treinos completados',
      type: AchievementType.count,
      target: 250,
      xpReward: 1000,
      emoji: '🏅',
    ),
    AchievementDefinition(
      id: 'workouts_500',
      title: '🎖️ Lenda',
      description: '500 treinos completados',
      type: AchievementType.count,
      target: 500,
      xpReward: 2000,
      emoji: '🎖️',
    ),

    // Calorias
    AchievementDefinition(
      id: 'calories_500',
      title: '🔥 Aquecendo',
      description: 'Queime 500 calorias',
      type: AchievementType.calories,
      target: 500,
      xpReward: 25,
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: 'calories_1k',
      title: '🔥 Queimador',
      description: 'Queime 1.000 calorias',
      type: AchievementType.calories,
      target: 1000,
      xpReward: 75,
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: 'calories_5k',
      title: '🔥 Fornalha',
      description: 'Queime 5.000 calorias',
      type: AchievementType.calories,
      target: 5000,
      xpReward: 150,
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: 'calories_10k',
      title: '🌋 Vulcão',
      description: 'Queime 10.000 calorias',
      type: AchievementType.calories,
      target: 10000,
      xpReward: 300,
      emoji: '🌋',
    ),
    AchievementDefinition(
      id: 'calories_50k',
      title: '☀️ Sol Ardente',
      description: 'Queime 50.000 calorias',
      type: AchievementType.calories,
      target: 50000,
      xpReward: 1000,
      emoji: '☀️',
    ),

    // Tempo
    AchievementDefinition(
      id: 'minutes_60',
      title: '⏱️ Uma Hora',
      description: '60 minutos de exercício',
      type: AchievementType.minutes,
      target: 60,
      xpReward: 25,
      emoji: '⏱️',
    ),
    AchievementDefinition(
      id: 'minutes_300',
      title: '⏱️ Cinco Horas',
      description: '300 minutos de exercício',
      type: AchievementType.minutes,
      target: 300,
      xpReward: 75,
      emoji: '⏱️',
    ),
    AchievementDefinition(
      id: 'minutes_1000',
      title: '⌛ Maratonista',
      description: '1.000 minutos de exercício',
      type: AchievementType.minutes,
      target: 1000,
      xpReward: 400,
      emoji: '⌛',
    ),
    AchievementDefinition(
      id: 'minutes_3000',
      title: '🕐 Relógio Humano',
      description: '3.000 minutos de exercício',
      type: AchievementType.minutes,
      target: 3000,
      xpReward: 800,
      emoji: '🕐',
    ),
    AchievementDefinition(
      id: 'minutes_10000',
      title: '⏳ Incansável',
      description: '10.000 minutos de exercício',
      type: AchievementType.minutes,
      target: 10000,
      xpReward: 2000,
      emoji: '⏳',
    ),

    // Variedade
    AchievementDefinition(
      id: 'categories_3',
      title: '🎨 Explorador',
      description: 'Treine 3 categorias diferentes',
      type: AchievementType.variety,
      target: 3,
      xpReward: 50,
      emoji: '🎨',
    ),
    AchievementDefinition(
      id: 'categories_5',
      title: '🌈 Versátil',
      description: 'Treine 5 categorias diferentes',
      type: AchievementType.variety,
      target: 5,
      xpReward: 150,
      emoji: '🌈',
    ),
    AchievementDefinition(
      id: 'categories_all',
      title: '🌟 Mestre Completo',
      description: 'Treine todas as categorias',
      type: AchievementType.variety,
      target: 8,
      xpReward: 300,
      emoji: '🌟',
    ),

    // Especiais
    AchievementDefinition(
      id: 'early_bird',
      title: '🌅 Madrugador',
      description: '5 treinos antes das 7h',
      type: AchievementType.special,
      target: 5,
      xpReward: 100,
      emoji: '🌅',
    ),
    AchievementDefinition(
      id: 'night_owl',
      title: '🦉 Coruja',
      description: '5 treinos após 21h',
      type: AchievementType.special,
      target: 5,
      xpReward: 100,
      emoji: '🦉',
    ),
    AchievementDefinition(
      id: 'weekend_warrior',
      title: '🗓️ Guerreiro de Fim de Semana',
      description: '10 treinos no fim de semana',
      type: AchievementType.special,
      target: 10,
      xpReward: 150,
      emoji: '🗓️',
    ),
    AchievementDefinition(
      id: 'marathon_session',
      title: '🏃 Maratona',
      description: 'Uma sessão de 60+ minutos',
      type: AchievementType.special,
      target: 1,
      xpReward: 100,
      emoji: '🏃',
    ),
    AchievementDefinition(
      id: 'calorie_burner',
      title: '💥 Explosão',
      description: 'Queime 500+ calorias em uma sessão',
      type: AchievementType.special,
      target: 1,
      xpReward: 150,
      emoji: '💥',
    ),
  ];

  /// Mapa de conquistas por ID
  static Map<String, AchievementDefinition> get achievementsById {
    return {for (final a in achievements) a.id: a};
  }
}
