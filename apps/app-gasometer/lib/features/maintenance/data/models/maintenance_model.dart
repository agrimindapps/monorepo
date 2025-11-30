import 'package:core/core.dart';

import '../../../../core/data/models/base_sync_model.dart';

/// Helper function to safely convert dynamic values to bool
bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  if (value is int) return value != 0;
  if (value == null) return false;
  // If it's a Map or any other type, treat as false
  return false;
}

/// Maintenance (Manutenção) model with Firebase sync support
/// TypeId: 14 - Gasometer range (10-19) to avoid conflicts with other apps
class MaintenanceModel extends BaseSyncModel {
  MaintenanceModel({
    required super.id,
    int? createdAtMs,
    int? updatedAtMs,
    int? lastSyncAtMs,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
    this.veiculoId = '',
    this.tipo = '',
    this.descricao = '',
    this.valor = 0.0,
    this.data = 0,
    this.odometro = 0,
    this.proximaRevisao,
    this.concluida = false,
    this.receiptImageUrl,
    this.receiptImagePath,
  }) : super(
         createdAt: createdAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
             : null,
         updatedAt: updatedAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
             : null,
         lastSyncAt: lastSyncAtMs != null
             ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs)
             : null,
       );
  factory MaintenanceModel.create({
    String? id,
    String? userId,
    required String veiculoId,
    required String tipo,
    required String descricao,
    required double valor,
    required int data,
    required int odometro,
    int? proximaRevisao,
    bool concluida = false,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    final now = DateTime.now();
    final maintenanceId = id ?? now.millisecondsSinceEpoch.toString();

    return MaintenanceModel(
      id: maintenanceId,
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
      proximaRevisao: proximaRevisao,
      concluida: concluida,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );
  }

  /// Create from Firebase map
  factory MaintenanceModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return MaintenanceModel(
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
      odometro: (map['odometro'] as num?)?.toInt() ?? 0,
      proximaRevisao: (map['proxima_revisao'] as num?)?.toInt(),
      concluida: _parseBool(map['concluida']),
      receiptImageUrl: map['receipt_image_url']?.toString(),
      receiptImagePath: map['receipt_image_path']?.toString(),
    );
  }

  // Field declarations
  final String veiculoId;
  final String tipo;
  final String descricao;
  final double valor;
  final int data;
  final int odometro;
  final int? proximaRevisao;
  final bool concluida;
  final String? receiptImageUrl;
  final String? receiptImagePath;

  @override
  String get collectionName => 'maintenance';

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
      'proxima_revisao': proximaRevisao,
      'concluida': concluida,
      'receipt_image_url': receiptImageUrl,
      'receipt_image_path': receiptImagePath,
    };
  }

  /// copyWith method for immutability
  @override
  MaintenanceModel copyWith({
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
    int? odometro,
    int? proximaRevisao,
    bool? concluida,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    return MaintenanceModel(
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
      proximaRevisao: proximaRevisao ?? this.proximaRevisao,
      concluida: concluida ?? this.concluida,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  /// Calculate total maintenance costs
  static double calcularTotalManutencoes(List<MaintenanceModel> manutencoes) {
    return manutencoes.fold(
      0.0,
      (total, manutencao) => total + manutencao.valor,
    );
  }

  /// Filter maintenances by type
  static List<MaintenanceModel> filtrarPorTipo(
    List<MaintenanceModel> manutencoes,
    String tipo,
  ) {
    return manutencoes.where((manutencao) => manutencao.tipo == tipo).toList();
  }

  /// Sort maintenances by date (most recent first)
  static List<MaintenanceModel> ordenarPorData(
    List<MaintenanceModel> manutencoes,
  ) {
    manutencoes.sort((a, b) => b.data.compareTo(a.data));
    return manutencoes;
  }

  /// Check if has higher value than another maintenance
  bool possuiMaiorValor(MaintenanceModel outraManutencao) {
    return valor > outraManutencao.valor;
  }

  /// Check if belongs to specific date
  bool pertenceAData(DateTime dataAlvo) {
    final maintenanceDate = DateTime.fromMillisecondsSinceEpoch(data);
    return maintenanceDate.year == dataAlvo.year &&
        maintenanceDate.month == dataAlvo.month &&
        maintenanceDate.day == dataAlvo.day;
  }

  /// Check if maintenance is overdue
  bool estaVencida() {
    if (proximaRevisao == null) return false;
    return DateTime.now().millisecondsSinceEpoch > proximaRevisao!;
  }

  /// Check if needs review based on current odometer
  bool precisaRevisao(int odometroAtual) {
    const int intervaloRevisao = 10000; // 10.000 km
    return (odometroAtual - odometro) >= intervaloRevisao;
  }

  /// Check if value is within range
  bool valorDentroDoIntervalo(double min, double max) {
    return valor >= min && valor <= max;
  }

  /// Clone the object - returns copy with same data
  MaintenanceModel clone() {
    return copyWith();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MaintenanceModel(id: $id, veiculoId: $veiculoId, tipo: $tipo, descricao: $descricao, valor: $valor)';
  }
}
