import 'package:core/core.dart';

import '../../../../core/data/models/base_sync_model.dart';

part 'fuel_supply_model.g.dart';

/// Fuel Supply (Abastecimento) model with Firebase sync support
/// TypeId: 11 - Gasometer range (10-19) to avoid conflicts with other apps
@HiveType(typeId: 11)
class FuelSupplyModel extends BaseSyncModel {

  FuelSupplyModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'gasometer',
    this.vehicleId = '',
    this.date = 0,
    this.odometer = 0.0,
    this.liters = 0.0,
    this.totalPrice = 0.0,
    this.fullTank,
    this.pricePerLiter = 0.0,
    this.gasStationName,
    this.notes,
    this.fuelType = 0,
    this.receiptImageUrl,
    this.receiptImagePath,
  }) : super(
          id: id,
          createdAt: createdAtMs != null ? DateTime.fromMillisecondsSinceEpoch(createdAtMs) : null,
          updatedAt: updatedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs) : null,
          lastSyncAt: lastSyncAtMs != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs) : null,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  /// Factory constructor for creating new fuel supply
  factory FuelSupplyModel.create({
    String? id,
    String? userId,
    required String vehicleId,
    required int date,
    required double odometer,
    required double liters,
    required double totalPrice,
    bool? fullTank,
    required double pricePerLiter,
    String? gasStationName,
    String? notes,
    required int fuelType,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    final now = DateTime.now();
    final supplyId = id ?? now.millisecondsSinceEpoch.toString();
    
    return FuelSupplyModel(
      id: supplyId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      vehicleId: vehicleId,
      date: date,
      odometer: odometer,
      liters: liters,
      totalPrice: totalPrice,
      fullTank: fullTank,
      pricePerLiter: pricePerLiter,
      gasStationName: gasStationName,
      notes: notes,
      fuelType: fuelType,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );
  }

  /// Create from Hive map
  factory FuelSupplyModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);
    
    return FuelSupplyModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      vehicleId: map['vehicleId']?.toString() ?? '',
      date: (map['date'] as num?)?.toInt() ?? 0,
      odometer: (map['odometer'] as num? ?? 0.0).toDouble(),
      liters: (map['liters'] as num? ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] as num? ?? 0.0).toDouble(),
      fullTank: map['fullTank'] as bool?,
      pricePerLiter: (map['pricePerLiter'] as num? ?? 0.0).toDouble(),
      gasStationName: map['gasStationName']?.toString(),
      notes: map['notes']?.toString(),
      fuelType: (map['fuelType'] as num?)?.toInt() ?? 0,
      receiptImageUrl: map['receiptImageUrl']?.toString(),
      receiptImagePath: map['receiptImagePath']?.toString(),
    );
  }

  /// Create from Firebase map
  factory FuelSupplyModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);
    
    return FuelSupplyModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      vehicleId: map['vehicle_id']?.toString() ?? '',
      date: (map['date'] as num?)?.toInt() ?? 0,
      odometer: (map['odometer'] as num? ?? 0.0).toDouble(),
      liters: (map['liters'] as num? ?? 0.0).toDouble(),
      totalPrice: (map['total_price'] as num? ?? 0.0).toDouble(),
      fullTank: map['full_tank'] as bool?,
      pricePerLiter: (map['price_per_liter'] as num? ?? 0.0).toDouble(),
      gasStationName: map['gas_station_name']?.toString(),
      notes: map['notes']?.toString(),
      fuelType: (map['fuel_type'] as num?)?.toInt() ?? 0,
      receiptImageUrl: map['receipt_image_url']?.toString(),
      receiptImagePath: map['receipt_image_path']?.toString(),
    );
  }

  /// FIXED: fromJson now correctly handles Firebase Timestamp objects
  factory FuelSupplyModel.fromJson(Map<String, dynamic> json) {
    final hasTimestamp = json.values.any((value) => value is Timestamp);
    
    if (hasTimestamp || json.containsKey('created_at') || json.containsKey('updated_at')) {
      return FuelSupplyModel.fromFirebaseMap(json);
    } else {
      return FuelSupplyModel.fromHiveMap(json);
    }
  }
  @HiveField(0) @override final String id;
  @HiveField(1) final int? createdAtMs;
  @HiveField(2) final int? updatedAtMs;
  @HiveField(3) final int? lastSyncAtMs;
  @HiveField(4) @override final bool isDirty;
  @HiveField(5) @override final bool isDeleted;
  @HiveField(6) @override final int version;
  @HiveField(7) @override final String? userId;
  @HiveField(8) @override final String? moduleName;
  @HiveField(10) final String vehicleId;
  @HiveField(11) final int date;
  @HiveField(12) final double odometer;
  @HiveField(13) final double liters;
  @HiveField(14) final double totalPrice;
  @HiveField(15) final bool? fullTank;
  @HiveField(16) final double pricePerLiter;
  @HiveField(17) final String? gasStationName;
  @HiveField(18) final String? notes;
  @HiveField(19) final int fuelType;
  @HiveField(20) final String? receiptImageUrl;
  @HiveField(21) final String? receiptImagePath;

  @override
  String get collectionName => 'fuel_supplies';

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'vehicleId': vehicleId,
        'date': date,
        'odometer': odometer,
        'liters': liters,
        'totalPrice': totalPrice,
        'fullTank': fullTank,
        'pricePerLiter': pricePerLiter,
        'gasStationName': gasStationName,
        'notes': notes,
        'fuelType': fuelType,
        'receiptImageUrl': receiptImageUrl,
        'receiptImagePath': receiptImagePath,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'vehicle_id': vehicleId,
      'date': date,
      'odometer': odometer,
      'liters': liters,
      'total_price': totalPrice,
      'full_tank': fullTank,
      'price_per_liter': pricePerLiter,
      'gas_station_name': gasStationName,
      'notes': notes,
      'fuel_type': fuelType,
      'receipt_image_url': receiptImageUrl,
      'receipt_image_path': receiptImagePath,
    };
  }

  /// copyWith method for immutability
  @override
  FuelSupplyModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? vehicleId,
    int? date,
    double? odometer,
    double? liters,
    double? totalPrice,
    bool? fullTank,
    double? pricePerLiter,
    String? gasStationName,
    String? notes,
    int? fuelType,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    return FuelSupplyModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      totalPrice: totalPrice ?? this.totalPrice,
      fullTank: fullTank ?? this.fullTank,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      gasStationName: gasStationName ?? this.gasStationName,
      notes: notes ?? this.notes,
      fuelType: fuelType ?? this.fuelType,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  
  /// Get the fuel supply date as DateTime object
  DateTime get supplyDate => DateTime.fromMillisecondsSinceEpoch(date);

  /// Get calculated price per liter (for display purposes)
  double get calculatedPricePerLiter => liters > 0 ? totalPrice / liters : 0.0;

  /// Clone the object - returns copy with same data
  FuelSupplyModel clone() {
    return copyWith();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FuelSupplyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FuelSupplyModel(id: $id, vehicleId: $vehicleId, date: $date, liters: $liters, totalPrice: $totalPrice)';
  }
}
