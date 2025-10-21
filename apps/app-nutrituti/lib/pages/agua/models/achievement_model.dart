class WaterAchievement {
  final String title;
  final String description;
  final bool isUnlocked;

  WaterAchievement({
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });

  WaterAchievement copyWith({
    String? title,
    String? description,
    bool? isUnlocked,
  }) {
    return WaterAchievement(
      title: title ?? this.title,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  WaterAchievement unlock() {
    return copyWith(isUnlocked: true);
  }
}
