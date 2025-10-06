class UsageStats {
  final int totalTasks;
  final int totalSubtasks;
  final int totalTags;
  final int completedTasks;
  final int activeTasksThisWeek;
  final int completedSubtasks;

  const UsageStats({
    this.totalTasks = 0,
    this.totalSubtasks = 0,
    this.totalTags = 0,
    this.completedTasks = 0,
    this.activeTasksThisWeek = 0,
    this.completedSubtasks = 0,
  });
  int get totalCompletedSubtasks => completedSubtasks;

  UsageStats copyWith({
    int? totalTasks,
    int? totalSubtasks,
    int? totalTags,
    int? completedTasks,
    int? activeTasksThisWeek,
    int? completedSubtasks,
  }) {
    return UsageStats(
      totalTasks: totalTasks ?? this.totalTasks,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
      totalTags: totalTags ?? this.totalTags,
      completedTasks: completedTasks ?? this.completedTasks,
      activeTasksThisWeek: activeTasksThisWeek ?? this.activeTasksThisWeek,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
    );
  }
}
