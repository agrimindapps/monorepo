class WeightAchievement {
  final String title;
  final String description;
  bool isUnlocked;

  WeightAchievement({
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });

  void unlock() {
    isUnlocked = true;
  }
}
