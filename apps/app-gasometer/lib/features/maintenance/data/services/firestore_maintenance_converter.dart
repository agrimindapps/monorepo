import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';
import '../models/maintenance_model.dart';

/// Service responsible for converting between Firestore documents and MaintenanceEntity
/// Follows SRP by handling only Firestore conversion logic
@lazySingleton
class FirestoreMaintenanceConverter {
  /// Convert Firestore document data to MaintenanceEntity
  MaintenanceEntity documentToEntity(Map<String, dynamic> data, String docId) {
    final dataWithId = {...data, 'id': docId};
    final model = MaintenanceModel.fromFirebaseMap(dataWithId);
    return modelToEntity(model);
  }

  /// Convert multiple Firestore documents to entities
  List<MaintenanceEntity> documentsToEntities(
    List<Map<String, dynamic>> documents,
    List<String> docIds,
  ) {
    if (documents.length != docIds.length) {
      throw ArgumentError('Documents and IDs lists must have same length');
    }

    return List.generate(
      documents.length,
      (index) => documentToEntity(documents[index], docIds[index]),
    );
  }

  /// Convert MaintenanceEntity to Firestore map
  Map<String, dynamic> entityToFirebaseMap(MaintenanceEntity entity) {
    final model = entityToModel(entity);
    return model.toFirebaseMap();
  }

  /// Convert MaintenanceModel to MaintenanceEntity
  MaintenanceEntity modelToEntity(MaintenanceModel model) {
    return MaintenanceEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: _mapStringToMaintenanceType(model.tipo),
      status: model.concluida
          ? MaintenanceStatus.completed
          : MaintenanceStatus.pending,
      title: model.tipo,
      description: model.descricao,
      cost: model.valor,
      serviceDate: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro.toDouble(),
      workshopName: null, // Not available in current model
      workshopPhone: null,
      workshopAddress: null,
      nextServiceDate: model.proximaRevisao != null
          ? DateTime.fromMillisecondsSinceEpoch(model.proximaRevisao!)
          : null,
      nextServiceOdometer: null,
      photosPaths: const [],
      invoicesPaths: const [],
      parts: const {},
      notes: null,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: const {},
    );
  }

  /// Convert MaintenanceEntity to MaintenanceModel
  MaintenanceModel entityToModel(MaintenanceEntity entity) {
    return MaintenanceModel.create(
      id: entity.id,
      userId: entity.userId?.isEmpty == true ? null : entity.userId,
      veiculoId: entity.vehicleId,
      tipo: _mapMaintenanceTypeToString(entity.type),
      descricao: entity.description,
      valor: entity.cost,
      data: entity.serviceDate.millisecondsSinceEpoch,
      odometro: entity.odometer.toInt(),
      proximaRevisao: entity.nextServiceDate?.millisecondsSinceEpoch,
      concluida: entity.status == MaintenanceStatus.completed,
    );
  }

  /// Check if two maintenance records are duplicates
  /// Duplicates are defined as same vehicle, date, and type within 5 minutes
  bool areDuplicates(MaintenanceEntity a, MaintenanceEntity b) {
    if (a.vehicleId != b.vehicleId) return false;
    if (a.type != b.type) return false;

    final timeDiff = a.serviceDate.difference(b.serviceDate).abs();
    return timeDiff.inMinutes <= 5;
  }

  // Private helper methods for type mapping
  MaintenanceType _mapStringToMaintenanceType(String type) {
    switch (type.toLowerCase()) {
      case 'preventiva':
        return MaintenanceType.preventive;
      case 'corretiva':
        return MaintenanceType.corrective;
      case 'revisão':
      case 'revisao':
        return MaintenanceType.inspection;
      case 'emergencial':
        return MaintenanceType.emergency;
      default:
        return MaintenanceType.preventive;
    }
  }

  String _mapMaintenanceTypeToString(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventiva';
      case MaintenanceType.corrective:
        return 'Corretiva';
      case MaintenanceType.inspection:
        return 'Revisão';
      case MaintenanceType.emergency:
        return 'Emergencial';
    }
  }

  /// Get display name for maintenance type
  String getMaintenanceTypeDisplayName(MaintenanceType type) {
    return _mapMaintenanceTypeToString(type);
  }

  /// Parse maintenance type from string
  MaintenanceType parseMaintenanceType(String type) {
    return _mapStringToMaintenanceType(type);
  }
}
