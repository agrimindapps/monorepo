class NotificationStats {
  final int totalNotifications;
  final int unreadNotifications;
  final bool areNotificationsEnabled;
  final int totalPending;
  final int taskReminders;
  final int taskDeadlines;

  const NotificationStats({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.areNotificationsEnabled,
    this.totalPending = 0,
    this.taskReminders = 0,
    this.taskDeadlines = 0,
  });
}