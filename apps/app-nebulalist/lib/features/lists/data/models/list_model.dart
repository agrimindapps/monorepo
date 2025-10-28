import 'package:core/core.dart';
import '../../domain/entities/list_entity.dart';

part 'list_model.g.dart';

/// Data model for List
/// Provides serialization for Hive and Firestore
@HiveType(typeId: 0)
class ListModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String ownerId;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final bool isArchived;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final String? shareToken;

  @HiveField(11)
  final bool isShared;

  @HiveField(12)
  final DateTime? archivedAt;

  @HiveField(13)
  final int itemCount;

  @HiveField(14)
  final int completedCount;

  const ListModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.description = '',
    this.tags = const [],
    this.category = 'outros',
    this.isFavorite = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.shareToken,
    this.isShared = false,
    this.archivedAt,
    this.itemCount = 0,
    this.completedCount = 0,
  });

  /// Create from Firestore document
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String? ?? 'outros',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      shareToken: json['shareToken'] as String?,
      isShared: json['isShared'] as bool? ?? false,
      archivedAt: json['archivedAt'] != null
          ? _parseTimestamp(json['archivedAt'])
          : null,
      itemCount: json['itemCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'description': description,
      'tags': tags,
      'category': category,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'shareToken': shareToken,
      'isShared': isShared,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'itemCount': itemCount,
      'completedCount': completedCount,
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
  factory ListModel.fromEntity(ListEntity entity) {
    return ListModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      description: entity.description,
      tags: entity.tags,
      category: entity.category,
      isFavorite: entity.isFavorite,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      shareToken: entity.shareToken,
      isShared: entity.isShared,
      archivedAt: entity.archivedAt,
      itemCount: entity.itemCount,
      completedCount: entity.completedCount,
    );
  }

  /// Convert to entity
  ListEntity toEntity() => ListEntity(
        id: id,
        name: name,
        ownerId: ownerId,
        description: description,
        tags: tags,
        category: category,
        isFavorite: isFavorite,
        isArchived: isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt,
        shareToken: shareToken,
        isShared: isShared,
        archivedAt: archivedAt,
        itemCount: itemCount,
        completedCount: completedCount,
      );

  /// Computed getters (similar to ListEntity)
  double get completionPercentage {
    if (itemCount == 0) return 0.0;
    return (completedCount / itemCount * 100).clamp(0.0, 100.0);
  }

  bool get isEmpty => itemCount == 0;

  bool get isComplete => itemCount > 0 && itemCount == completedCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => id.hashCode ^ updatedAt.hashCode;
}
