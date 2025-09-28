import 'package:flutter/foundation.dart';

import '../../domain/entities/maintenance_entity.dart';
import '../models/maintenance_model.dart';

/// Dedicated mapper for converting between MaintenanceModel and MaintenanceEntity
/// Handles all field compatibility and data transformation
abstract class MaintenanceMapper {
  
  /// Convert MaintenanceModel to MaintenanceEntity
  static MaintenanceEntity modelToEntity(MaintenanceModel model) {
    return MaintenanceEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: _mapStringToMaintenanceType(model.tipo),
      status: _mapToMaintenanceStatus(model.concluida),
      title: _generateTitleFromTypeAndDescription(model.tipo, model.descricao),
      description: model.descricao,
      cost: model.valor,
      serviceDate: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro.toDouble(),
      // Workshop info - not available in current model, but prepared for future
      workshopName: null,
      workshopPhone: null,
      workshopAddress: null,
      // Next service info
      nextServiceDate: model.proximaRevisao != null 
          ? DateTime.fromMillisecondsSinceEpoch(model.proximaRevisao!) 
          : null,
      nextServiceOdometer: null, // Not available in current model
      // Attachments - not available in current model
      photosPaths: const [],
      invoicesPaths: const [],
      parts: const {},
      notes: null, // Could store additional info from description if needed
      // System metadata
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: _buildMetadata(model),
    );
  }

  /// Convert MaintenanceEntity to MaintenanceModel
  static MaintenanceModel entityToModel(MaintenanceEntity entity) {
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

  /// Convert list of models to entities
  static List<MaintenanceEntity> modelListToEntityList(List<MaintenanceModel> models) {
    return models.map((model) => modelToEntity(model)).toList();
  }

  /// Convert list of entities to models
  static List<MaintenanceModel> entityListToModelList(List<MaintenanceEntity> entities) {
    return entities.map((entity) => entityToModel(entity)).toList();
  }

  /// Update model with entity data (for updates)
  static MaintenanceModel updateModelFromEntity(
    MaintenanceModel existingModel,
    MaintenanceEntity updatedEntity,
  ) {
    return existingModel.copyWith(
      veiculoId: updatedEntity.vehicleId,
      tipo: _mapMaintenanceTypeToString(updatedEntity.type),
      descricao: updatedEntity.description,
      valor: updatedEntity.cost,
      data: updatedEntity.serviceDate.millisecondsSinceEpoch,
      odometro: updatedEntity.odometer.toInt(),
      proximaRevisao: updatedEntity.nextServiceDate?.millisecondsSinceEpoch,
      concluida: updatedEntity.status == MaintenanceStatus.completed,
      updatedAt: DateTime.now(),
      isDirty: true,
    );
  }

  // Private helper methods

  /// Map string type to MaintenanceType enum
  static MaintenanceType _mapStringToMaintenanceType(String type) {
    switch (type.toLowerCase().trim()) {
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
        // Default to preventive for unknown types
        return MaintenanceType.preventive;
    }
  }

  /// Map MaintenanceType enum to string
  static String _mapMaintenanceTypeToString(MaintenanceType type) {
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

  /// Map boolean completion status to MaintenanceStatus enum
  static MaintenanceStatus _mapToMaintenanceStatus(bool concluida) {
    return concluida ? MaintenanceStatus.completed : MaintenanceStatus.pending;
  }

  /// Generate a meaningful title from type and description
  static String _generateTitleFromTypeAndDescription(String tipo, String descricao) {
    // If description is meaningful, use it
    if (descricao.trim().isNotEmpty && descricao.trim().length > 3) {
      // Limit title length and ensure it's meaningful
      String title = descricao.trim();
      if (title.length > 50) {
        title = '${title.substring(0, 47)}...';
      }
      return title;
    }
    
    // Otherwise use type as title
    return tipo.trim().isNotEmpty ? tipo : 'Manutenção';
  }

  /// Build metadata for the entity from model information
  static Map<String, dynamic> _buildMetadata(MaintenanceModel model) {
    return {
      'source': 'model_conversion',
      'originalFields': {
        'veiculoId': model.veiculoId,
        'tipo': model.tipo,
        'valor': model.valor,
        'data': model.data,
        'odometro': model.odometro,
        'concluida': model.concluida,
      },
      'syncInfo': {
        'isDirty': model.isDirty,
        'isDeleted': model.isDeleted,
        'version': model.version,
        'lastSyncAt': model.lastSyncAt?.millisecondsSinceEpoch,
      },
      'conversionTimestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Validate that a model can be converted to entity
  static bool canConvertModelToEntity(MaintenanceModel model) {
    return model.id.isNotEmpty &&
           model.veiculoId.isNotEmpty &&
           model.tipo.isNotEmpty &&
           model.data > 0 &&
           model.valor >= 0;
  }

  /// Validate that an entity can be converted to model
  static bool canConvertEntityToModel(MaintenanceEntity entity) {
    return entity.id.isNotEmpty &&
           entity.vehicleId.isNotEmpty &&
           entity.description.isNotEmpty &&
           entity.cost >= 0;
  }

  /// Get conversion errors for model to entity
  static List<String> getModelToEntityErrors(MaintenanceModel model) {
    final List<String> errors = [];
    
    if (model.id.isEmpty) {
      errors.add('ID é obrigatório');
    }
    if (model.veiculoId.isEmpty) {
      errors.add('ID do veículo é obrigatório');
    }
    if (model.tipo.isEmpty) {
      errors.add('Tipo de manutenção é obrigatório');
    }
    if (model.data <= 0) {
      errors.add('Data de serviço inválida');
    }
    if (model.valor < 0) {
      errors.add('Valor não pode ser negativo');
    }
    if (model.odometro < 0) {
      errors.add('Odômetro não pode ser negativo');
    }
    
    return errors;
  }

  /// Get conversion errors for entity to model
  static List<String> getEntityToModelErrors(MaintenanceEntity entity) {
    final List<String> errors = [];
    
    if (entity.id.isEmpty) {
      errors.add('ID é obrigatório');
    }
    if (entity.vehicleId.isEmpty) {
      errors.add('ID do veículo é obrigatório');
    }
    if (entity.description.isEmpty) {
      errors.add('Descrição é obrigatória');
    }
    if (entity.cost < 0) {
      errors.add('Custo não pode ser negativo');
    }
    if (entity.odometer < 0) {
      errors.add('Odômetro não pode ser negativo');
    }
    
    return errors;
  }

  /// Safe conversion with error handling
  static MaintenanceEntity? safeModelToEntity(MaintenanceModel model) {
    try {
      if (!canConvertModelToEntity(model)) {
        return null;
      }
      return modelToEntity(model);
    } catch (e) {
      // Log error in production
      if (kDebugMode) {
        print('Error converting model to entity: $e');
      }
      return null;
    }
  }

  /// Safe conversion with error handling
  static MaintenanceModel? safeEntityToModel(MaintenanceEntity entity) {
    try {
      if (!canConvertEntityToModel(entity)) {
        return null;
      }
      return entityToModel(entity);
    } catch (e) {
      // Log error in production
      if (kDebugMode) {
        print('Error converting entity to model: $e');
      }
      return null;
    }
  }
}