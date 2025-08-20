class ExercicioAchievement {
  final String title;
  final String description;
  final bool isUnlocked;

  ExercicioAchievement({
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });
}
