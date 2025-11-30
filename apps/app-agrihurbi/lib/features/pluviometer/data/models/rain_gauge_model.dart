import 'package:drift/drift.dart';

import '../../../../database/agrihurbi_database.dart';
import '../../domain/entities/rain_gauge_entity.dart';

/// Model de dados para pluviômetro
///
/// Converte entre RainGaugeEntity (domínio) e RainGauge (Drift)
class RainGaugeModel extends RainGaugeEntity {
  const RainGaugeModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required super.isActive,
    required super.description,
    required super.capacity,
    super.longitude,
    super.latitude,
    super.groupId,
    super.objectId,
  });

  /// Converte de Entity para Model
  factory RainGaugeModel.fromEntity(RainGaugeEntity entity) {
    return RainGaugeModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      description: entity.description,
      capacity: entity.capacity,
      longitude: entity.longitude,
      latitude: entity.latitude,
      groupId: entity.groupId,
      objectId: entity.objectId,
    );
  }

  /// Converte de Drift RainGauge para Model
  factory RainGaugeModel.fromDrift(RainGauge driftModel) {
    return RainGaugeModel(
      id: driftModel.id,
      createdAt: driftModel.createdAt,
      updatedAt: driftModel.updatedAt,
      isActive: driftModel.isActive,
      description: driftModel.description,
      capacity: driftModel.capacity,
      longitude: driftModel.longitude,
      latitude: driftModel.latitude,
      groupId: driftModel.groupId,
      objectId: driftModel.objectId,
    );
  }

  /// Converte Model para Entity (upcasting)
  RainGaugeEntity toEntity() {
    return RainGaugeEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      description: description,
      capacity: capacity,
      longitude: longitude,
      latitude: latitude,
      groupId: groupId,
      objectId: objectId,
    );
  }

  /// Converte para Drift Companion (para insert/update)
  RainGaugesCompanion toDriftCompanion() {
    return RainGaugesCompanion.insert(
      id: id,
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      description: description,
      capacity: capacity,
      longitude: Value(longitude),
      latitude: Value(latitude),
      groupId: Value(groupId),
      objectId: Value(objectId),
    );
  }

  /// Converte de JSON (Firebase/API)
  factory RainGaugeModel.fromJson(Map<String, dynamic> json) {
    return RainGaugeModel(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      isActive: json['active'] as bool? ?? true,
      description: json['descricao'] as String? ?? '',
      capacity: json['quantidade'] as String? ?? '',
      longitude: json['longitude'] as String?,
      latitude: json['latitude'] as String?,
      groupId: json['fkGrupo'] as String?,
      objectId: json['objectId'] as String?,
    );
  }

  /// Converte para JSON (Firebase/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'active': isActive,
      'descricao': description,
      'quantidade': capacity,
      'longitude': longitude,
      'latitude': latitude,
      'fkGrupo': groupId,
      'objectId': objectId,
    };
  }
}

/// Extensão para converter listas
extension RainGaugeListExtension on List<RainGauge> {
  List<RainGaugeEntity> toEntities() {
    return map((driftModel) => RainGaugeModel.fromDrift(driftModel).toEntity())
        .toList();
  }
}
