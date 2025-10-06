class UserLimits {
  final int maxTasks;
  final int maxSubtasks;
  final int maxTags;
  final int maxActiveTasksPerDay;
  final int maxActiveSubtasksPerDay;
  final bool isUserPremium;
  final int currentTasks;
  final int currentSubtasks;
  final int currentTags;

  const UserLimits({
    this.maxTasks = 25,
    this.maxSubtasks = 50,
    this.maxTags = 10,
    this.maxActiveTasksPerDay = 5,
    this.maxActiveSubtasksPerDay = 10,
    this.isUserPremium = false,
    this.currentTasks = 0,
    this.currentSubtasks = 0,
    this.currentTags = 0,
  });
  bool get isPremium => isUserPremium;
  
  int get remainingTasks => maxTasks - currentTasks;
  int get remainingSubtasks => maxSubtasks - currentSubtasks;
  int get remainingTags => maxTags - currentTags;
  bool get canCreateTask => remainingTasks > 0;
  bool get canCreateSubtask => remainingSubtasks > 0;
  bool get canCreateTag => remainingTags > 0;

  UserLimits copyWith({
    int? maxTasks,
    int? maxSubtasks,
    int? maxTags,
    int? maxActiveTasksPerDay,
    int? maxActiveSubtasksPerDay,
    bool? isUserPremium,
    int? currentTasks,
    int? currentSubtasks,
    int? currentTags,
  }) {
    return UserLimits(
      maxTasks: maxTasks ?? this.maxTasks,
      maxSubtasks: maxSubtasks ?? this.maxSubtasks,
      maxTags: maxTags ?? this.maxTags,
      maxActiveTasksPerDay: maxActiveTasksPerDay ?? this.maxActiveTasksPerDay,
      maxActiveSubtasksPerDay: maxActiveSubtasksPerDay ?? this.maxActiveSubtasksPerDay,
      isUserPremium: isUserPremium ?? this.isUserPremium,
      currentTasks: currentTasks ?? this.currentTasks,
      currentSubtasks: currentSubtasks ?? this.currentSubtasks,
      currentTags: currentTags ?? this.currentTags,
    );
  }
  factory UserLimits.premium({
    int currentTasks = 0,
    int currentSubtasks = 0,
    int currentTags = 0,
  }) {
    return UserLimits(
      maxTasks: 999999, // Ilimitado
      maxSubtasks: 999999, // Ilimitado
      maxTags: 999999, // Ilimitado
      maxActiveTasksPerDay: 999999, // Ilimitado
      maxActiveSubtasksPerDay: 999999, // Ilimitado
      isUserPremium: true,
      currentTasks: currentTasks,
      currentSubtasks: currentSubtasks,
      currentTags: currentTags,
    );
  }
  factory UserLimits.free({
    int currentTasks = 0,
    int currentSubtasks = 0,
    int currentTags = 0,
  }) {
    return UserLimits(
      maxTasks: 25,
      maxSubtasks: 50,
      maxTags: 10,
      maxActiveTasksPerDay: 5,
      maxActiveSubtasksPerDay: 10,
      isUserPremium: false,
      currentTasks: currentTasks,
      currentSubtasks: currentSubtasks,
      currentTags: currentTags,
    );
  }
}