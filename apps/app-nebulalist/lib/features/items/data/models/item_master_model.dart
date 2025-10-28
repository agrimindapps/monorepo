import 'package:core/core.dart';
import '../../domain/entities/item_master_entity.dart';

part 'item_master_model.g.dart';

/// Data model for ItemMaster
/// Provides serialization for Hive and Firestore
@HiveType(typeId: 1)
class ItemMasterModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ownerId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String? photoUrl;

  @HiveField(7)
  final double? estimatedPrice;

  @HiveField(8)
  final String? preferredBrand;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final int usageCount;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  const ItemMasterModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description = '',
    this.tags = const [],
    this.category = 'outros',
    this.photoUrl,
    this.estimatedPrice,
    this.preferredBrand,
    this.notes,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory ItemMasterModel.fromJson(Map<String, dynamic> json) {
    return ItemMasterModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String? ?? 'outros',
      photoUrl: json['photoUrl'] as String?,
      estimatedPrice: json['estimatedPrice'] as double?,
      preferredBrand: json['preferredBrand'] as String?,
      notes: json['notes'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'tags': tags,
      'category': category,
      'photoUrl': photoUrl,
      'estimatedPrice': estimatedPrice,
      'preferredBrand': preferredBrand,
      'notes': notes,
      'usageCount': usageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
  factory ItemMasterModel.fromEntity(ItemMasterEntity entity) {
    return ItemMasterModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      description: entity.description,
      tags: entity.tags,
      category: entity.category,
      photoUrl: entity.photoUrl,
      estimatedPrice: entity.estimatedPrice,
      preferredBrand: entity.preferredBrand,
      notes: entity.notes,
      usageCount: entity.usageCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  ItemMasterEntity toEntity() => ItemMasterEntity(
        id: id,
        ownerId: ownerId,
        name: name,
        description: description,
        tags: tags,
        category: category,
        photoUrl: photoUrl,
        estimatedPrice: estimatedPrice,
        preferredBrand: preferredBrand,
        notes: notes,
        usageCount: usageCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemMasterModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => id.hashCode ^ updatedAt.hashCode;
}
