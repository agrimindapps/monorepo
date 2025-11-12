import 'package:core/core.dart';

import '../../../../core/data/models/base_sync_model.dart';

/// Odometer model with Firebase sync support
class OdometerModel extends BaseSyncModel {

  OdometerModel({
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
    this.registrationDate = 0,
    this.value = 0.0,
    this.description = '',
    this.type,
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

  /// Factory constructor for creating new odometer reading
  factory OdometerModel.create({
    String? id,
    String? userId,
    required String vehicleId,
    required int registrationDate,
    required double value,
    required String description,
    String? type,
  }) {
    final now = DateTime.now();
    final readingId = id ?? now.millisecondsSinceEpoch.toString();
    
    return OdometerModel(
      id: readingId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      vehicleId: vehicleId,
      registrationDate: registrationDate,
      value: value,
      description: description,
      type: type,
    );
  }

  /// Create from map
  factory OdometerModel.fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);
    
    return OdometerModel(
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
      registrationDate: (map['registrationDate'] as num?)?.toInt() ?? 0,
      value: (map['value'] as num? ?? 0.0).toDouble(),
      description: map['description']?.toString() ?? '',
      type: map['type']?.toString(),
    );
  }

  /// Create from Firebase map
  factory OdometerModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);
    
    return OdometerModel(
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
      registrationDate: (map['registration_date'] as num?)?.toInt() ?? 0,
      value: (map['value'] as num? ?? 0.0).toDouble(),
      description: map['description']?.toString() ?? '',
      type: map['type']?.toString(),
    );
  }

  factory OdometerModel.fromJson(Map<String, dynamic> json) => OdometerModel.fromMap(json);
  @override final String id;
  final int? createdAtMs;
  final int? updatedAtMs;
  final int? lastSyncAtMs;
  @override final bool isDirty;
  @override final bool isDeleted;
  @override final int version;
  @override final String? userId;
  @override final String? moduleName;
  final String vehicleId;
  final int registrationDate;
  final double value;
  final String description;
  final String? type;

  @override
  String get collectionName => 'odometer_readings';

  /// Convert to map
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'vehicleId': vehicleId,
        'registrationDate': registrationDate,
        'value': value,
        'description': description,
        'type': type,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'vehicle_id': vehicleId,
      'registration_date': registrationDate,
      'value': value,
      'description': description,
      'type': type,
    };
  }

  /// copyWith method for immutability
  @override
  OdometerModel copyWith({
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
    int? registrationDate,
    double? value,
    String? description,
    String? type,
  }) {
    return OdometerModel(
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
      registrationDate: registrationDate ?? this.registrationDate,
      value: value ?? this.value,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OdometerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OdometerModel(id: $id, vehicleId: $vehicleId, registrationDate: $registrationDate, value: $value, description: $description)';
  }
}
