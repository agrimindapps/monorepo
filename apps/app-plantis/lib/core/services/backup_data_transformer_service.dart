import 'package:flutter/foundation.dart';

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/entities/space.dart';
import '../../features/tasks/domain/entities/task.dart';

/// Service responsável por transformações de dados em operações de backup
/// Implementa Single Responsibility Principle - apenas transformação de dados
class BackupDataTransformerService {
  const BackupDataTransformerService();

  /// Converte Plant para JSON para backup
  Map<String, dynamic> plantToJson(Plant plant) {
    try {
      return {
        'id': plant.id,
        'name': plant.name,
        'species': plant.species,
        'spaceId': plant.spaceId,
        'imageBase64': plant.imageBase64,
        'imageUrls': plant.imageUrls,
        'plantingDate': plant.plantingDate?.toIso8601String(),
        'notes': plant.notes,
        'isFavorited': plant.isFavorited,
        'userId': plant.userId,
        'createdAt': plant.createdAt?.toIso8601String(),
        'updatedAt': plant.updatedAt?.toIso8601String(),
        '_backup_version': '1.0',
        '_backup_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao converter Plant para JSON: $e');
      rethrow;
    }
  }

  /// Converte Task para JSON para backup
  Map<String, dynamic> taskToJson(Task task) {
    try {
      return {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'plantId': task.plantId,
        'userId': task.userId,
        'type': task.type.name,
        'priority': task.priority.name,
        'status': task.status.name,
        'dueDate': task.dueDate.toIso8601String(),
        'completedAt': task.completedAt?.toIso8601String(),
        'completionNotes': task.completionNotes,
        'isRecurring': task.isRecurring,
        'recurringIntervalDays': task.recurringIntervalDays,
        'nextDueDate': task.nextDueDate?.toIso8601String(),
        'createdAt': task.createdAt?.toIso8601String(),
        'updatedAt': task.updatedAt?.toIso8601String(),
        '_backup_version': '1.0',
        '_backup_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao converter Task para JSON: $e');
      rethrow;
    }
  }

  /// Converte Space para JSON para backup
  Map<String, dynamic> spaceToJson(Space space) {
    try {
      return {
        'id': space.id,
        'name': space.name,
        'description': space.description,
        'lightCondition': space.lightCondition,
        'humidity': space.humidity,
        'averageTemperature': space.averageTemperature,
        'userId': space.userId,
        'createdAt': space.createdAt?.toIso8601String(),
        'updatedAt': space.updatedAt?.toIso8601String(),
        '_backup_version': '1.0',
        '_backup_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao converter Space para JSON: $e');
      rethrow;
    }
  }

  Plant createPlantFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      return Plant(
        id: data['id'] as String,
        name: data['name'] as String,
        species: data['species'] as String?,
        spaceId: data['spaceId'] as String?,
        imageBase64: data['imageBase64'] as String?,
        imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
        plantingDate: _parseOptionalDateTime(data['plantingDate']),
        notes: data['notes'] as String?,
        isFavorited: data['isFavorited'] as bool? ?? false,
        userId: userId,
        createdAt: _parseDateTime(data['createdAt']),
        updatedAt: _parseOptionalDateTime(data['updatedAt']),
      );
    } catch (e) {
      throw TransformException(
        'Erro ao criar Plant dos dados de backup: ${e.toString()}',
      );
    }
  }

  Task createTaskFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      return Task(
        id: data['id'] as String,
        title: data['title'] as String,
        description: data['description'] as String?,
        plantId: data['plantId'] as String,
        userId: userId,
        type: _parseTaskType(data['type'] as String?),
        priority: _parseTaskPriority(data['priority'] as String?),
        status: _parseTaskStatus(data['status'] as String?),
        dueDate: _parseDateTime(data['dueDate']) ?? DateTime.now(),
        completedAt: _parseOptionalDateTime(data['completedAt']),
        completionNotes: data['completionNotes'] as String?,
        isRecurring: data['isRecurring'] as bool? ?? false,
        recurringIntervalDays: data['recurringIntervalDays'] as int?,
        nextDueDate: _parseOptionalDateTime(data['nextDueDate']),
        createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
        updatedAt: _parseOptionalDateTime(data['updatedAt']),
      );
    } catch (e) {
      throw TransformException(
        'Erro ao criar Task dos dados de backup: ${e.toString()}',
      );
    }
  }

  Space createSpaceFromBackupData(Map<String, dynamic> data, String userId) {
    try {
      return Space(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String?,
        lightCondition: data['lightCondition'] as String?,
        humidity: (data['humidity'] as num?)?.toDouble(),
        averageTemperature: (data['averageTemperature'] as num?)?.toDouble(),
        userId: userId,
        createdAt: _parseDateTime(data['createdAt']),
        updatedAt: _parseOptionalDateTime(data['updatedAt']),
      );
    } catch (e) {
      throw TransformException(
        'Erro ao criar Space dos dados de backup: ${e.toString()}',
      );
    }
  }

  /// Merge dados de Plant existente com dados do backup
  Plant mergePlantData(Plant existing, Plant backup) {
    return existing.copyWith(
      name: backup.name,
      species: backup.species,
      spaceId: backup.spaceId,
      imageBase64: backup.imageBase64,
      imageUrls:
          backup.imageUrls.isNotEmpty ? backup.imageUrls : existing.imageUrls,
      plantingDate: backup.plantingDate ?? existing.plantingDate,
      notes: backup.notes ?? existing.notes,
      isFavorited: backup.isFavorited,
      updatedAt: DateTime.now(),
    );
  }

  /// Merge dados de Task existente com dados do backup
  Task mergeTaskData(Task existing, Task backup) {
    return existing.copyWith(updatedAt: DateTime.now());
  }

  /// Merge dados de Space existente com dados do backup
  Space mergeSpaceData(Space existing, Space backup) {
    return existing.copyWith(
      name: backup.name,
      description: backup.description,
      lightCondition: backup.lightCondition,
      humidity: backup.humidity,
      averageTemperature: backup.averageTemperature,
      updatedAt: DateTime.now(),
    );
  }

  /// Parse DateTime obrigatório
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('❌ Erro ao parsear DateTime: $value');
        return null;
      }
    }
    return null;
  }

  /// Parse DateTime opcional
  DateTime? _parseOptionalDateTime(dynamic value) {
    return _parseDateTime(value);
  }

  /// Parse TaskType do backup
  TaskType _parseTaskType(String? value) {
    if (value == null) return TaskType.custom;

    try {
      return TaskType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => TaskType.custom,
      );
    } catch (e) {
      debugPrint('❌ TaskType desconhecido: $value, usando custom');
      return TaskType.custom;
    }
  }

  /// Parse TaskPriority do backup
  TaskPriority _parseTaskPriority(String? value) {
    if (value == null) return TaskPriority.medium;

    try {
      return TaskPriority.values.firstWhere(
        (priority) => priority.name == value,
        orElse: () => TaskPriority.medium,
      );
    } catch (e) {
      debugPrint('❌ TaskPriority desconhecido: $value, usando medium');
      return TaskPriority.medium;
    }
  }

  /// Parse TaskStatus do backup
  TaskStatus _parseTaskStatus(String? value) {
    if (value == null) return TaskStatus.pending;

    try {
      return TaskStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => TaskStatus.pending,
      );
    } catch (e) {
      debugPrint('❌ TaskStatus desconhecido: $value, usando pending');
      return TaskStatus.pending;
    }
  }
}

/// Exceção específica para erros de transformação de dados
class TransformException implements Exception {
  final String message;

  const TransformException(this.message);

  @override
  String toString() => 'TransformException: $message';
}
