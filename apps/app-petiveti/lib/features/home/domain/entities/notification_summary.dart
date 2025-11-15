/// Entity representing a notification summary
class NotificationSummary {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isUrgent;
  final String? relatedEntityId;
  final String? relatedEntityType; // 'animal', 'appointment', 'medication', etc.

  const NotificationSummary({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUrgent = false,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  /// Copy with pattern
  NotificationSummary copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isUrgent,
    String? relatedEntityId,
    String? relatedEntityType,
  }) {
    return NotificationSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isUrgent: isUrgent ?? this.isUrgent,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
    );
  }
}
