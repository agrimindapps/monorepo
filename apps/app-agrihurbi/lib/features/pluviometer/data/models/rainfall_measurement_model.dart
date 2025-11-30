import 'package:drift/drift.dart';

import '../../../../database/agrihurbi_database.dart';
import '../../domain/entities/rainfall_measurement_entity.dart';

/// Model de dados para medição pluviométrica
///
/// Converte entre RainfallMeasurementEntity (domínio) e RainfallMeasurement (Drift)
class RainfallMeasurementModel extends RainfallMeasurementEntity {
  const RainfallMeasurementModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required super.isActive,
    required super.rainGaugeId,
    required super.measurementDate,
    required super.amount,
    super.observations,
    super.objectId,
  });

  /// Converte de Entity para Model
  factory RainfallMeasurementModel.fromEntity(RainfallMeasurementEntity entity) {
    return RainfallMeasurementModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      rainGaugeId: entity.rainGaugeId,
      measurementDate: entity.measurementDate,
      amount: entity.amount,
      observations: entity.observations,
      objectId: entity.objectId,
    );
  }

  /// Converte de Drift RainfallMeasurement para Model
  factory RainfallMeasurementModel.fromDrift(RainfallMeasurement driftModel) {
    return RainfallMeasurementModel(
      id: driftModel.id,
      createdAt: driftModel.createdAt,
      updatedAt: driftModel.updatedAt,
      isActive: driftModel.isActive,
      rainGaugeId: driftModel.rainGaugeId,
      measurementDate: driftModel.measurementDate,
      amount: driftModel.amount,
      observations: driftModel.observations,
      objectId: driftModel.objectId,
    );
  }

  /// Converte Model para Entity (upcasting)
  RainfallMeasurementEntity toEntity() {
    return RainfallMeasurementEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      rainGaugeId: rainGaugeId,
      measurementDate: measurementDate,
      amount: amount,
      observations: observations,
      objectId: objectId,
    );
  }

  /// Converte para Drift Companion (para insert/update)
  RainfallMeasurementsCompanion toDriftCompanion() {
    return RainfallMeasurementsCompanion.insert(
      id: id,
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      rainGaugeId: rainGaugeId,
      measurementDate: measurementDate,
      amount: amount,
      observations: Value(observations),
      objectId: Value(objectId),
    );
  }

  /// Converte de JSON (Firebase/API) - formato do app antigo
  factory RainfallMeasurementModel.fromJson(Map<String, dynamic> json) {
    return RainfallMeasurementModel(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      isActive: json['active'] as bool? ?? true,
      rainGaugeId: json['fkPluviometro'] as String? ?? '',
      measurementDate: json['dtMedicao'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dtMedicao'] as int)
          : DateTime.now(),
      amount: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      observations: json['observacoes'] as String?,
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
      'fkPluviometro': rainGaugeId,
      'dtMedicao': measurementDate.millisecondsSinceEpoch,
      'quantidade': amount,
      'observacoes': observations,
      'objectId': objectId,
    };
  }
}

/// Extensão para converter listas
extension RainfallMeasurementListExtension on List<RainfallMeasurement> {
  List<RainfallMeasurementEntity> toEntities() {
    return map((driftModel) =>
            RainfallMeasurementModel.fromDrift(driftModel).toEntity())
        .toList();
  }
}
