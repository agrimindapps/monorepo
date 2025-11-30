

/// Firebase mapper for Vehicle entities
/// Handles conversion between VehicleEntity and Firestore JSON format
///
/// Key responsibilities:
/// - Convert VehicleEntity to Firestore-compatible JSON (toJson)
/// - Convert Firestore JSON back to VehicleEntity (fromJson)
/// - Handle Timestamp conversions (DateTime ↔ Firestore Timestamp)
/// - Manage null safety for optional fields
/// - Include sync metadata (isDirty, version, firebaseId, lastSyncAt)
library;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
class VehicleFirebaseMapper {
  /// Convert VehicleEntity to Firestore JSON
  ///
  /// Firestore field naming convention: snake_case
  /// Excludes local-only 'id' field (document ID is stored separately)
  /// Converts DateTime to Timestamp for Firestore compatibility
  static Map<String, dynamic> toJson(VehicleEntity vehicle) {
    return {
      // Vehicle-specific fields
      'name': vehicle.name,
      'brand': vehicle.brand,
      'model': vehicle.model,
      'year': vehicle.year,
      'color': vehicle.color,
      'license_plate': vehicle.licensePlate,
      'type': vehicle.type.name,
      'supported_fuels': List<String>.from(vehicle.supportedFuels.map((e) => e.name)),
      'current_odometer': vehicle.currentOdometer,
      'is_active': vehicle.isActive,
      'metadata': Map<String, dynamic>.from(vehicle.metadata),

      // Optional fields
      if (vehicle.tankCapacity != null) 'tank_capacity': vehicle.tankCapacity,
      if (vehicle.engineSize != null) 'engine_size': vehicle.engineSize,
      if (vehicle.photoUrl != null) 'photo_url': vehicle.photoUrl,
      if (vehicle.averageConsumption != null) 'average_consumption': vehicle.averageConsumption,

      // BaseSyncEntity fields
      'created_at': vehicle.createdAt != null
          ? Timestamp.fromDate(vehicle.createdAt!.toUtc())
          : Timestamp.now(),
      'updated_at': vehicle.updatedAt != null
          ? Timestamp.fromDate(vehicle.updatedAt!.toUtc())
          : Timestamp.now(),
      'last_sync_at': vehicle.lastSyncAt != null
          ? Timestamp.fromDate(vehicle.lastSyncAt!.toUtc())
          : null,
      'is_dirty': false, // When pushing to Firebase, mark as clean
      'is_deleted': vehicle.isDeleted,
      'version': vehicle.version,
      'user_id': vehicle.userId,
      'module_name': vehicle.moduleName ?? 'gasometer',
    };
  }

  /// Convert Firestore JSON to VehicleEntity
  ///
  /// Parameters:
  /// - json: Firestore document data
  /// - documentId: Firestore document ID (becomes firebaseId)
  ///
  /// Returns VehicleEntity with:
  /// - isDirty = false (remote data is authoritative)
  /// - All Timestamp fields converted to DateTime
  /// - Null safety for all optional fields
  static VehicleEntity fromJson(Map<String, dynamic> json, String documentId) {
    // Parse supported fuels
    List<FuelType> supportedFuels = [FuelType.gasoline];
    if (json['supported_fuels'] != null) {
      supportedFuels = (json['supported_fuels'] as List<dynamic>)
          .map((e) => FuelType.fromString(e as String))
          .toList();
    }

    return VehicleEntity(
      // Use Firestore document ID
      id: documentId,
      firebaseId: documentId,

      // Vehicle-specific fields
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      color: json['color'] as String? ?? '',
      licensePlate: json['license_plate'] as String? ?? '',
      type: json['type'] != null
          ? VehicleType.fromString(json['type'] as String)
          : VehicleType.car,
      supportedFuels: supportedFuels,
      tankCapacity: (json['tank_capacity'] as num?)?.toDouble(),
      engineSize: (json['engine_size'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      currentOdometer: (json['current_odometer'] as num?)?.toDouble() ?? 0.0,
      averageConsumption: (json['average_consumption'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},

      // BaseSyncEntity fields
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
      lastSyncAt: _parseTimestamp(json['last_sync_at']) ?? DateTime.now(),
      isDirty: false, // Remote data is clean (authoritative)
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      userId: json['user_id'] as String?,
      moduleName: json['module_name'] as String? ?? 'gasometer',
    );
  }

  /// Batch convert multiple Firestore documents to VehicleEntities
  static List<VehicleEntity> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Parse Firestore Timestamp to DateTime
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
