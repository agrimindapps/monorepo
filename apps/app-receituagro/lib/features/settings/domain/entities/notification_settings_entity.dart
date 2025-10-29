/// Domain entity representing notification-related user settings.
/// Responsible for managing notification preferences, sounds, and promotional settings.
///
/// Business Rules:
/// - soundEnabled only applies if notificationsEnabled is true
/// - promotionalNotificationsEnabled can be disabled independently
/// - lastUpdated tracks when notification settings were last changed
class NotificationSettingsEntity {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool promotionalNotificationsEnabled;
  final DateTime lastUpdated;

  const NotificationSettingsEntity({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.promotionalNotificationsEnabled,
    required this.lastUpdated,
  });

  /// Creates a copy of this entity with the given fields replaced.
  /// If a field is not provided, the current value is retained.
  NotificationSettingsEntity copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? promotionalNotificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return NotificationSettingsEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      promotionalNotificationsEnabled:
          promotionalNotificationsEnabled ??
          this.promotionalNotificationsEnabled,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Creates default notification settings for new users.
  /// Defaults: Notifications enabled, sound enabled, promotional enabled
  static NotificationSettingsEntity defaults() {
    return NotificationSettingsEntity(
      notificationsEnabled: true,
      soundEnabled: true,
      promotionalNotificationsEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Check if notification settings are valid
  /// Valid when: if notifications are disabled, sound state doesn't matter
  bool get isValid {
    // If notifications are disabled, sound state is irrelevant
    if (!notificationsEnabled) return true;

    // If notifications are enabled, we just need soundEnabled to be set
    return true;
  }

  /// Business rule: Check if sound will actually play
  /// Sound only plays if BOTH notifications and sound are enabled
  bool get willPlaySound {
    return notificationsEnabled && soundEnabled;
  }

  /// Business rule: Check if promotional notifications will be sent
  /// Promotional notifications require notifications to be enabled
  bool get willReceivePromotional {
    return notificationsEnabled && promotionalNotificationsEnabled;
  }

  /// Business rule: Get notification level (for analytics/logging)
  NotificationLevel get notificationLevel {
    if (!notificationsEnabled) return NotificationLevel.disabled;
    if (!soundEnabled && !promotionalNotificationsEnabled) {
      return NotificationLevel.silent;
    }
    if (promotionalNotificationsEnabled) {
      return NotificationLevel.full;
    }
    return NotificationLevel.essential;
  }

  /// Business rule: Check if notifications changed
  bool hasNotificationsChanged(NotificationSettingsEntity other) {
    return notificationsEnabled != other.notificationsEnabled;
  }

  /// Business rule: Check if sound preference changed
  bool hasSoundChanged(NotificationSettingsEntity other) {
    return soundEnabled != other.soundEnabled;
  }

  /// Business rule: Check if promotional preference changed
  bool hasPromotionalChanged(NotificationSettingsEntity other) {
    return promotionalNotificationsEnabled !=
        other.promotionalNotificationsEnabled;
  }

  /// Business rule: Get user preference summary
  /// Useful for UI display and user consent tracking
  String get preferenceSummary {
    if (!notificationsEnabled) {
      return 'Todas as notificações desativadas';
    }

    final parts = <String>[];
    if (soundEnabled) parts.add('Som ativado');
    if (promotionalNotificationsEnabled) parts.add('Promoções ativadas');

    if (parts.isEmpty) {
      return 'Apenas notificações essenciais';
    }

    return parts.join(', ');
  }

  @override
  String toString() {
    return 'NotificationSettingsEntity('
        'notificationsEnabled: $notificationsEnabled, '
        'soundEnabled: $soundEnabled, '
        'promotionalNotificationsEnabled: $promotionalNotificationsEnabled, '
        'lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettingsEntity &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.promotionalNotificationsEnabled ==
            promotionalNotificationsEnabled &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return notificationsEnabled.hashCode ^
        soundEnabled.hashCode ^
        promotionalNotificationsEnabled.hashCode ^
        lastUpdated.hashCode;
  }
}

/// Enum representing the level of notifications a user receives
enum NotificationLevel { disabled, silent, essential, full }
