import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../plants/data/models/plant_model.dart';

/// Firebase mapper for Plant entities
/// Handles conversion between PlantModel and Firestore JSON format
///
/// Key responsibilities:
/// - Convert PlantModel to Firestore-compatible JSON (toJson)
/// - Convert Firestore JSON back to PlantModel (fromJson)
/// - Handle Timestamp conversions (DateTime ↔ Firestore Timestamp)
/// - Manage null safety for optional fields
/// - Include sync metadata (isDirty, version, firebaseId, lastSyncAt)
class PlantFirebaseMapper {
  /// Convert PlantModel to Firestore JSON
  ///
  /// Firestore field naming convention: snake_case
  /// Excludes local-only 'id' field (document ID is stored separately)
  /// Converts DateTime to Timestamp for Firestore compatibility
  static Map<String, dynamic> toJson(PlantModel plant) {
    return {
      // Plant-specific fields
      'name': plant.name,
      'species': plant.species,
      'space_id': plant.spaceId,
      'image_base64': plant.imageBase64,
      'image_urls': plant.imageUrls,
      'planting_date': plant.plantingDate != null
          ? Timestamp.fromDate(plant.plantingDate!.toUtc())
          : null,
      'notes': plant.notes,
      'is_favorited': plant.isFavorited,

      // PlantConfig nested object
      'config': plant.config != null
          ? {
              'watering_interval_days': plant.config!.wateringIntervalDays,
              'fertilizing_interval_days': plant.config!.fertilizingIntervalDays,
              'pruning_interval_days': plant.config!.pruningIntervalDays,
              'sunlight_check_interval_days': plant.config!.sunlightCheckIntervalDays,
              'pest_inspection_interval_days': plant.config!.pestInspectionIntervalDays,
              'replanting_interval_days': plant.config!.replantingIntervalDays,
              'light_requirement': plant.config!.lightRequirement,
              'water_amount': plant.config!.waterAmount,
              'soil_type': plant.config!.soilType,
              'ideal_temperature': plant.config!.idealTemperature,
              'ideal_humidity': plant.config!.idealHumidity,
              'enable_watering_care': plant.config!.enableWateringCare,
              'last_watering_date': plant.config!.lastWateringDate != null
                  ? Timestamp.fromDate(plant.config!.lastWateringDate!.toUtc())
                  : null,
              'enable_fertilizer_care': plant.config!.enableFertilizerCare,
              'last_fertilizer_date': plant.config!.lastFertilizerDate != null
                  ? Timestamp.fromDate(plant.config!.lastFertilizerDate!.toUtc())
                  : null,
            }
          : null,

      // BaseSyncEntity fields (from Plant extends BaseSyncEntity)
      'created_at': plant.createdAt != null
          ? Timestamp.fromDate(plant.createdAt!.toUtc())
          : Timestamp.now(),
      'updated_at': plant.updatedAt != null
          ? Timestamp.fromDate(plant.updatedAt!.toUtc())
          : Timestamp.now(),
      'last_sync_at': plant.lastSyncAt != null
          ? Timestamp.fromDate(plant.lastSyncAt!.toUtc())
          : null,
      'is_dirty': plant.isDirty,
      'is_deleted': plant.isDeleted,
      'version': plant.version,
      'user_id': plant.userId,
      'module_name': plant.moduleName ?? 'plantis',
    };
  }

  /// Convert Firestore JSON to PlantModel
  ///
  /// Parameters:
  /// - json: Firestore document data
  /// - documentId: Firestore document ID (becomes plant.id)
  ///
  /// Returns PlantModel with:
  /// - isDirty = false (remote data is authoritative)
  /// - All Timestamp fields converted to DateTime
  /// - Null safety for all optional fields
  static PlantModel fromJson(Map<String, dynamic> json, String documentId) {
    // Parse PlantConfig if present
    PlantConfigModel? config;
    if (json['config'] != null) {
      final configData = json['config'] as Map<String, dynamic>;
      config = PlantConfigModel(
        wateringIntervalDays: configData['watering_interval_days'] as int?,
        fertilizingIntervalDays: configData['fertilizing_interval_days'] as int?,
        pruningIntervalDays: configData['pruning_interval_days'] as int?,
        sunlightCheckIntervalDays: configData['sunlight_check_interval_days'] as int?,
        pestInspectionIntervalDays: configData['pest_inspection_interval_days'] as int?,
        replantingIntervalDays: configData['replanting_interval_days'] as int?,
        lightRequirement: configData['light_requirement'] as String?,
        waterAmount: configData['water_amount'] as String?,
        soilType: configData['soil_type'] as String?,
        idealTemperature: (configData['ideal_temperature'] as num?)?.toDouble(),
        idealHumidity: (configData['ideal_humidity'] as num?)?.toDouble(),
        enableWateringCare: configData['enable_watering_care'] as bool?,
        lastWateringDate: configData['last_watering_date'] != null
            ? (configData['last_watering_date'] as Timestamp).toDate()
            : null,
        enableFertilizerCare: configData['enable_fertilizer_care'] as bool?,
        lastFertilizerDate: configData['last_fertilizer_date'] != null
            ? (configData['last_fertilizer_date'] as Timestamp).toDate()
            : null,
      );
    }

    return PlantModel(
      // Use Firestore document ID as local ID
      id: documentId,

      // Plant-specific fields
      name: json['name'] as String,
      species: json['species'] as String?,
      spaceId: json['space_id'] as String?,
      imageBase64: json['image_base64'] as String?,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : const [],
      plantingDate: json['planting_date'] != null
          ? (json['planting_date'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
      isFavorited: json['is_favorited'] as bool? ?? false,
      config: config,

      // BaseSyncEntity fields
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
      lastSyncAt: json['last_sync_at'] != null
          ? (json['last_sync_at'] as Timestamp).toDate()
          : DateTime.now(), // Mark as synced
      isDirty: false, // Remote data is clean (authoritative)
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['user_id'] as String?,
      moduleName: json['module_name'] as String? ?? 'plantis',
    );
  }

  /// Batch convert multiple Firestore documents to PlantModels
  static List<PlantModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
