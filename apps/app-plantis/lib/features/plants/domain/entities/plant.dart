import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

class Plant extends BaseSyncEntity {
  final String name;
  final String? species;
  final String? spaceId;
  final String? imageBase64; // Manter para compatibilidade
  final List<String> imageUrls; // Nova lista de URLs de imagens
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfig? config;
  final bool isFavorited;

  const Plant({
    required super.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageBase64,
    this.imageUrls = const [],
    this.plantingDate,
    this.notes,
    this.config,
    this.isFavorited = false,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
  });

  bool get hasImage =>
      imageUrls.isNotEmpty || (imageBase64 != null && imageBase64!.isNotEmpty);

  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  int get imagesCount => imageUrls.length;

  String get displayName => name.trim().isEmpty ? 'Planta sem nome' : name;

  String get displaySpecies =>
      species?.trim().isEmpty ?? true ? 'Espécie não informada' : species!;

  int get ageInDays {
    if (plantingDate == null) return 0;
    return DateTime.now().difference(plantingDate!).inDays;
  }

  /// Convert from legacy PlantaModel to modern Plant entity
  factory Plant.fromPlantaModel(dynamic plantaModel) {
    return Plant(
      id: plantaModel.id as String,
      name: (plantaModel.nome as String?) ?? '',
      species: plantaModel.especie as String?,
      spaceId: plantaModel.espacoId as String?,
      imageBase64: plantaModel.fotoBase64 as String?,
      imageUrls: (plantaModel.imagePaths as List<dynamic>?)?.cast<String>() ?? [],
      plantingDate: plantaModel.dataCadastro as DateTime?,
      notes: plantaModel.observacoes as String?,
      isFavorited: (plantaModel.isFavorited as bool?) ?? false,
      createdAt: plantaModel.createdAt as DateTime?,
      updatedAt: plantaModel.updatedAt as DateTime?,
      lastSyncAt: plantaModel.lastSyncAt as DateTime?,
      isDirty: (plantaModel.isDirty as bool?) ?? false,
      isDeleted: (plantaModel.isDeleted as bool?) ?? false,
      version: (plantaModel.version as int?) ?? 1,
      userId: plantaModel.userId as String?,
      moduleName: plantaModel.moduleName as String?,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'name': name,
      'species': species,
      'space_id': spaceId,
      'image_base64': imageBase64,
      'image_urls': imageUrls,
      'planting_date': plantingDate?.toIso8601String(),
      'notes': notes,
      'is_favorited': isFavorited,
      'config':
          config != null
              ? {
                'watering_interval_days': config!.wateringIntervalDays,
                'fertilizing_interval_days': config!.fertilizingIntervalDays,
                'pruning_interval_days': config!.pruningIntervalDays,
                'sunlight_check_interval_days':
                    config!.sunlightCheckIntervalDays,
                'pest_inspection_interval_days':
                    config!.pestInspectionIntervalDays,
                'replanting_interval_days': config!.replantingIntervalDays,
                'light_requirement': config!.lightRequirement,
                'water_amount': config!.waterAmount,
                'soil_type': config!.soilType,
                'ideal_temperature': config!.idealTemperature,
                'ideal_humidity': config!.idealHumidity,
                'enable_watering_care': config!.enableWateringCare,
                'last_watering_date': config!.lastWateringDate?.toIso8601String(),
                'enable_fertilizer_care': config!.enableFertilizerCare,
                'last_fertilizer_date': config!.lastFertilizerDate?.toIso8601String(),
              }
              : null,
    };
  }

  @override
  Plant markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  Plant markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  Plant markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
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
    List<String>? imageUrls,
    DateTime? plantingDate,
    String? notes,
    PlantConfig? config,
    bool? isFavorited,
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
      imageUrls: imageUrls ?? this.imageUrls,
      plantingDate: plantingDate ?? this.plantingDate,
      notes: notes ?? this.notes,
      config: config ?? this.config,
      isFavorited: isFavorited ?? this.isFavorited,
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
    imageUrls,
    plantingDate,
    notes,
    config,
    isFavorited,
  ];
}

class PlantConfig extends Equatable {
  final int? wateringIntervalDays;
  final int? fertilizingIntervalDays;
  final int? pruningIntervalDays;
  final int? sunlightCheckIntervalDays;
  final int? pestInspectionIntervalDays;
  final int? replantingIntervalDays;
  final String? lightRequirement; // 'low', 'medium', 'high'
  final String? waterAmount; // 'little', 'moderate', 'plenty'
  final String? soilType;
  final double? idealTemperature;
  final double? idealHumidity;
  
  // New care fields for Water and Fertilizer
  final bool? enableWateringCare;
  final DateTime? lastWateringDate;
  
  final bool? enableFertilizerCare;
  final DateTime? lastFertilizerDate;

  const PlantConfig({
    this.wateringIntervalDays,
    this.fertilizingIntervalDays,
    this.pruningIntervalDays,
    this.sunlightCheckIntervalDays,
    this.pestInspectionIntervalDays,
    this.replantingIntervalDays,
    this.lightRequirement,
    this.waterAmount,
    this.soilType,
    this.idealTemperature,
    this.idealHumidity,
    this.enableWateringCare,
    this.lastWateringDate,
    this.enableFertilizerCare,
    this.lastFertilizerDate,
  });

  bool get hasWateringSchedule =>
      wateringIntervalDays != null && wateringIntervalDays! > 0;
  bool get hasFertilizingSchedule =>
      fertilizingIntervalDays != null && fertilizingIntervalDays! > 0;
  bool get hasPruningSchedule =>
      pruningIntervalDays != null && pruningIntervalDays! > 0;
  bool get hasSunlightCheckSchedule =>
      sunlightCheckIntervalDays != null && sunlightCheckIntervalDays! > 0;
  bool get hasPestInspectionSchedule =>
      pestInspectionIntervalDays != null && pestInspectionIntervalDays! > 0;
  bool get hasReplantingSchedule =>
      replantingIntervalDays != null && replantingIntervalDays! > 0;

  // New care schedule getters
  bool get hasWateringCareEnabled => enableWateringCare == true;
  bool get hasFertilizerCareEnabled => enableFertilizerCare == true;

  PlantConfig copyWith({
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
    bool? enableWateringCare,
    DateTime? lastWateringDate,
    bool? enableFertilizerCare,
    DateTime? lastFertilizerDate,
  }) {
    return PlantConfig(
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
      enableWateringCare: enableWateringCare ?? this.enableWateringCare,
      lastWateringDate: lastWateringDate ?? this.lastWateringDate,
      enableFertilizerCare: enableFertilizerCare ?? this.enableFertilizerCare,
      lastFertilizerDate: lastFertilizerDate ?? this.lastFertilizerDate,
    );
  }

  @override
  List<Object?> get props => [
    wateringIntervalDays,
    fertilizingIntervalDays,
    pruningIntervalDays,
    sunlightCheckIntervalDays,
    pestInspectionIntervalDays,
    replantingIntervalDays,
    lightRequirement,
    waterAmount,
    soilType,
    idealTemperature,
    idealHumidity,
    enableWateringCare,
    lastWateringDate,
    enableFertilizerCare,
    lastFertilizerDate,
  ];
}
