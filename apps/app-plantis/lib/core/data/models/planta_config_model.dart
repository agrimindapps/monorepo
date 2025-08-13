import 'package:hive/hive.dart';
import 'base_sync_model.dart';

part 'planta_config_model.g.dart';

/// PlantaConfig model with Firebase sync support
/// TypeId: 4 - Sequential numbering
@HiveType(typeId: 4)
class PlantaConfigModel extends BaseSyncModel {
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

  // PlantaConfig specific fields
  @HiveField(10) final String plantaId;
  @HiveField(11) final bool aguaAtiva;
  @HiveField(12) final int intervaloRegaDias;
  @HiveField(13) final bool aduboAtivo;
  @HiveField(14) final int intervaloAdubacaoDias;
  @HiveField(15) final bool banhoSolAtivo;
  @HiveField(16) final int intervaloBanhoSolDias;
  @HiveField(17) final bool inspecaoPragasAtiva;
  @HiveField(18) final int intervaloInspecaoPragasDias;
  @HiveField(19) final bool podaAtiva;
  @HiveField(20) final int intervaloPodaDias;
  @HiveField(21) final bool replantarAtivo;
  @HiveField(22) final int intervaloReplantarDias;

  const PlantaConfigModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'plantis',
    required this.plantaId,
    this.aguaAtiva = true,
    this.intervaloRegaDias = 1,
    this.aduboAtivo = true,
    this.intervaloAdubacaoDias = 7,
    this.banhoSolAtivo = true,
    this.intervaloBanhoSolDias = 1,
    this.inspecaoPragasAtiva = true,
    this.intervaloInspecaoPragasDias = 7,
    this.podaAtiva = true,
    this.intervaloPodaDias = 30,
    this.replantarAtivo = true,
    this.intervaloReplantarDias = 180,
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
  String get collectionName => 'planta_configs';

  /// Factory constructor for creating new planta config
  factory PlantaConfigModel.create({
    String? id,
    String? userId,
    required String plantaId,
    bool aguaAtiva = true,
    int intervaloRegaDias = 1,
    bool aduboAtivo = true,
    int intervaloAdubacaoDias = 7,
    bool banhoSolAtivo = true,
    int intervaloBanhoSolDias = 1,
    bool inspecaoPragasAtiva = true,
    int intervaloInspecaoPragasDias = 7,
    bool podaAtiva = true,
    int intervaloPodaDias = 30,
    bool replantarAtivo = true,
    int intervaloReplantarDias = 180,
  }) {
    final now = DateTime.now();
    final configId = id ?? now.millisecondsSinceEpoch.toString();
    
    return PlantaConfigModel(
      id: configId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      plantaId: plantaId,
      aguaAtiva: aguaAtiva,
      intervaloRegaDias: intervaloRegaDias,
      aduboAtivo: aduboAtivo,
      intervaloAdubacaoDias: intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo,
      intervaloBanhoSolDias: intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva,
      intervaloPodaDias: intervaloPodaDias,
      replantarAtivo: replantarAtivo,
      intervaloReplantarDias: intervaloReplantarDias,
    );
  }

