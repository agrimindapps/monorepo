import 'package:core/core.dart';
import 'package:hive/hive.dart';

import '../../../../core/data/models/base_sync_model.dart';

part 'odometer_model.g.dart';

/// Odometer model with Firebase sync support
/// TypeId: 2 - New sequential numbering
@HiveType(typeId: 2)
// ignore: must_be_immutable
class OdometerModel extends BaseSyncModel {
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

  // Odometer specific fields
  @HiveField(10) final String idVeiculo;
  @HiveField(11) final int data;
  @HiveField(12) final double odometro;
  @HiveField(13) final String descricao;
  @HiveField(14) final String? tipoRegistro;

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
    this.idVeiculo = '',
    this.data = 0,
    this.odometro = 0.0,
    this.descricao = '',
    this.tipoRegistro,
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
  String get collectionName => 'odometer_readings';

  /// Factory constructor for creating new odometer reading
  factory OdometerModel.create({
    String? id,
    String? userId,
    required String idVeiculo,
    required int data,
    required double odometro,
    required String descricao,
    String? tipoRegistro,
  }) {
    final now = DateTime.now();
    final readingId = id ?? now.millisecondsSinceEpoch.toString();
    
    return OdometerModel(
      id: readingId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      idVeiculo: idVeiculo,
      data: data,
      odometro: odometro,
      descricao: descricao,
      tipoRegistro: tipoRegistro,
    );
  }

  /// Create from Hive map
  factory OdometerModel.fromHiveMap(Map<String, dynamic> map) {
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
      idVeiculo: map['idVeiculo']?.toString() ?? '',
      data: (map['data'] as num?)?.toInt() ?? 0,
      odometro: (map['odometro'] as num? ?? 0.0).toDouble(),
      descricao: map['descricao']?.toString() ?? '',
      tipoRegistro: map['tipoRegistro']?.toString(),
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'idVeiculo': idVeiculo,
        'data': data,
        'odometro': odometro,
        'descricao': descricao,
        'tipoRegistro': tipoRegistro,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'id_veiculo': idVeiculo,
      'data': data,
      'odometro': odometro,
      'descricao': descricao,
      'tipo_registro': tipoRegistro,
    };
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
      idVeiculo: map['id_veiculo']?.toString() ?? '',
      data: (map['data'] as num?)?.toInt() ?? 0,
      odometro: (map['odometro'] as num? ?? 0.0).toDouble(),
      descricao: map['descricao']?.toString() ?? '',
      tipoRegistro: map['tipo_registro']?.toString(),
    );
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
    String? idVeiculo,
    int? data,
    double? odometro,
    String? descricao,
    String? tipoRegistro,
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
      idVeiculo: idVeiculo ?? this.idVeiculo,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      descricao: descricao ?? this.descricao,
      tipoRegistro: tipoRegistro ?? this.tipoRegistro,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory OdometerModel.fromMap(Map<String, dynamic> map) => OdometerModel.fromHiveMap(map);
  factory OdometerModel.fromJson(Map<String, dynamic> json) => OdometerModel.fromHiveMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OdometerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OdometerModel(id: $id, idVeiculo: $idVeiculo, data: $data, odometro: $odometro, descricao: $descricao)';
  }
}