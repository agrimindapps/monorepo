import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/models/backup_model.dart';

/// Service responsável pela validação de integridade de backups
/// Implementa Single Responsibility Principle - apenas validação
class BackupValidationService {
  const BackupValidationService();

  /// Valida a integridade completa de um backup
  Future<Either<Failure, ValidationResult>> validateBackupIntegrity(
    BackupModel backup,
  ) async {
    try {
      debugPrint('🔍 Validando integridade do backup...');

      final validationErrors = <String>[];
      final validationWarnings = <String>[];
      final structureValidation = _validateBackupStructure(backup);
      structureValidation.fold(
        (error) => validationErrors.add(error),
        (_) => <String, dynamic>{},
      );
      final compatibilityValidation = _validateCompatibility(backup);
      compatibilityValidation.fold(
        (error) => validationErrors.add(error),
        (_) => <String, dynamic>{},
      );
      final metadataValidation = _validateMetadata(backup);
      metadataValidation.fold(
        (error) => validationErrors.add(error),
        (_) => <String, dynamic>{},
      );
      final plantsValidation = await _validatePlantsData(backup.data.plants);
      plantsValidation.fold(
        (error) => validationErrors.add(error),
        (warnings) => validationWarnings.addAll(warnings),
      );
      final tasksValidation = await _validateTasksData(backup.data.tasks);
      tasksValidation.fold(
        (error) => validationErrors.add(error),
        (warnings) => validationWarnings.addAll(warnings),
      );
      final spacesValidation = await _validateSpacesData(backup.data.spaces);
      spacesValidation.fold(
        (error) => validationErrors.add(error),
        (warnings) => validationWarnings.addAll(warnings),
      );
      final settingsValidation = _validateSettingsData(backup.data.settings);
      settingsValidation.fold(
        (error) => validationErrors.add(error),
        (warnings) => validationWarnings.addAll(warnings),
      );
      if (validationErrors.isNotEmpty) {
        return Left(
          ValidationFailure(
            'Backup possui erros críticos: ${validationErrors.join('; ')}',
          ),
        );
      }

      return Right(
        ValidationResult(
          isValid: true,
          errors: validationErrors,
          warnings: validationWarnings,
          validatedItemsCount: _countValidatedItems(backup),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro durante validação: $e');
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }

  /// Validação rápida apenas da estrutura básica
  Either<String, void> validateBasicStructure(BackupModel backup) {
    return _validateBackupStructure(backup);
  }

  /// Validação de compatibilidade de versão
  Either<String, void> validateCompatibility(BackupModel backup) {
    return _validateCompatibility(backup);
  }

  /// Valida estrutura básica do backup
  Either<String, void> _validateBackupStructure(BackupModel backup) {
    if (backup.version.isEmpty) {
      return const Left('Backup não possui versão definida');
    }

    if (backup.userId.isEmpty) {
      return const Left('Backup não possui ID de usuário');
    }

    if (backup.data.plants.isEmpty &&
        backup.data.tasks.isEmpty &&
        backup.data.spaces.isEmpty) {
      return const Left('Backup não contém dados');
    }

    return const Right(null);
  }

  /// Valida compatibilidade do backup
  Either<String, void> _validateCompatibility(BackupModel backup) {
    if (!backup.isCompatible) {
      return const Left('Backup incompatível com a versão atual do app');
    }
    return const Right(null);
  }

  /// Valida metadados do backup
  Either<String, void> _validateMetadata(BackupModel backup) {
    final metadata = backup.metadata;

    if (metadata.plantsCount < 0 ||
        metadata.tasksCount < 0 ||
        metadata.spacesCount < 0) {
      return const Left('Metadados possuem valores inválidos');
    }
    if (metadata.plantsCount != backup.data.plants.length) {
      return Left(
        'Inconsistência nos metadados: esperado ${metadata.plantsCount} plantas, '
        'encontrado ${backup.data.plants.length}',
      );
    }

    if (metadata.tasksCount != backup.data.tasks.length) {
      return Left(
        'Inconsistência nos metadados: esperado ${metadata.tasksCount} tarefas, '
        'encontrado ${backup.data.tasks.length}',
      );
    }

    if (metadata.spacesCount != backup.data.spaces.length) {
      return Left(
        'Inconsistência nos metadados: esperado ${metadata.spacesCount} espaços, '
        'encontrado ${backup.data.spaces.length}',
      );
    }

    return const Right(null);
  }

  /// Valida dados de plantas
  Future<Either<String, List<String>>> _validatePlantsData(
    List<Map<String, dynamic>> plantsData,
  ) async {
    final warnings = <String>[];

    for (int i = 0; i < plantsData.length; i++) {
      final plant = plantsData[i];
      if (!plant.containsKey('id') || plant['id'].toString().isEmpty) {
        return Left('Planta ${i + 1} não possui ID');
      }

      if (!plant.containsKey('name') || plant['name'].toString().isEmpty) {
        return Left('Planta ${i + 1} não possui nome');
      }

      if (!plant.containsKey('userId') || plant['userId'].toString().isEmpty) {
        return Left('Planta ${i + 1} não possui ID de usuário');
      }
      if ((!plant.containsKey('imageUrls') ||
              (plant['imageUrls'] as List?)?.isEmpty == true) &&
          (!plant.containsKey('imageBase64') ||
              plant['imageBase64'].toString().isEmpty)) {
        warnings.add('Planta "${plant['name']}" não possui imagem');
      }

      if (!plant.containsKey('species') ||
          plant['species'].toString().isEmpty) {
        warnings.add('Planta "${plant['name']}" não possui espécie informada');
      }
      if (plant.containsKey('plantingDate')) {
        if (!_isValidDate(plant['plantingDate'])) {
          return Left('Planta ${i + 1} possui data de plantio inválida');
        }
      }
    }

    return Right(warnings);
  }

  /// Valida dados de tarefas
  Future<Either<String, List<String>>> _validateTasksData(
    List<Map<String, dynamic>> tasksData,
  ) async {
    final warnings = <String>[];

    for (int i = 0; i < tasksData.length; i++) {
      final task = tasksData[i];
      if (!task.containsKey('id') || task['id'].toString().isEmpty) {
        return Left('Tarefa ${i + 1} não possui ID');
      }

      if (!task.containsKey('name') || task['name'].toString().isEmpty) {
        return Left('Tarefa ${i + 1} não possui nome');
      }

      if (!task.containsKey('plantId') || task['plantId'].toString().isEmpty) {
        return Left('Tarefa ${i + 1} não está associada a uma planta');
      }

      if (!task.containsKey('userId') || task['userId'].toString().isEmpty) {
        return Left('Tarefa ${i + 1} não possui ID de usuário');
      }
      if (!task.containsKey('description') ||
          task['description'].toString().isEmpty) {
        warnings.add('Tarefa "${task['name']}" não possui descrição');
      }
      if (task.containsKey('dueDate')) {
        if (!_isValidDate(task['dueDate'])) {
          return Left('Tarefa ${i + 1} possui data de vencimento inválida');
        }
      }

      if (task.containsKey('completedAt')) {
        if (!_isValidDate(task['completedAt'])) {
          return Left('Tarefa ${i + 1} possui data de conclusão inválida');
        }
      }
    }

    return Right(warnings);
  }

  /// Valida dados de espaços
  Future<Either<String, List<String>>> _validateSpacesData(
    List<Map<String, dynamic>> spacesData,
  ) async {
    final warnings = <String>[];

    for (int i = 0; i < spacesData.length; i++) {
      final space = spacesData[i];
      if (!space.containsKey('id') || space['id'].toString().isEmpty) {
        return Left('Espaço ${i + 1} não possui ID');
      }

      if (!space.containsKey('name') || space['name'].toString().isEmpty) {
        return Left('Espaço ${i + 1} não possui nome');
      }

      if (!space.containsKey('userId') || space['userId'].toString().isEmpty) {
        return Left('Espaço ${i + 1} não possui ID de usuário');
      }
      if (!space.containsKey('description') ||
          space['description'].toString().isEmpty) {
        warnings.add('Espaço "${space['name']}" não possui descrição');
      }
    }

    return Right(warnings);
  }

  /// Valida dados de configurações
  Either<String, List<String>> _validateSettingsData(
    Map<String, dynamic> settings,
  ) {
    final warnings = <String>[];
    if (settings.isEmpty) {
      warnings.add('Backup não contém configurações do usuário');
    }
    final expectedKeys = [
      'notifications_enabled',
      'backup_settings',
      'theme_mode',
      'language',
    ];

    for (final key in expectedKeys) {
      if (!settings.containsKey(key)) {
        warnings.add('Configuração "$key" não encontrada');
      }
    }

    return Right(warnings);
  }

  /// Valida se uma string é uma data válida
  bool _isValidDate(dynamic dateValue) {
    if (dateValue == null) return false;

    try {
      if (dateValue is String) {
        DateTime.parse(dateValue);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Conta total de itens validados
  int _countValidatedItems(BackupModel backup) {
    return backup.data.plants.length +
        backup.data.tasks.length +
        backup.data.spaces.length;
  }
}

/// Resultado da validação de um backup
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int validatedItemsCount;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.validatedItemsCount,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: ${errors.length}, '
        'warnings: ${warnings.length}, items: $validatedItemsCount)';
  }
}
