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

  /// Convert from PlantaModel to Plant entity (migration compatibility)
  /// Includes robust validation to handle corrupted or null data
  factory Plant.fromPlantaModel(dynamic plantaModel) {
    try {
      // Validate essential fields
      if (plantaModel == null) {
        throw ArgumentError('PlantaModel cannot be null');
      }

      final id = plantaModel.id;
      if (id == null || id.toString().trim().isEmpty) {
        throw ArgumentError('PlantaModel must have a valid ID');
      }

      // Safe conversion with null checks and validation
      String safeName = '';
      try {
        final nome = plantaModel.nome;
        safeName = (nome is String && nome.trim().isNotEmpty) ? nome : '';
      } catch (e) {
        // Keep default empty name if conversion fails
      }

      String? safeSpecies;
      try {
        final especie = plantaModel.especie;
        safeSpecies = (especie is String && especie.trim().isNotEmpty) ? especie : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      String? safeSpaceId;
      try {
        final espacoId = plantaModel.espacoId;
        safeSpaceId = (espacoId is String && espacoId.trim().isNotEmpty) ? espacoId : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      String? safeImageBase64;
      try {
        final fotoBase64 = plantaModel.fotoBase64;
        safeImageBase64 = (fotoBase64 is String && fotoBase64.trim().isNotEmpty) ? fotoBase64 : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      List<String> safeImageUrls = [];
      try {
        final imagePaths = plantaModel.imagePaths;
        if (imagePaths is List) {
          safeImageUrls = imagePaths
              .where((path) => path != null && path.toString().trim().isNotEmpty)
              .map((path) => path.toString())
              .toList();
        }
      } catch (e) {
        // Keep empty list if conversion fails
      }

      DateTime? safePlantingDate;
      try {
        final dataCadastro = plantaModel.dataCadastro;
        safePlantingDate = (dataCadastro is DateTime) ? dataCadastro : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      String? safeNotes;
      try {
        final observacoes = plantaModel.observacoes;
        safeNotes = (observacoes is String && observacoes.trim().isNotEmpty) ? observacoes : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      bool safeIsFavorited = false;
      try {
        final isFavorited = plantaModel.isFavorited;
        safeIsFavorited = (isFavorited is bool) ? isFavorited : false;
      } catch (e) {
        // Keep default false if conversion fails
      }

      DateTime? safeCreatedAt;
      try {
        final createdAt = plantaModel.createdAt;
        safeCreatedAt = (createdAt is DateTime) ? createdAt : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      DateTime? safeUpdatedAt;
      try {
        final updatedAt = plantaModel.updatedAt;
        safeUpdatedAt = (updatedAt is DateTime) ? updatedAt : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      DateTime? safeLastSyncAt;
      try {
        final lastSyncAt = plantaModel.lastSyncAt;
        safeLastSyncAt = (lastSyncAt is DateTime) ? lastSyncAt : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      bool safeIsDirty = false;
      try {
        final isDirty = plantaModel.isDirty;
        safeIsDirty = (isDirty is bool) ? isDirty : false;
      } catch (e) {
        // Keep default false if conversion fails
      }

      bool safeIsDeleted = false;
      try {
        final isDeleted = plantaModel.isDeleted;
        safeIsDeleted = (isDeleted is bool) ? isDeleted : false;
      } catch (e) {
        // Keep default false if conversion fails
      }

      int safeVersion = 1;
      try {
        final version = plantaModel.version;
        safeVersion = (version is int && version > 0) ? version : 1;
      } catch (e) {
        // Keep default 1 if conversion fails
      }

      String? safeUserId;
      try {
        final userId = plantaModel.userId;
        safeUserId = (userId is String && userId.trim().isNotEmpty) ? userId : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      String? safeModuleName;
      try {
        final moduleName = plantaModel.moduleName;
        safeModuleName = (moduleName is String && moduleName.trim().isNotEmpty) ? moduleName : null;
      } catch (e) {
        // Keep null if conversion fails
      }

      return Plant(
        id: id.toString(),
        name: safeName,
        species: safeSpecies,
        spaceId: safeSpaceId,
        imageBase64: safeImageBase64,
        imageUrls: safeImageUrls,
        plantingDate: safePlantingDate,
        notes: safeNotes,
        isFavorited: safeIsFavorited,
        createdAt: safeCreatedAt,
        updatedAt: safeUpdatedAt,
        lastSyncAt: safeLastSyncAt,
        isDirty: safeIsDirty,
        isDeleted: safeIsDeleted,
        version: safeVersion,
        userId: safeUserId,
        moduleName: safeModuleName,
      );
    } catch (e) {
      // If conversion completely fails, log error and return a basic plant with minimal data
      print('Error converting PlantaModel to Plant: $e');
      
      // Try to extract at least the ID for basic functionality
      String fallbackId;
      try {
        fallbackId = plantaModel?.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      } catch (_) {
        fallbackId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      return Plant(
        id: fallbackId,
        name: 'Planta com dados corrompidos',
        species: null,
        spaceId: null,
        imageBase64: null,
        imageUrls: const [],
        plantingDate: null,
        notes: 'Dados originais corrompidos - convertido com valores padrão',
        isFavorited: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastSyncAt: null,
        isDirty: true,
        isDeleted: false,
        version: 1,
        userId: null,
        moduleName: 'plantis',
      );
    }
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

  /// Convert Plant entity to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'spaceId': spaceId,
      'imageBase64': imageBase64,
      'imageUrls': imageUrls,
      'notes': notes,
      'plantingDate': plantingDate?.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
      'isFavorited': isFavorited,
      'config': config?.toJson(),
    };
  }

  /// Create Plant entity from JSON
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String?,
      spaceId: json['spaceId'] as String?,
      imageBase64: json['imageBase64'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      plantingDate: json['plantingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['plantingDate'] as int)
          : null,
      isFavorited: json['isFavorited'] as bool? ?? false,
      config: json['config'] != null
          ? PlantConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSyncAt'] as int)
          : null,
      isDirty: json['isDirty'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['userId'] as String?,
      moduleName: json['moduleName'] as String?,
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

  /// Convert PlantConfig to JSON
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
      'enableWateringCare': enableWateringCare,
      'lastWateringDate': lastWateringDate?.millisecondsSinceEpoch,
      'enableFertilizerCare': enableFertilizerCare,
      'lastFertilizerDate': lastFertilizerDate?.millisecondsSinceEpoch,
    };
  }

  /// Create PlantConfig from JSON
  factory PlantConfig.fromJson(Map<String, dynamic> json) {
    return PlantConfig(
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
      enableWateringCare: json['enableWateringCare'] as bool?,
      lastWateringDate: json['lastWateringDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastWateringDate'] as int)
          : null,
      enableFertilizerCare: json['enableFertilizerCare'] as bool?,
      lastFertilizerDate: json['lastFertilizerDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastFertilizerDate'] as int)
          : null,
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

  /// Create Plant entity from Firebase map
  static Plant fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return Plant(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      name: map['name'] as String,
      species: map['species'] as String?,
      spaceId: map['space_id'] as String?,
      imageBase64: map['image_base64'] as String?,
      imageUrls: map['image_urls'] != null
          ? List<String>.from(map['image_urls'] as List)
          : const [],
      plantingDate: map['planting_date'] != null
          ? DateTime.parse(map['planting_date'] as String)
          : null,
      notes: map['notes'] as String?,
      isFavorited: map['is_favorited'] as bool? ?? false,
      config: map['config'] != null
          ? PlantConfig(
              wateringIntervalDays: map['config']['watering_interval_days'] as int?,
              fertilizingIntervalDays: map['config']['fertilizing_interval_days'] as int?,
              pruningIntervalDays: map['config']['pruning_interval_days'] as int?,
              sunlightCheckIntervalDays: map['config']['sunlight_check_interval_days'] as int?,
              pestInspectionIntervalDays: map['config']['pest_inspection_interval_days'] as int?,
              replantingIntervalDays: map['config']['replanting_interval_days'] as int?,
              lightRequirement: map['config']['light_requirement'] as String?,
              waterAmount: map['config']['water_amount'] as String?,
              soilType: map['config']['soil_type'] as String?,
              idealTemperature: (map['config']['ideal_temperature'] as num?)?.toDouble(),
              idealHumidity: (map['config']['ideal_humidity'] as num?)?.toDouble(),
              enableWateringCare: map['config']['enable_watering_care'] as bool?,
              lastWateringDate: map['config']['last_watering_date'] != null
                  ? DateTime.parse(map['config']['last_watering_date'] as String)
                  : null,
              enableFertilizerCare: map['config']['enable_fertilizer_care'] as bool?,
              lastFertilizerDate: map['config']['last_fertilizer_date'] != null
                  ? DateTime.parse(map['config']['last_fertilizer_date'] as String)
                  : null,
            )
          : null,
    );
  }
}
