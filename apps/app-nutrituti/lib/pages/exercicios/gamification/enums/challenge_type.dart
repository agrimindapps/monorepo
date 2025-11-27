/// Tipos de desafios semanais no sistema FitQuest
enum ChallengeType {
  minutos('Minutos', '⏱️', 'Acumule minutos de exercício'),
  calorias('Calorias', '🔥', 'Queime calorias'),
  sessoes('Sessões', '📊', 'Complete sessões de treino'),
  streak('Sequência', '📅', 'Mantenha dias consecutivos');

  const ChallengeType(this.label, this.emoji, this.description);

  final String label;
  final String emoji;
  final String description;
}

/// Tipos de conquistas no sistema FitQuest
enum AchievementType {
  streak('Consistência'),
  count('Volume'),
  calories('Calorias'),
  minutes('Tempo'),
  variety('Variedade'),
  special('Especial');

  const AchievementType(this.label);

  final String label;
}
