import 'package:hive/hive.dart';
import 'package:core/core.dart';
import '../../../../core/data/models/base_sync_model.dart';

part 'maintenance_model.g.dart';

/// Maintenance (Manutenção) model with Firebase sync support
/// TypeId: 4 - New sequential numbering
@HiveType(typeId: 4)
// ignore: must_be_immutable
class MaintenanceModel extends BaseSyncModel {
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

  // Maintenance specific fields
  @HiveField(10) final String veiculoId;
  @HiveField(11) final String tipo; // Preventiva, Corretiva, Revisão
  @HiveField(12) final String descricao;
  @HiveField(13) final double valor;
  @HiveField(14) final int data;
  @HiveField(15) final int odometro;
  @HiveField(16) final int? proximaRevisao;
  @HiveField(17) final bool concluida;

  MaintenanceModel({
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
    this.odometro = 0,
    this.proximaRevisao,
    this.concluida = false,
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
  String get collectionName => 'maintenance';

  /// Factory constructor for creating new maintenance
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
    );
  }

  /// Create from Hive map
  factory MaintenanceModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);
    
    return MaintenanceModel(
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
      valor: (map['valor'] ?? 0.0).toDouble(),
      data: map['data']?.toInt() ?? 0,
      odometro: map['odometro']?.toInt() ?? 0,
      proximaRevisao: map['proximaRevisao']?.toInt(),
      concluida: map['concluida'] ?? false,
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'veiculoId': veiculoId,
        'tipo': tipo,
        'descricao': descricao,
        'valor': valor,
        'data': data,
        'odometro': odometro,
        'proximaRevisao': proximaRevisao,
        'concluida': concluida,
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
      'proxima_revisao': proximaRevisao,
      'concluida': concluida,
    };
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
      valor: (map['valor'] ?? 0.0).toDouble(),
      data: map['data']?.toInt() ?? 0,
      odometro: map['odometro']?.toInt() ?? 0,
      proximaRevisao: map['proxima_revisao']?.toInt(),
      concluida: map['concluida'] ?? false,
    );
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
  }) {
    return MaintenanceModel(
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
      proximaRevisao: proximaRevisao ?? this.proximaRevisao,
      concluida: concluida ?? this.concluida,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory MaintenanceModel.fromMap(Map<String, dynamic> map) => MaintenanceModel.fromHiveMap(map);
  factory MaintenanceModel.fromJson(Map<String, dynamic> json) => MaintenanceModel.fromHiveMap(json);

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
    return manutencoes
        .where((manutencao) => manutencao.tipo == tipo)
        .toList();
  }

  /// Sort maintenances by date (most recent first)
  static List<MaintenanceModel> ordenarPorData(
      List<MaintenanceModel> manutencoes) {
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