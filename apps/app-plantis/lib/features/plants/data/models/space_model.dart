import '../../domain/entities/space.dart';

class SpaceModel extends Space {
  const SpaceModel({
    required super.id,
    required super.name,
    super.description,
    super.lightCondition,
    super.humidity,
    super.averageTemperature,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
  });

  factory SpaceModel.fromEntity(Space space) {
    return SpaceModel(
      id: space.id,
      name: space.name,
      description: space.description,
      lightCondition: space.lightCondition,
      humidity: space.humidity,
      averageTemperature: space.averageTemperature,
      createdAt: space.createdAt,
      updatedAt: space.updatedAt,
      isDeleted: space.isDeleted,
      isDirty: space.isDirty,
    );
  }

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      lightCondition: json['lightCondition'] as String?,
      humidity: (json['humidity'] as num?)?.toDouble(),
      averageTemperature: (json['averageTemperature'] as num?)?.toDouble(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isDirty: json['isDirty'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lightCondition': lightCondition,
      'humidity': humidity,
      'averageTemperature': averageTemperature,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isDirty': isDirty,
    };
  }

  @override
  SpaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? lightCondition,
    double? humidity,
    double? averageTemperature,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      lightCondition: lightCondition ?? this.lightCondition,
      humidity: humidity ?? this.humidity,
      averageTemperature: averageTemperature ?? this.averageTemperature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }
}
