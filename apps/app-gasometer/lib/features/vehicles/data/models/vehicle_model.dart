import 'package:hive/hive.dart';
import 'package:core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/base_sync_model.dart';
import '../../domain/entities/vehicle_entity.dart';

part 'vehicle_model.g.dart';

/// Vehicle model with Firebase sync support
/// TypeId: 0 - New sequential numbering  
@HiveType(typeId: 0)
class VehicleModel extends BaseSyncModel {
  // Base sync fields (required for Hive generation)
  @HiveField(0) final String id;
  @HiveField(1) final int? createdAtMs;
  @HiveField(2) final int? updatedAtMs;
  @HiveField(3) final int? lastSyncAtMs;
  @HiveField(4) final bool isDirty;
  @HiveField(5) final bool isDeleted;
  @HiveField(6) final int version;
  @HiveField(7) final String? userId;
  @HiveField(8) final String? moduleName;

  // Vehicle specific fields  
  @HiveField(10) final String marca;
  @HiveField(11) final String modelo;
  @HiveField(12) final int ano;
  @HiveField(13) final String placa;
  @HiveField(14) final double odometroInicial;
  @HiveField(15) final int combustivel;
  @HiveField(16) final String renavan;
  @HiveField(17) final String chassi;
  @HiveField(18) final String cor;
  @HiveField(19) final bool vendido;
  @HiveField(20) final double valorVenda;
  @HiveField(21) final double odometroAtual;
  @HiveField(22) final String? foto;

  VehicleModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'gasometer',
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.odometroInicial,
    this.combustivel = 0,
    this.renavan = '',
    this.chassi = '',
    this.cor = '',
    this.vendido = false,
    this.valorVenda = 0.0,
    this.odometroAtual = 0.0,
    this.foto,
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
  String get collectionName => 'vehicles';

  /// Factory constructor for creating new vehicle
  factory VehicleModel.create({
    String? id,
    String? userId,
    required String marca,
    required String modelo,
    required int ano,
    required String placa,
    required double odometroInicial,
    int combustivel = 0,
    String renavan = '',
    String chassi = '',
    String cor = '',
    bool vendido = false,
    double valorVenda = 0.0,
    double odometroAtual = 0.0,
    String? foto,
  }) {
    final now = DateTime.now();
    final vehicleId = id ?? now.millisecondsSinceEpoch.toString();
    
    return VehicleModel(
      id: vehicleId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      marca: marca,
      modelo: modelo,
      ano: ano,
      placa: placa,
      odometroInicial: odometroInicial,
      combustivel: combustivel,
      renavan: renavan,
      chassi: chassi,
      cor: cor,
      vendido: vendido,
      valorVenda: valorVenda,
      odometroAtual: odometroAtual,
      foto: foto,
    );
  }

