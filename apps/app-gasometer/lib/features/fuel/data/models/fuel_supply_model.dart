import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:hive/hive.dart';

import '../../../../core/data/models/base_sync_model.dart';

part 'fuel_supply_model.g.dart';

/// Fuel Supply (Abastecimento) model with Firebase sync support
/// TypeId: 1 - New sequential numbering
@HiveType(typeId: 1)
// ignore: must_be_immutable
class FuelSupplyModel extends BaseSyncModel {
  // Base sync fields (required for Hive generation)
  @HiveField(0) @override final String id;
  @HiveField(1) final int? createdAtMs;
  @HiveField(2) final int? updatedAtMs;
  @HiveField(3) final int? lastSyncAtMs;
  @HiveField(4) @override final bool isDirty;
  @HiveField(5) @override final bool isDeleted;
  @HiveField(6) @override final int version;
  @HiveField(7) @override final String? userId;
  @HiveField(8) @override final String? moduleName;

  // Fuel supply specific fields - using English names aligned with Entity
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

  @override
  String get collectionName => 'fuel_supplies';

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
    // Legacy parameters for backward compatibility
    String? veiculoId,
    int? data,
    double? odometro,
    double? litros,
    double? valorTotal,
    bool? tanqueCheio,
    double? precoPorLitro,
    String? posto,
    String? observacao,
    int? tipoCombustivel,
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
      vehicleId: vehicleId ?? veiculoId ?? '',
      date: date ?? data ?? 0,
      odometer: odometer ?? odometro ?? 0.0,
      liters: liters ?? litros ?? 0.0,
      totalPrice: totalPrice ?? valorTotal ?? 0.0,
      fullTank: fullTank ?? tanqueCheio,
      pricePerLiter: pricePerLiter ?? precoPorLitro ?? 0.0,
      gasStationName: gasStationName ?? posto,
      notes: notes ?? observacao,
      fuelType: fuelType ?? tipoCombustivel ?? 0,
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
      vehicleId: map['vehicleId']?.toString() ?? map['veiculoId']?.toString() ?? '',
      date: (map['date'] as num?)?.toInt() ?? (map['data'] as num?)?.toInt() ?? 0,
      odometer: (map['odometer'] as num? ?? map['odometro'] as num? ?? 0.0).toDouble(),
      liters: (map['liters'] as num? ?? map['litros'] as num? ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] as num? ?? map['valorTotal'] as num? ?? 0.0).toDouble(),
      fullTank: map['fullTank'] as bool? ?? map['tanqueCheio'] as bool?,
      pricePerLiter: (map['pricePerLiter'] as num? ?? map['precoPorLitro'] as num? ?? 0.0).toDouble(),
      gasStationName: map['gasStationName']?.toString() ?? map['posto']?.toString(),
      notes: map['notes']?.toString() ?? map['observacao']?.toString(),
      fuelType: (map['fuelType'] as num?)?.toInt() ?? (map['tipoCombustivel'] as num?)?.toInt() ?? 0,
      receiptImageUrl: map['receiptImageUrl']?.toString(),
      receiptImagePath: map['receiptImagePath']?.toString(),
    );
  }

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
        // Legacy support
        'veiculoId': vehicleId,
        'data': date,
        'odometro': odometer,
        'litros': liters,
        'valorTotal': totalPrice,
        'tanqueCheio': fullTank,
        'precoPorLitro': pricePerLiter,
        'posto': gasStationName,
        'observacao': notes,
        'tipoCombustivel': fuelType,
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
      // Legacy Firebase fields for backward compatibility
      'veiculo_id': vehicleId,
      'data': date,
      'odometro': odometer,
      'litros': liters,
      'valor_total': totalPrice,
      'tanque_cheio': fullTank,
      'preco_por_litro': pricePerLiter,
      'posto': gasStationName,
      'observacao': notes,
      'tipo_combustivel': fuelType,
      'receipt_image_url': receiptImageUrl,
      'receipt_image_path': receiptImagePath,
    };
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
      vehicleId: map['vehicle_id']?.toString() ?? map['veiculo_id']?.toString() ?? '',
      date: (map['date'] as num?)?.toInt() ?? (map['data'] as num?)?.toInt() ?? 0,
      odometer: (map['odometer'] as num? ?? map['odometro'] as num? ?? 0.0).toDouble(),
      liters: (map['liters'] as num? ?? map['litros'] as num? ?? 0.0).toDouble(),
      totalPrice: (map['total_price'] as num? ?? map['valor_total'] as num? ?? 0.0).toDouble(),
      fullTank: map['full_tank'] as bool? ?? map['tanque_cheio'] as bool?,
      pricePerLiter: (map['price_per_liter'] as num? ?? map['preco_por_litro'] as num? ?? 0.0).toDouble(),
      gasStationName: map['gas_station_name']?.toString() ?? map['posto']?.toString(),
      notes: map['notes']?.toString() ?? map['observacao']?.toString(),
      fuelType: (map['fuel_type'] as num?)?.toInt() ?? (map['tipo_combustivel'] as num?)?.toInt() ?? 0,
      receiptImageUrl: map['receipt_image_url']?.toString(),
      receiptImagePath: map['receipt_image_path']?.toString(),
    );
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
    // Legacy support
    String? veiculoId,
    int? data,
    double? odometro,
    double? litros,
    double? valorTotal,
    bool? tanqueCheio,
    double? precoPorLitro,
    String? posto,
    String? observacao,
    int? tipoCombustivel,
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
      vehicleId: vehicleId ?? veiculoId ?? this.vehicleId,
      date: date ?? data ?? this.date,
      odometer: odometer ?? odometro ?? this.odometer,
      liters: liters ?? litros ?? this.liters,
      totalPrice: totalPrice ?? valorTotal ?? this.totalPrice,
      fullTank: fullTank ?? tanqueCheio ?? this.fullTank,
      pricePerLiter: pricePerLiter ?? precoPorLitro ?? this.pricePerLiter,
      gasStationName: gasStationName ?? posto ?? this.gasStationName,
      notes: notes ?? observacao ?? this.notes,
      fuelType: fuelType ?? tipoCombustivel ?? this.fuelType,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory FuelSupplyModel.fromMap(Map<String, dynamic> map) => FuelSupplyModel.fromHiveMap(map);
  /// FIXED: fromJson now correctly handles Firebase Timestamp objects
  factory FuelSupplyModel.fromJson(Map<String, dynamic> json) {
    // Check if this is Firebase data (contains Timestamp objects)
    final hasTimestamp = json.values.any((value) => value is Timestamp);
    
    if (hasTimestamp || json.containsKey('created_at') || json.containsKey('updated_at')) {
      // Use Firebase parsing for data from remote source
      return FuelSupplyModel.fromFirebaseMap(json);
    } else {
      // Use Hive parsing for local data
      return FuelSupplyModel.fromHiveMap(json);
    }
  }

  // Legacy Portuguese getters for backward compatibility
  String get veiculoId => vehicleId;
  int get data => date;
  double get odometro => odometer;
  double get litros => liters;
  double get valorTotal => totalPrice;
  bool? get tanqueCheio => fullTank;
  double get precoPorLitro => pricePerLiter;
  String? get posto => gasStationName;
  String? get observacao => notes;
  int get tipoCombustivel => fuelType;
  
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