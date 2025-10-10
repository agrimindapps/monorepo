import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Example entity
/// Represents an example item in the domain layer (pure business logic)
/// Extends BaseSyncEntity from core package for offline-first sync support
class ExampleEntity extends BaseSyncEntity with EquatableMixin {
  const ExampleEntity({
    required super.id,
    required this.name,
    this.description,
    super.createdAt,
    super.updatedAt,
    super.isDirty = false,
    super.userId,
    super.moduleName = 'example',
  });

  final String name;
  final String? description;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
        isDirty,
        userId,
        moduleName,
      ];

  /// Create a copy with modified fields
  ExampleEntity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    String? userId,
    String? moduleName,
  }) {
    return ExampleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  /// Convert to Firebase map for storage
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDirty': isDirty,
      'userId': userId,
      'moduleName': moduleName,
    };
  }

  /// Create entity from Firebase map
  factory ExampleEntity.fromFirebaseMap(Map<String, dynamic> map) {
    return ExampleEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      isDirty: map['isDirty'] as bool? ?? false,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String? ?? 'example',
    );
  }

  /// Create empty entity for testing
  factory ExampleEntity.empty() {
    return ExampleEntity(
      id: '',
      name: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
