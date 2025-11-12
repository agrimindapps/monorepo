import 'package:core/core.dart';

import '../../../../core/data/models/base_sync_model.dart';

/// Expense (Despesa) model with Firebase sync support
/// TypeId: 13 - Gasometer range (10-19) to avoid conflicts with other apps
class ExpenseModel extends BaseSyncModel {
  ExpenseModel({
    required String id,
    int? createdAtMs,
    int? updatedAtMs,
    int? lastSyncAtMs,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName = 'gasometer',
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
    this.receiptImageUrl,
  }) : super(
         id: id,
         createdAt: createdAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
             : null,
         updatedAt: updatedAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
             : null,
         lastSyncAt: lastSyncAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs)
             : null,
         isDirty: isDirty,
         isDeleted: isDeleted,
         version: version,
         userId: userId,
         moduleName: moduleName,
       );

  // Field declarations
  final String veiculoId;
  final String tipo;
  final String descricao;
  final double valor;
  final int data;
  final double odometro;
  final String? receiptImagePath;
  final String? location;
  final String? notes;
  final Map<String, dynamic> metadata;
  final String? receiptImageUrl;

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
    String? receiptImageUrl,
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
      receiptImageUrl: receiptImageUrl,
    );
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
      metadata: Map<String, dynamic>.from(
        (map['metadata'] as Map<dynamic, dynamic>?) ?? {},
      ),
      receiptImageUrl: map['receipt_image_url']?.toString(),
    );
  }

  /// Create from JSON map (Firebase format)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel.fromFirebaseMap(json);
  }

  @override
  String get collectionName => 'expenses';

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
      'receipt_image_url': receiptImageUrl,
    };
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
    String? receiptImageUrl,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      createdAtMs:
          createdAt?.millisecondsSinceEpoch ??
          this.createdAt?.millisecondsSinceEpoch,
      updatedAtMs:
          updatedAt?.millisecondsSinceEpoch ??
          this.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs:
          lastSyncAt?.millisecondsSinceEpoch ??
          this.lastSyncAt?.millisecondsSinceEpoch,
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
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
    );
  }

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
