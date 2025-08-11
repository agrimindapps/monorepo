import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class Plant extends BaseSyncEntity {
  final String name;
  final String? species;
  final String? spaceId;
  final String? imageBase64;
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfig? config;
  
  const Plant({
    required super.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageBase64,
    this.plantingDate,
    this.notes,
    this.config,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });
  
  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;
  
  String get displayName => name.trim().isEmpty ? 'Planta sem nome' : name;
  
  String get displaySpecies => species?.trim().isEmpty ?? true 
      ? 'Espécie não informada' 
      : species!;
  
  int get ageInDays {
    if (plantingDate == null) return 0;
    return DateTime.now().difference(plantingDate!).inDays;
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'name': name,
      'species': species,
      'space_id': spaceId,
      'image_base64': imageBase64,
      'planting_date': plantingDate?.toIso8601String(),
      'notes': notes,
      'config': config != null ? {
        'watering_interval_days': config!.wateringIntervalDays,
        'fertilizing_interval_days': config!.fertilizingIntervalDays,
        'pruning_interval_days': config!.pruningIntervalDays,
        'light_requirement': config!.lightRequirement,
        'water_amount': config!.waterAmount,
        'soil_type': config!.soilType,
        'ideal_temperature': config!.idealTemperature,
        'ideal_humidity': config!.idealHumidity,
      } : null,
    };
  }

  @override
  Plant markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Plant markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  Plant markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Plant incrementVersion() {
    return copyWith(version: version + 1);
  }

  @override
  Plant withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  Plant withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
  
  @override
  Plant copyWith({
    String? id,
    String? name,
    String? species,
    String? spaceId,
    String? imageBase64,
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
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      spaceId: spaceId ?? this.spaceId,
      imageBase64: imageBase64 ?? this.imageBase64,
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
  
  @override
  List<Object?> get props => [
    ...super.props,
    name,
    species,
    spaceId,
    imageBase64,
    plantingDate,
    notes,
    config,
  ];
}

class PlantConfig extends Equatable {
  final int? wateringIntervalDays;
  final int? fertilizingIntervalDays;
  final int? pruningIntervalDays;
  final String? lightRequirement; // 'low', 'medium', 'high'
  final String? waterAmount; // 'little', 'moderate', 'plenty'
  final String? soilType;
  final double? idealTemperature;
  final double? idealHumidity;
  
  const PlantConfig({
    this.wateringIntervalDays,
    this.fertilizingIntervalDays,
    this.pruningIntervalDays,
    this.lightRequirement,
    this.waterAmount,
    this.soilType,
    this.idealTemperature,
    this.idealHumidity,
  });
  
  bool get hasWateringSchedule => wateringIntervalDays != null && wateringIntervalDays! > 0;
  bool get hasFertilizingSchedule => fertilizingIntervalDays != null && fertilizingIntervalDays! > 0;
  bool get hasPruningSchedule => pruningIntervalDays != null && pruningIntervalDays! > 0;
  
  PlantConfig copyWith({
    int? wateringIntervalDays,
    int? fertilizingIntervalDays,
    int? pruningIntervalDays,
    String? lightRequirement,
    String? waterAmount,
    String? soilType,
    double? idealTemperature,
    double? idealHumidity,
  }) {
    return PlantConfig(
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      fertilizingIntervalDays: fertilizingIntervalDays ?? this.fertilizingIntervalDays,
      pruningIntervalDays: pruningIntervalDays ?? this.pruningIntervalDays,
      lightRequirement: lightRequirement ?? this.lightRequirement,
      waterAmount: waterAmount ?? this.waterAmount,
      soilType: soilType ?? this.soilType,
      idealTemperature: idealTemperature ?? this.idealTemperature,
      idealHumidity: idealHumidity ?? this.idealHumidity,
    );
  }
  
  @override
  List<Object?> get props => [
    wateringIntervalDays,
    fertilizingIntervalDays,
    pruningIntervalDays,
    lightRequirement,
    waterAmount,
    soilType,
    idealTemperature,
    idealHumidity,
  ];
}