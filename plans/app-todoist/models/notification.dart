// models/notification.dart
enum NotificationType {
  reminder,
  assignment,
  comment,
  listShared,
  taskCompleted
}

class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedEntityId; // Task ID, List ID, etc.
  final DateTime createdAt;
  final bool isRead;
  final bool isDelivered;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedEntityId,
    required this.createdAt,
    this.isRead = false,
    this.isDelivered = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['userId'],
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.reminder,
      ),
      title: json['title'],
      message: json['message'],
      relatedEntityId: json['relatedEntityId'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'relatedEntityId': relatedEntityId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
    };
  }
}
