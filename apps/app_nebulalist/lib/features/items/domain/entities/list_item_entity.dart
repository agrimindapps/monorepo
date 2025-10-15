import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_item_entity.freezed.dart';

/// Priority levels for list items
enum Priority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Baixa';
      case Priority.normal:
        return 'Normal';
      case Priority.high:
        return 'Alta';
      case Priority.urgent:
        return 'Urgente';
    }
  }

  int get value {
    switch (this) {
      case Priority.low:
        return 0;
      case Priority.normal:
        return 1;
      case Priority.high:
        return 2;
      case Priority.urgent:
        return 3;
    }
  }
}

/// Entity representing a ListItem (instance of an ItemMaster in a specific list)
/// Links an ItemMaster to a List with quantity, priority, and completion status
@freezed
class ListItemEntity with _$ListItemEntity {
  const factory ListItemEntity({
    required String id,
    required String listId,
    required String itemMasterId,
    @Default('1') String quantity,
    @Default(Priority.normal) Priority priority,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    String? notes,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? addedBy,
  }) = _ListItemEntity;

  const ListItemEntity._();

  /// Check if item is overdue (if needed for future features)
  bool get isOverdue => false; // Placeholder for future reminder logic

  /// Check if item has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Get priority color for UI
  String get priorityColor {
    switch (priority) {
      case Priority.low:
        return '#4CAF50'; // Green
      case Priority.normal:
        return '#9E9E9E'; // Grey
      case Priority.high:
        return '#FF9800'; // Orange
      case Priority.urgent:
        return '#F44336'; // Red
    }
  }
}