  /// Create from Hive map
  factory VehicleModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);
    
    return VehicleModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      marca: map['marca']?.toString() ?? '',
      modelo: map['modelo']?.toString() ?? '',
      ano: map['ano']?.toInt() ?? 0,
      placa: map['placa']?.toString() ?? '',
      odometroInicial: (map['odometroInicial'] ?? 0.0).toDouble(),
      combustivel: map['combustivel']?.toInt() ?? 0,
      renavan: map['renavan']?.toString() ?? '',
      chassi: map['chassi']?.toString() ?? '',
      cor: map['cor']?.toString() ?? '',
      vendido: map['vendido'] ?? false,
      valorVenda: (map['valorVenda'] ?? 0.0).toDouble(),
      odometroAtual: (map['odometroAtual'] ?? 0.0).toDouble(),
      foto: map['foto']?.toString(),
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'placa': placa,
        'odometroInicial': odometroInicial,
        'combustivel': combustivel,
        'renavan': renavan,
        'chassi': chassi,
        'cor': cor,
        'vendido': vendido,
        'valorVenda': valorVenda,
        'odometroAtual': odometroAtual,
        'foto': foto,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'odometro_inicial': odometroInicial,
      'combustivel': combustivel,
      'renavan': renavan,
      'chassi': chassi,
      'cor': cor,
      'vendido': vendido,
      'valor_venda': valorVenda,
      'odometro_atual': odometroAtual,
      'foto': foto,
    };
  }

  /// Create from Firebase map
  factory VehicleModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);
    
    return VehicleModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      marca: map['marca']?.toString() ?? '',
      modelo: map['modelo']?.toString() ?? '',
      ano: map['ano']?.toInt() ?? 0,
      placa: map['placa']?.toString() ?? '',
      odometroInicial: (map['odometro_inicial'] ?? 0.0).toDouble(),
      combustivel: map['combustivel']?.toInt() ?? 0,
      renavan: map['renavan']?.toString() ?? '',
      chassi: map['chassi']?.toString() ?? '',
      cor: map['cor']?.toString() ?? '',
      vendido: map['vendido'] ?? false,
      valorVenda: (map['valor_venda'] ?? 0.0).toDouble(),
      odometroAtual: (map['odometro_atual'] ?? 0.0).toDouble(),
      foto: map['foto']?.toString(),
    );
  }

  /// Create from Firestore document
  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel.fromFirebaseMap({...data, 'id': doc.id});
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return toFirebaseMap();
  }

  /// Convert to entity
  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      userId: userId ?? '',
      name: '$marca $modelo',
      brand: marca,
      model: modelo,
      year: ano,
      color: cor,
      licensePlate: placa,
      type: VehicleType.car, // Default to car, you may want to map this properly
      supportedFuels: [FuelType.values[combustivel]], // Map from int to FuelType
      currentOdometer: odometroAtual,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: !isDeleted,
      metadata: {
        'renavan': renavan,
        'chassi': chassi,
        'vendido': vendido,
        'valorVenda': valorVenda,
        'odometroInicial': odometroInicial,
        'foto': foto,
      },
    );
  }

  /// Create from entity
  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      createdAtMs: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMs: entity.updatedAt.millisecondsSinceEpoch,
      userId: entity.userId,
      marca: entity.brand,
      modelo: entity.model,
      ano: entity.year,
      placa: entity.licensePlate,
      odometroInicial: entity.metadata['odometroInicial']?.toDouble() ?? 0.0,
      combustivel: entity.supportedFuels.isNotEmpty 
          ? entity.supportedFuels.first.index 
          : 0,
      renavan: entity.metadata['renavan']?.toString() ?? '',
      chassi: entity.metadata['chassi']?.toString() ?? '',
      cor: entity.color,
      vendido: entity.metadata['vendido'] ?? false,
      valorVenda: entity.metadata['valorVenda']?.toDouble() ?? 0.0,
      odometroAtual: entity.currentOdometer,
      foto: entity.metadata['foto']?.toString(),
      isDeleted: !entity.isActive,
    );
  }

  /// copyWith method for immutability
  @override
  VehicleModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? marca,
    String? modelo,
    int? ano,
    String? placa,
    double? odometroInicial,
    int? combustivel,
    String? renavan,
    String? chassi,
    String? cor,
    bool? vendido,
    double? valorVenda,
    double? odometroAtual,
    String? foto,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? this.createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? this.updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? this.lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      odometroInicial: odometroInicial ?? this.odometroInicial,
      combustivel: combustivel ?? this.combustivel,
      renavan: renavan ?? this.renavan,
      chassi: chassi ?? this.chassi,
      cor: cor ?? this.cor,
      vendido: vendido ?? this.vendido,
      valorVenda: valorVenda ?? this.valorVenda,
      odometroAtual: odometroAtual ?? this.odometroAtual,
      foto: foto ?? this.foto,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory VehicleModel.fromMap(Map<String, dynamic> map) => VehicleModel.fromHiveMap(map);
  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel.fromHiveMap(json);

  @override
  String toString() {
    return 'VehicleModel(id: $id, marca: $marca, modelo: $modelo, ano: $ano, placa: $placa)';
  }
}