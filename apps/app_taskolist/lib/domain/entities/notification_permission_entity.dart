class NotificationPermissionEntity {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final bool canScheduleExactAlarms;

  const NotificationPermissionEntity({
    required this.isGranted,
    this.isPermanentlyDenied = false,
    this.canScheduleExactAlarms = false,
  });

  factory NotificationPermissionEntity.initial() => const NotificationPermissionEntity(
    isGranted: false,
    isPermanentlyDenied: false,
    canScheduleExactAlarms: false,
  );
}