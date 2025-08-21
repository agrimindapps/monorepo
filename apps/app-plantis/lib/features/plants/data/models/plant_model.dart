import '../../domain/entities/plant.dart';

class PlantModel extends Plant {
  const PlantModel({
    required super.id,
    required super.name,
    super.species,
    super.spaceId,
    super.imageBase64,
    super.imageUrls = const [],
    super.plantingDate,
    super.notes,
    super.config,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
  });

  factory PlantModel.fromEntity(Plant plant) {
    return PlantModel(
      id: plant.id,
      name: plant.name,
      species: plant.species,
      spaceId: plant.spaceId,
      imageBase64: plant.imageBase64,
      imageUrls: plant.imageUrls,
      plantingDate: plant.plantingDate,
      notes: plant.notes,
      config: plant.config,
      createdAt: plant.createdAt,
      updatedAt: plant.updatedAt,
      isDeleted: plant.isDeleted,
      isDirty: plant.isDirty,
    );
  }

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String?,
      spaceId: json['spaceId'] as String?,
      imageBase64: json['imageBase64'] as String?,
      imageUrls:
          json['imageUrls'] != null
              ? List<String>.from(json['imageUrls'] as List)
              : const [],
      plantingDate:
          json['plantingDate'] != null
              ? DateTime.parse(json['plantingDate'] as String)
              : null,
      notes: json['notes'] as String?,
      config:
          json['config'] != null
              ? PlantConfigModel.fromJson(
                json['config'] as Map<String, dynamic>,
              )
              : null,
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
      'species': species,
      'spaceId': spaceId,
      'imageBase64': imageBase64,
      'imageUrls': imageUrls,
      'plantingDate': plantingDate?.toIso8601String(),
      'notes': notes,
      'config':
          config != null ? PlantConfigModel.fromEntity(config!).toJson() : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isDirty': isDirty,
    };
  }

  @override
  PlantModel copyWith({
    String? id,
    String? name,
    String? species,
    String? spaceId,
    String? imageBase64,
    List<String>? imageUrls,
    DateTime? plantingDate,
    String? notes,
    PlantConfig? config,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      spaceId: spaceId ?? this.spaceId,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrls: imageUrls ?? this.imageUrls,
      plantingDate: plantingDate ?? this.plantingDate,
      notes: notes ?? this.notes,
      config: config ?? this.config,
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

class PlantConfigModel extends PlantConfig {
  const PlantConfigModel({
    super.wateringIntervalDays,
    super.fertilizingIntervalDays,
    super.pruningIntervalDays,
    super.sunlightCheckIntervalDays,
    super.pestInspectionIntervalDays,
    super.replantingIntervalDays,
    super.lightRequirement,
    super.waterAmount,
    super.soilType,
    super.idealTemperature,
    super.idealHumidity,
  });

  factory PlantConfigModel.fromEntity(PlantConfig config) {
    return PlantConfigModel(
      wateringIntervalDays: config.wateringIntervalDays,
      fertilizingIntervalDays: config.fertilizingIntervalDays,
      pruningIntervalDays: config.pruningIntervalDays,
      sunlightCheckIntervalDays: config.sunlightCheckIntervalDays,
      pestInspectionIntervalDays: config.pestInspectionIntervalDays,
      replantingIntervalDays: config.replantingIntervalDays,
      lightRequirement: config.lightRequirement,
      waterAmount: config.waterAmount,
      soilType: config.soilType,
      idealTemperature: config.idealTemperature,
      idealHumidity: config.idealHumidity,
    );
  }

  factory PlantConfigModel.fromJson(Map<String, dynamic> json) {
    return PlantConfigModel(
      wateringIntervalDays: json['wateringIntervalDays'] as int?,
      fertilizingIntervalDays: json['fertilizingIntervalDays'] as int?,
      pruningIntervalDays: json['pruningIntervalDays'] as int?,
      sunlightCheckIntervalDays: json['sunlightCheckIntervalDays'] as int?,
      pestInspectionIntervalDays: json['pestInspectionIntervalDays'] as int?,
      replantingIntervalDays: json['replantingIntervalDays'] as int?,
      lightRequirement: json['lightRequirement'] as String?,
      waterAmount: json['waterAmount'] as String?,
      soilType: json['soilType'] as String?,
      idealTemperature: (json['idealTemperature'] as num?)?.toDouble(),
      idealHumidity: (json['idealHumidity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wateringIntervalDays': wateringIntervalDays,
      'fertilizingIntervalDays': fertilizingIntervalDays,
      'pruningIntervalDays': pruningIntervalDays,
      'sunlightCheckIntervalDays': sunlightCheckIntervalDays,
      'pestInspectionIntervalDays': pestInspectionIntervalDays,
      'replantingIntervalDays': replantingIntervalDays,
      'lightRequirement': lightRequirement,
      'waterAmount': waterAmount,
      'soilType': soilType,
      'idealTemperature': idealTemperature,
      'idealHumidity': idealHumidity,
    };
  }

  @override
  PlantConfigModel copyWith({
    int? wateringIntervalDays,
    int? fertilizingIntervalDays,
    int? pruningIntervalDays,
    int? sunlightCheckIntervalDays,
    int? pestInspectionIntervalDays,
    int? replantingIntervalDays,
    String? lightRequirement,
    String? waterAmount,
    String? soilType,
    double? idealTemperature,
    double? idealHumidity,
  }) {
    return PlantConfigModel(
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      fertilizingIntervalDays:
          fertilizingIntervalDays ?? this.fertilizingIntervalDays,
      pruningIntervalDays: pruningIntervalDays ?? this.pruningIntervalDays,
      sunlightCheckIntervalDays:
          sunlightCheckIntervalDays ?? this.sunlightCheckIntervalDays,
      pestInspectionIntervalDays:
          pestInspectionIntervalDays ?? this.pestInspectionIntervalDays,
      replantingIntervalDays:
          replantingIntervalDays ?? this.replantingIntervalDays,
      lightRequirement: lightRequirement ?? this.lightRequirement,
      waterAmount: waterAmount ?? this.waterAmount,
      soilType: soilType ?? this.soilType,
      idealTemperature: idealTemperature ?? this.idealTemperature,
      idealHumidity: idealHumidity ?? this.idealHumidity,
    );
  }
}
