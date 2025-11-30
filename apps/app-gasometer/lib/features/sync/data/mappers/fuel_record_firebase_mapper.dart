

/// Firebase mapper for FuelRecord entities
/// Handles conversion between FuelRecordEntity and Firestore JSON format
///
/// Key responsibilities:
/// - Convert FuelRecordEntity to Firestore-compatible JSON (toJson)
/// - Convert Firestore JSON back to FuelRecordEntity (fromJson)
/// - Handle Timestamp conversions (DateTime ↔ Firestore Timestamp)
/// - Manage null safety for optional fields
/// - Include sync metadata (isDirty, version, lastSyncAt)
library;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
class FuelRecordFirebaseMapper {
  /// Convert FuelRecordEntity to Firestore JSON
  ///
  /// Firestore field naming convention: snake_case
  /// Excludes local-only 'id' field (document ID is stored separately)
  /// Converts DateTime to Timestamp for Firestore compatibility
  static Map<String, dynamic> toJson(FuelRecordEntity record) {
    return {
      // FuelRecord-specific fields
      'vehicle_id': record.vehicleId,
      'fuel_type': record.fuelType.index,
      'liters': record.liters,
      'price_per_liter': record.pricePerLiter,
      'total_price': record.totalPrice,
      'odometer': record.odometer,
      'date': Timestamp.fromDate(record.date.toUtc()),
      'full_tank': record.fullTank,

      // Optional fields
      if (record.gasStationName != null) 'gas_station_name': record.gasStationName,
      if (record.gasStationBrand != null) 'gas_station_brand': record.gasStationBrand,
      if (record.latitude != null) 'latitude': record.latitude,
      if (record.longitude != null) 'longitude': record.longitude,
      if (record.notes != null) 'notes': record.notes,
      if (record.previousOdometer != null) 'previous_odometer': record.previousOdometer,
      if (record.distanceTraveled != null) 'distance_traveled': record.distanceTraveled,
      if (record.consumption != null) 'consumption': record.consumption,

      // BaseSyncEntity fields
      'created_at': record.createdAt != null
          ? Timestamp.fromDate(record.createdAt!.toUtc())
          : Timestamp.now(),
      'updated_at': record.updatedAt != null
          ? Timestamp.fromDate(record.updatedAt!.toUtc())
          : Timestamp.now(),
      'last_sync_at': record.lastSyncAt != null
          ? Timestamp.fromDate(record.lastSyncAt!.toUtc())
          : null,
      'is_dirty': false, // When pushing to Firebase, mark as clean
      'is_deleted': record.isDeleted,
      'version': record.version,
      'user_id': record.userId,
      'module_name': record.moduleName ?? 'gasometer',
    };
  }

  /// Convert Firestore JSON to FuelRecordEntity
  ///
  /// Parameters:
  /// - json: Firestore document data
  /// - documentId: Firestore document ID (becomes entity id)
  ///
  /// Returns FuelRecordEntity with:
  /// - isDirty = false (remote data is authoritative)
  /// - All Timestamp fields converted to DateTime
  /// - Null safety for all optional fields
  static FuelRecordEntity fromJson(Map<String, dynamic> json, String documentId) {
    return FuelRecordEntity(
      // Use Firestore document ID
      id: documentId,

      // FuelRecord-specific fields
      vehicleId: json['vehicle_id'] as String,
      fuelType: FuelType.values[json['fuel_type'] as int? ?? 0],
      liters: (json['liters'] as num).toDouble(),
      pricePerLiter: (json['price_per_liter'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      odometer: (json['odometer'] as num).toDouble(),
      date: _parseTimestamp(json['date']) ?? DateTime.now(),
      fullTank: json['full_tank'] as bool? ?? true,

      // Optional fields
      gasStationName: json['gas_station_name'] as String?,
      gasStationBrand: json['gas_station_brand'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      previousOdometer: (json['previous_odometer'] as num?)?.toDouble(),
      distanceTraveled: (json['distance_traveled'] as num?)?.toDouble(),
      consumption: (json['consumption'] as num?)?.toDouble(),

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

  /// Batch convert multiple Firestore documents to FuelRecordEntities
  static List<FuelRecordEntity> fromQuerySnapshot(QuerySnapshot snapshot) {
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