  /// Create from Hive map
  factory PlantaConfigModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);
    
    return PlantaConfigModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantaId: map['plantaId']?.toString() ?? '',
      aguaAtiva: map['aguaAtiva'] ?? true,
      intervaloRegaDias: map['intervaloRegaDias']?.toInt() ?? 1,
      aduboAtivo: map['aduboAtivo'] ?? true,
      intervaloAdubacaoDias: map['intervaloAdubacaoDias']?.toInt() ?? 7,
      banhoSolAtivo: map['banhoSolAtivo'] ?? true,
      intervaloBanhoSolDias: map['intervaloBanhoSolDias']?.toInt() ?? 1,
      inspecaoPragasAtiva: map['inspecaoPragasAtiva'] ?? true,
      intervaloInspecaoPragasDias: map['intervaloInspecaoPragasDias']?.toInt() ?? 7,
      podaAtiva: map['podaAtiva'] ?? true,
      intervaloPodaDias: map['intervaloPodaDias']?.toInt() ?? 30,
      replantarAtivo: map['replantarAtivo'] ?? true,
      intervaloReplantarDias: map['intervaloReplantarDias']?.toInt() ?? 180,
    );
  }

  /// Convert to Hive map
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({
        'plantaId': plantaId,
        'aguaAtiva': aguaAtiva,
        'intervaloRegaDias': intervaloRegaDias,
        'aduboAtivo': aduboAtivo,
        'intervaloAdubacaoDias': intervaloAdubacaoDias,
        'banhoSolAtivo': banhoSolAtivo,
        'intervaloBanhoSolDias': intervaloBanhoSolDias,
        'inspecaoPragasAtiva': inspecaoPragasAtiva,
        'intervaloInspecaoPragasDias': intervaloInspecaoPragasDias,
        'podaAtiva': podaAtiva,
        'intervaloPodaDias': intervaloPodaDias,
        'replantarAtivo': replantarAtivo,
        'intervaloReplantarDias': intervaloReplantarDias,
      });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'planta_id': plantaId,
      'agua_ativa': aguaAtiva,
      'intervalo_rega_dias': intervaloRegaDias,
      'adubo_ativo': aduboAtivo,
      'intervalo_adubacao_dias': intervaloAdubacaoDias,
      'banho_sol_ativo': banhoSolAtivo,
      'intervalo_banho_sol_dias': intervaloBanhoSolDias,
      'inspecao_pragas_ativa': inspecaoPragasAtiva,
      'intervalo_inspecao_pragas_dias': intervaloInspecaoPragasDias,
      'poda_ativa': podaAtiva,
      'intervalo_poda_dias': intervaloPodaDias,
      'replantar_ativo': replantarAtivo,
      'intervalo_replantar_dias': intervaloReplantarDias,
    };
  }

  /// Create from Firebase map
  factory PlantaConfigModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);
    
    return PlantaConfigModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantaId: map['planta_id']?.toString() ?? '',
      aguaAtiva: map['agua_ativa'] ?? true,
      intervaloRegaDias: map['intervalo_rega_dias']?.toInt() ?? 1,
      aduboAtivo: map['adubo_ativo'] ?? true,
      intervaloAdubacaoDias: map['intervalo_adubacao_dias']?.toInt() ?? 7,
      banhoSolAtivo: map['banho_sol_ativo'] ?? true,
      intervaloBanhoSolDias: map['intervalo_banho_sol_dias']?.toInt() ?? 1,
      inspecaoPragasAtiva: map['inspecao_pragas_ativa'] ?? true,
      intervaloInspecaoPragasDias: map['intervalo_inspecao_pragas_dias']?.toInt() ?? 7,
      podaAtiva: map['poda_ativa'] ?? true,
      intervaloPodaDias: map['intervalo_poda_dias']?.toInt() ?? 30,
      replantarAtivo: map['replantar_ativo'] ?? true,
      intervaloReplantarDias: map['intervalo_replantar_dias']?.toInt() ?? 180,
    );
  }

  /// copyWith method for immutability
  @override
  PlantaConfigModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? plantaId,
    bool? aguaAtiva,
    int? intervaloRegaDias,
    bool? aduboAtivo,
    int? intervaloAdubacaoDias,
    bool? banhoSolAtivo,
    int? intervaloBanhoSolDias,
    bool? inspecaoPragasAtiva,
    int? intervaloInspecaoPragasDias,
    bool? podaAtiva,
    int? intervaloPodaDias,
    bool? replantarAtivo,
    int? intervaloReplantarDias,
  }) {
    return PlantaConfigModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? this.createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? this.updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? this.lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      plantaId: plantaId ?? this.plantaId,
      aguaAtiva: aguaAtiva ?? this.aguaAtiva,
      intervaloRegaDias: intervaloRegaDias ?? this.intervaloRegaDias,
      aduboAtivo: aduboAtivo ?? this.aduboAtivo,
      intervaloAdubacaoDias: intervaloAdubacaoDias ?? this.intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo ?? this.banhoSolAtivo,
      intervaloBanhoSolDias: intervaloBanhoSolDias ?? this.intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva ?? this.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias ?? this.intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva ?? this.podaAtiva,
      intervaloPodaDias: intervaloPodaDias ?? this.intervaloPodaDias,
      replantarAtivo: replantarAtivo ?? this.replantarAtivo,
      intervaloReplantarDias: intervaloReplantarDias ?? this.intervaloReplantarDias,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();
  factory PlantaConfigModel.fromMap(Map<String, dynamic> map) => PlantaConfigModel.fromHiveMap(map);
  factory PlantaConfigModel.fromJson(Map<String, dynamic> json) => PlantaConfigModel.fromHiveMap(json);

  /// Obtém o intervalo em dias para um tipo de cuidado específico
  int getIntervalForCareType(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return intervaloRegaDias;
      case 'adubo':
        return intervaloAdubacaoDias;
      case 'banho_sol':
        return intervaloBanhoSolDias;
      case 'inspecao_pragas':
        return intervaloInspecaoPragasDias;
      case 'poda':
        return intervaloPodaDias;
      case 'replantar':
        return intervaloReplantarDias;
      default:
        return 1;
    }
  }

  /// Verifica se um tipo de cuidado está ativo
  bool isCareTypeActive(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return aguaAtiva;
      case 'adubo':
        return aduboAtivo;
      case 'banho_sol':
        return banhoSolAtivo;
      case 'inspecao_pragas':
        return inspecaoPragasAtiva;
      case 'poda':
        return podaAtiva;
      case 'replantar':
        return replantarAtivo;
      default:
        return false;
    }
  }

  /// Lista todos os tipos de cuidado ativos
  List<String> get activeCareTypes {
    final active = <String>[];
    if (aguaAtiva) active.add('agua');
    if (aduboAtivo) active.add('adubo');
    if (banhoSolAtivo) active.add('banho_sol');
    if (inspecaoPragasAtiva) active.add('inspecao_pragas');
    if (podaAtiva) active.add('poda');
    if (replantarAtivo) active.add('replantar');
    return active;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantaConfigModel &&
        other.id == id &&
        other.plantaId == plantaId &&
        other.aguaAtiva == aguaAtiva &&
        other.intervaloRegaDias == intervaloRegaDias &&
        other.aduboAtivo == aduboAtivo &&
        other.intervaloAdubacaoDias == intervaloAdubacaoDias &&
        other.banhoSolAtivo == banhoSolAtivo &&
        other.intervaloBanhoSolDias == intervaloBanhoSolDias &&
        other.inspecaoPragasAtiva == inspecaoPragasAtiva &&
        other.intervaloInspecaoPragasDias == intervaloInspecaoPragasDias &&
        other.podaAtiva == podaAtiva &&
        other.intervaloPodaDias == intervaloPodaDias &&
        other.replantarAtivo == replantarAtivo &&
        other.intervaloReplantarDias == intervaloReplantarDias;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      plantaId,
      aguaAtiva,
      intervaloRegaDias,
      aduboAtivo,
      intervaloAdubacaoDias,
      banhoSolAtivo,
      intervaloBanhoSolDias,
      inspecaoPragasAtiva,
      intervaloInspecaoPragasDias,
      podaAtiva,
      intervaloPodaDias,
      replantarAtivo,
      intervaloReplantarDias,
    );
  }

  @override
  String toString() {
    return 'PlantaConfigModel(id: $id, plantaId: $plantaId, aguaAtiva: $aguaAtiva, intervaloRegaDias: $intervaloRegaDias)';
  }
}