// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part 'planta_config_model.g.dart';

@HiveType(typeId: 85)
class PlantaConfigModel extends BaseModel {
  @HiveField(7)
  String plantaId;

  @HiveField(8)
  bool aguaAtiva;

  @HiveField(9)
  int intervaloRegaDias;

  @HiveField(10)
  bool aduboAtivo;

  @HiveField(11)
  int intervaloAdubacaoDias;

  @HiveField(12)
  bool banhoSolAtivo;

  @HiveField(13)
  int intervaloBanhoSolDias;

  @HiveField(14)
  bool inspecaoPragasAtiva;

  @HiveField(15)
  int intervaloInspecaoPragasDias;

  @HiveField(16)
  bool podaAtiva;

  @HiveField(17)
  int intervaloPodaDias;

  @HiveField(18)
  bool replantarAtivo;

  @HiveField(19)
  int intervaloReplantarDias;

  PlantaConfigModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
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
  });

  @override
  PlantaConfigModel copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plantaId: plantaId ?? this.plantaId,
      aguaAtiva: aguaAtiva ?? this.aguaAtiva,
      intervaloRegaDias: intervaloRegaDias ?? this.intervaloRegaDias,
      aduboAtivo: aduboAtivo ?? this.aduboAtivo,
      intervaloAdubacaoDias:
          intervaloAdubacaoDias ?? this.intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo ?? this.banhoSolAtivo,
      intervaloBanhoSolDias:
          intervaloBanhoSolDias ?? this.intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva ?? this.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias:
          intervaloInspecaoPragasDias ?? this.intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva ?? this.podaAtiva,
      intervaloPodaDias: intervaloPodaDias ?? this.intervaloPodaDias,
      replantarAtivo: replantarAtivo ?? this.replantarAtivo,
      intervaloReplantarDias:
          intervaloReplantarDias ?? this.intervaloReplantarDias,
    )..updateBase(
        isDeleted: isDeleted,
        needsSync: needsSync,
        lastSyncAt: lastSyncAt,
        version: version,
      );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
    };
  }

  static PlantaConfigModel fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return PlantaConfigModel(
      id: json['id'] ?? '',
      createdAt: _extractTimestamp(json['createdAt']) ?? now,
      updatedAt: _extractTimestamp(json['updatedAt']) ?? now,
      plantaId: json['plantaId'] as String,
      aguaAtiva: json['aguaAtiva'] as bool? ?? true,
      intervaloRegaDias: json['intervaloRegaDias'] as int? ?? 1,
      aduboAtivo: json['aduboAtivo'] as bool? ?? true,
      intervaloAdubacaoDias: json['intervaloAdubacaoDias'] as int? ?? 7,
      banhoSolAtivo: json['banhoSolAtivo'] as bool? ?? true,
      intervaloBanhoSolDias: json['intervaloBanhoSolDias'] as int? ?? 1,
      inspecaoPragasAtiva: json['inspecaoPragasAtiva'] as bool? ?? true,
      intervaloInspecaoPragasDias:
          json['intervaloInspecaoPragasDias'] as int? ?? 7,
      podaAtiva: json['podaAtiva'] as bool? ?? true,
      intervaloPodaDias: json['intervaloPodaDias'] as int? ?? 30,
      replantarAtivo: json['replantarAtivo'] as bool? ?? true,
      intervaloReplantarDias: json['intervaloReplantarDias'] as int? ?? 180,
    );
  }

  /// Converte Timestamp do Firestore ou int para int
  static int? _extractTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }

  @override
  String toString() {
    return 'PlantaConfigModel(id: $id, plantaId: $plantaId, aguaAtiva: $aguaAtiva, intervaloRegaDias: $intervaloRegaDias)';
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
}
