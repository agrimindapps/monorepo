import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:hive/hive.dart';

import '../../../../core/data/models/base_sync_model.dart';

part 'expense_model.g.dart';

/// Expense (Despesa) model with Firebase sync support
/// TypeId: 3 - New sequential numbering
@HiveType(typeId: 3)
// ignore: must_be_immutable
class ExpenseModel extends BaseSyncModel {
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

  // Expense specific fields
  @HiveField(10)
  final String veiculoId;
  @HiveField(11)
  final String tipo;
  @HiveField(12)
  final String descricao;
  @HiveField(13)
  final double valor;
  @HiveField(14)
  final int data;
  @HiveField(15)
  final double odometro;
  @HiveField(16)
  final String? receiptImagePath;
  @HiveField(17)
  final String? location;
  @HiveField(18)
  final String? notes;
  @HiveField(19)
  final Map<String, dynamic> metadata;

  ExpenseModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'gasometer',
    this.veiculoId = '',
    this.tipo = '',
    this.descricao = '',
    this.valor = 0.0,
    this.data = 0,
    this.odometro = 0.0,
    this.receiptImagePath,
    this.location,
    this.notes,
    this.metadata = const {},
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
  String get collectionName => 'expenses';

  /// Factory constructor for creating new expense
  factory ExpenseModel.create({
    String? id,
    String? userId,
    required String veiculoId,
    required String tipo,
    required String descricao,
    required double valor,
    required int data,
    required double odometro,
    String? receiptImagePath,
    String? location,
    String? notes,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    final expenseId = id ?? now.millisecondsSinceEpoch.toString();

    return ExpenseModel(
      id: expenseId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      veiculoId: veiculoId,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      data: data,
      odometro: odometro,
      receiptImagePath: receiptImagePath,
      location: location,
      notes: notes,
      metadata: metadata,
    );
  }

  /// Create from Hive map
  factory ExpenseModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return ExpenseModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      veiculoId: map['veiculoId']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      valor: (map['valor'] as num? ?? 0.0).toDouble(),
      data: (map['data'] as num?)?.toInt() ?? 0,
      odometro: (map['odometro'] as num? ?? 0.0).toDouble(),
      receiptImagePath: map['receiptImagePath']?.toString(),
      location: map['location']?.toString(),
      notes: map['notes']?.toString(),
      metadata: Map<String, dynamic>.from((map['metadata'] as Map<dynamic, dynamic>?) ?? {}),
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()..addAll({
      'veiculoId': veiculoId,
      'tipo': tipo,
      'descricao': descricao,
      'valor': valor,
      'data': data,
      'odometro': odometro,
      'receiptImagePath': receiptImagePath,
      'location': location,
      'notes': notes,
      'metadata': metadata,
    });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'veiculo_id': veiculoId,
      'tipo': tipo,
      'descricao': descricao,
      'valor': valor,
      'data': data,
      'odometro': odometro,
      'receipt_image_path': receiptImagePath,
      'location': location,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Create from Firebase map
  factory ExpenseModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);
    
    return ExpenseModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      veiculoId: map['veiculo_id']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      valor: (map['valor'] as num? ?? 0.0).toDouble(),
      data: (map['data'] as num?)?.toInt() ?? 0,
      odometro: (map['odometro'] as num? ?? 0.0).toDouble(),
      receiptImagePath: map['receipt_image_path']?.toString(),
      location: map['location']?.toString(),
      notes: map['notes']?.toString(),
      metadata: Map<String, dynamic>.from((map['metadata'] as Map<dynamic, dynamic>?) ?? {}),
    );
  }

  /// FIXED: fromJson now correctly handles Firebase Timestamp objects
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // Check if this is Firebase data (contains Timestamp objects)
    final hasTimestamp = json.values.any((value) => value is Timestamp);
    
    if (hasTimestamp || json.containsKey('created_at') || json.containsKey('updated_at')) {
      // Use Firebase parsing for data from remote source
      return ExpenseModel.fromFirebaseMap(json);
    } else {
      // Use Hive parsing for local data
      return ExpenseModel.fromHiveMap(json);
    }
  }

  /// copyWith method for immutability
  @override
  ExpenseModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? veiculoId,
    String? tipo,
    String? descricao,
    double? valor,
    int? data,
    double? odometro,
    String? receiptImagePath,
    String? location,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      veiculoId: veiculoId ?? this.veiculoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory ExpenseModel.fromMap(Map<String, dynamic> map) =>
      ExpenseModel.fromHiveMap(map);

  /// Get the expense date as DateTime object
  DateTime get expenseDate => DateTime.fromMillisecondsSinceEpoch(data);

  /// Clone the object - returns copy with same data
  ExpenseModel clone() {
    return copyWith();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseModel(id: $id, veiculoId: $veiculoId, tipo: $tipo, descricao: $descricao, valor: $valor, receiptImagePath: $receiptImagePath, location: $location)';
  }
}
