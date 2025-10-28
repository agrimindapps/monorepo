import 'package:core/core.dart';
import '../../domain/entities/list_item_entity.dart' as entities;

part 'list_item_model.g.dart';

/// Data model for ListItem
/// Provides serialization for Hive and Firestore
@HiveType(typeId: 2)
class ListItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String listId;

  @HiveField(2)
  final String itemMasterId;

  @HiveField(3)
  final String quantity;

  @HiveField(4)
  final int priorityIndex;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final int order;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? addedBy;

  const ListItemModel({
    required this.id,
    required this.listId,
    required this.itemMasterId,
    this.quantity = '1',
    this.priorityIndex = 1,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
    this.addedBy,
  });

  /// Create from Firestore document
  factory ListItemModel.fromJson(Map<String, dynamic> json) {
    return ListItemModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      itemMasterId: json['itemMasterId'] as String,
      quantity: json['quantity'] as String? ?? '1',
      priorityIndex: json['priority'] as int? ?? 1,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? _parseTimestamp(json['completedAt'])
          : null,
      notes: json['notes'] as String?,
      order: json['order'] as int? ?? 0,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      addedBy: json['addedBy'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'itemMasterId': itemMasterId,
      'quantity': quantity,
      'priority': priorityIndex,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'addedBy': addedBy,
    };
  }

  /// Helper to parse Firestore Timestamp or DateTime string
  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  /// Create from entity
  factory ListItemModel.fromEntity(entities.ListItemEntity entity) {
    return ListItemModel(
      id: entity.id,
      listId: entity.listId,
      itemMasterId: entity.itemMasterId,
      quantity: entity.quantity,
      priorityIndex: entity.priority.value,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      notes: entity.notes,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      addedBy: entity.addedBy,
    );
  }

  /// Convert to entity
  entities.ListItemEntity toEntity() => entities.ListItemEntity(
        id: id,
        listId: listId,
        itemMasterId: itemMasterId,
        quantity: quantity,
        priority: _priorityFromIndex(priorityIndex),
        isCompleted: isCompleted,
        completedAt: completedAt,
        notes: notes,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
        addedBy: addedBy,
      );

  /// Convert priority index to enum
  entities.Priority _priorityFromIndex(int index) {
    switch (index) {
      case 0:
        return entities.Priority.low;
      case 1:
        return entities.Priority.normal;
      case 2:
        return entities.Priority.high;
      case 3:
        return entities.Priority.urgent;
      default:
        return entities.Priority.normal;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => id.hashCode ^ updatedAt.hashCode;
}
