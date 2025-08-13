import 'package:hive/hive.dart';
import '../../../core/data/models/base_sync_model.dart';

part 'fuel_supply_model.g.dart';

/// Fuel Supply (Abastecimento) model with Firebase sync support
/// TypeId: 1 - New sequential numbering
@HiveType(typeId: 1)
class FuelSupplyModel extends BaseSyncModel {
  // Sync fields from BaseSyncModel (stored as milliseconds for Hive)
  @HiveField(0) final String id;
  @HiveField(1) final int? createdAtMs;
  @HiveField(2) final int? updatedAtMs;
  @HiveField(3) final int? lastSyncAtMs;
  @HiveField(4) final bool isDirty;
  @HiveField(5) final bool isDeleted;
  @HiveField(6) final int version;
  @HiveField(7) final String? userId;
  @HiveField(8) final String? moduleName;

  // Fuel supply specific fields
  @HiveField(10) final String veiculoId;
  @HiveField(11) final int data;
  @HiveField(12) final double odometro;
  @HiveField(13) final double litros;
  @HiveField(14) final double valorTotal;
  @HiveField(15) final bool? tanqueCheio;
  @HiveField(16) final double precoPorLitro;
  @HiveField(17) final String? posto;
  @HiveField(18) final String? observacao;
  @HiveField(19) final int tipoCombustivel;

  const FuelSupplyModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'gasometer',
    required this.veiculoId,
    required this.data,
    required this.odometro,
    required this.litros,
    required this.valorTotal,
    this.tanqueCheio,
    required this.precoPorLitro,
    this.posto,
    this.observacao,
    required this.tipoCombustivel,
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
    required String veiculoId,
    required int data,
    required double odometro,
    required double litros,
    required double valorTotal,
    bool? tanqueCheio,
    required double precoPorLitro,
    String? posto,
    String? observacao,
    required int tipoCombustivel,
  }) {
    final now = DateTime.now();
    final supplyId = id ?? now.millisecondsSinceEpoch.toString();
    
    return FuelSupplyModel(
      id: supplyId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      veiculoId: veiculoId,
      data: data,
      odometro: odometro,
      litros: litros,
      valorTotal: valorTotal,
      tanqueCheio: tanqueCheio,
      precoPorLitro: precoPorLitro,
      posto: posto,
      observacao: observacao,
      tipoCombustivel: tipoCombustivel,
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
      veiculoId: map['veiculoId']?.toString() ?? '',
      data: map['data']?.toInt() ?? 0,
      odometro: (map['odometro'] ?? 0.0).toDouble(),
      litros: (map['litros'] ?? 0.0).toDouble(),
      valorTotal: (map['valorTotal'] ?? 0.0).toDouble(),
      tanqueCheio: map['tanqueCheio'],
      precoPorLitro: (map['precoPorLitro'] ?? 0.0).toDouble(),
      posto: map['posto']?.toString(),
      observacao: map['observacao']?.toString(),
      tipoCombustivel: map['tipoCombustivel']?.toInt() ?? 0,
    );
  }

  /// Convert to Hive map
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'veiculoId': veiculoId,
        'data': data,
        'odometro': odometro,
        'litros': litros,
        'valorTotal': valorTotal,
        'tanqueCheio': tanqueCheio,
        'precoPorLitro': precoPorLitro,
        'posto': posto,
        'observacao': observacao,
        'tipoCombustivel': tipoCombustivel,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'veiculo_id': veiculoId,
      'data': data,
      'odometro': odometro,
      'litros': litros,
      'valor_total': valorTotal,
      'tanque_cheio': tanqueCheio,
      'preco_por_litro': precoPorLitro,
      'posto': posto,
      'observacao': observacao,
      'tipo_combustivel': tipoCombustivel,
    };
  }

  /// Create from Firebase map
  factory FuelSupplyModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
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
      veiculoId: map['veiculo_id']?.toString() ?? '',
      data: map['data']?.toInt() ?? 0,
      odometro: (map['odometro'] ?? 0.0).toDouble(),
      litros: (map['litros'] ?? 0.0).toDouble(),
      valorTotal: (map['valor_total'] ?? 0.0).toDouble(),
      tanqueCheio: map['tanque_cheio'],
      precoPorLitro: (map['preco_por_litro'] ?? 0.0).toDouble(),
      posto: map['posto']?.toString(),
      observacao: map['observacao']?.toString(),
      tipoCombustivel: map['tipo_combustivel']?.toInt() ?? 0,
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
  }) {
    return FuelSupplyModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? this.createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? this.updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? this.lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      veiculoId: veiculoId ?? this.veiculoId,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      litros: litros ?? this.litros,
      valorTotal: valorTotal ?? this.valorTotal,
      tanqueCheio: tanqueCheio ?? this.tanqueCheio,
      precoPorLitro: precoPorLitro ?? this.precoPorLitro,
      posto: posto ?? this.posto,
      observacao: observacao ?? this.observacao,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory FuelSupplyModel.fromMap(Map<String, dynamic> map) => FuelSupplyModel.fromHiveMap(map);
  factory FuelSupplyModel.fromJson(Map<String, dynamic> json) => FuelSupplyModel.fromHiveMap(json);

  /// Calculate correct consumption in km/L with previous odometer
  double calcularConsumoCorreto(double odometroAnterior) {
    if (litros <= 0) return 0.0;
    
    final distanciaPercorrida = odometro - odometroAnterior;
    if (distanciaPercorrida <= 0) return 0.0;
    
    return distanciaPercorrida / litros;
  }
  
  /// Calculate consumption in L/100km (European standard)
  double calcularConsumoL100km(double odometroAnterior) {
    final consumoKmL = calcularConsumoCorreto(odometroAnterior);
    if (consumoKmL <= 0) return 0.0;
    
    return 100 / consumoKmL;
  }

  /// Calculate average price per liter
  double calcularPrecoPorLitro() {
    return litros > 0 ? valorTotal / litros : 0.0;
  }

  /// Check if fuel supply belongs to specific vehicle
  bool pertenceAoVeiculo(int idVeiculo) {
    return veiculoId.toString() == idVeiculo.toString();
  }

  /// Validate basic required fields
  bool validarCamposBasicos() {
    return veiculoId.isNotEmpty && 
           data > 0 && 
           litros > 0 && 
           valorTotal > 0 && 
           odometro > 0 &&
           precoPorLitro > 0;
  }
  
  /// Validate financial consistency (total value vs price per liter)
  bool validarConsistenciaFinanceira({double toleranciaPercentual = 5.0}) {
    if (litros <= 0 || precoPorLitro <= 0) return false;
    
    final valorCalculado = precoPorLitro * litros;
    final diferenca = (valorTotal - valorCalculado).abs();
    final percentualDiferenca = (diferenca / valorTotal) * 100;
    
    return percentualDiferenca <= toleranciaPercentual;
  }

  /// Update total value - returns new instance (immutable)
  FuelSupplyModel atualizarValorTotal(double novoValor) {
    return copyWith(
      valorTotal: novoValor,
      updatedAt: DateTime.now(),
      isDirty: true,
    );
  }

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
    return 'FuelSupplyModel(id: $id, veiculoId: $veiculoId, data: $data, litros: $litros, valorTotal: $valorTotal)';
  }
}