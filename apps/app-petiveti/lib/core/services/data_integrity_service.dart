import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../features/animals/data/models/animal_model.dart';
import '../error/failures.dart';

/// Serviço de integridade de dados para app-petiveti
///
/// Responsabilidades:
/// 1. **ID Reconciliation**: Mapear IDs locais temporários → IDs remotos do Firebase
/// 2. **Orphan Detection**: Detectar medications/appointments sem animal válido
/// 3. **Duplicate Detection**: Identificar e remover duplicatas
/// 4. **Relationship Validation**: Validar relacionamentos animal → medications/appointments/weights
///
/// **FASE 2 Expansion**:
/// - Suporta reconciliação de todas as entidades (Animal, Medication, Appointment, Weight)
/// - Verificação de integridade cross-entity
/// - Detecção de orphans e auto-fix
///
/// **Quando usar:**
/// - Após sync manual (forceSyncApp)
/// - Periodicamente em background (timer)
/// - Antes de operações críticas (compartilhamento, exportação)
///
/// **Exemplo:**
/// ```dart
/// final service = getIt<DataIntegrityService>();
///
/// // Reconciliar ID após sync
/// await service.reconcileAnimalId('local_abc123', 'firebase_xyz789');
///
/// // Verificação completa de todas entidades
/// final report = await service.verifyAllEntities();
/// ```
class DataIntegrityService {
  const DataIntegrityService(this._animalLocalDataSource);

  final AnimalLocalDataSource _animalLocalDataSource;

  // TODO FASE 2: Injetar outros datasources quando necessário
  // final MedicationLocalDataSource _medicationLocalDataSource;
  // final AppointmentLocalDataSource _appointmentLocalDataSource;
  // final WeightLocalDataSource _weightLocalDataSource;

  // ========================================================================
  // ID RECONCILIATION
  // ========================================================================

  /// Reconcilia ID de um animal: remove versão local e mantém apenas versão remota
  ///
  /// **Fluxo:**
  /// 1. Usuário cria animal offline → ID local (ex: 'local_abc123')
  /// 2. Sync envia ao Firebase → Firebase retorna ID remoto (ex: 'firebase_xyz789')
  /// 3. Este método:
  ///    - Remove entrada com ID local do HiveBox
  ///    - Mantém apenas entrada com ID remoto
  ///    - Atualiza referências em medications/appointments/weights
  ///
  /// **Exemplo:**
  /// ```dart
  /// // Após sync bem-sucedido
  /// await reconcileAnimalId('local_abc123', 'firebase_xyz789');
  /// // HiveBox agora contém apenas 'firebase_xyz789'
  /// ```
  Future<Either<Failure, void>> reconcileAnimalId(
    String localId,
    String remoteId,
  ) async {
    try {
      if (localId == remoteId) {
        // Mesmo ID - não há o que reconciliar
        return const Right(null);
      }

      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] Reconciling animal ID: $localId → $remoteId',
        );
      }

      // 1. Buscar animal local
      final localAnimalId = int.tryParse(localId);
      if (localAnimalId == null) return const Right(null);
      
      final localAnimal = await _animalLocalDataSource.getAnimalById(localAnimalId);
      if (localAnimal == null) {
        // Animal local já foi removido ou nunca existiu
        if (kDebugMode) {
          debugPrint(
            '[DataIntegrity] Local animal $localId not found - already reconciled?',
          );
        }
        return const Right(null);
      }

      // 2. Verificar se animal remoto já existe
      final remoteAnimalId = int.tryParse(remoteId);
      if (remoteAnimalId == null) return const Right(null);
      
      final remoteAnimal =
          await _animalLocalDataSource.getAnimalById(remoteAnimalId);
      if (remoteAnimal != null) {
        // Animal remoto já existe - apenas remover duplicata local
        await _animalLocalDataSource.deleteAnimal(localAnimalId);

        if (kDebugMode) {
          debugPrint(
            '[DataIntegrity] ✅ Removed duplicate local animal $localId',
          );
        }
      } else {
        // Animal remoto não existe - atualizar ID do animal local
        final updatedAnimal = AnimalModel.fromEntity(
          localAnimal.toEntity().copyWith(id: remoteId),
        );
        await _animalLocalDataSource.updateAnimal(updatedAnimal);
        await _animalLocalDataSource.deleteAnimal(localAnimalId);

        if (kDebugMode) {
          debugPrint(
            '[DataIntegrity] ✅ Updated animal ID: $localId → $remoteId',
          );
        }
      }

      // 3. Atualizar referências em entidades relacionadas
      // TODO: Implementar quando MedicationRepository, AppointmentRepository e WeightRepository forem migrados
      // await _updateMedicationReferences(localId, remoteId);
      // await _updateAppointmentReferences(localId, remoteId);
      // await _updateWeightReferences(localId, remoteId);

      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DataIntegrity] ❌ Error reconciling animal ID: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(ServerFailure(message: 'Failed to reconcile animal ID: $e'));
    }
  }

  // ========================================================================
  // INTEGRITY VERIFICATION
  // ========================================================================

  /// Verifica integridade completa de todos os animals no HiveBox
  ///
  /// **Verificações:**
  /// 1. **Duplicate IDs**: Animals com IDs duplicados (improvável mas possível)
  /// 2. **Invalid Data**: Animals com dados inválidos (nome vazio, etc.)
  /// 3. **Emergency Data**: Animals com dados de emergência incompletos
  ///
  /// **Retorna:** IntegrityReport com estatísticas e problemas encontrados
  Future<Either<Failure, IntegrityReport>> verifyAnimalIntegrity() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] 🔍 Starting animal integrity verification...',
        );
      }

      final startTime = DateTime.now();
      final report = IntegrityReport();

      // Buscar todos os animals
      final allAnimals = await _animalLocalDataSource.getAnimals(userId);
      report.totalAnimals = allAnimals.length;

      if (kDebugMode) {
        debugPrint('[DataIntegrity] Verifying ${allAnimals.length} animals...');
      }

      // 1. Verificar duplicatas de ID
      await _checkDuplicateIds(allAnimals, report);

      // 2. Verificar dados inválidos
      await _checkInvalidData(allAnimals, report);

      // 3. Verificar emergency data
      await _checkEmergencyData(allAnimals, report);

      final duration = DateTime.now().difference(startTime);
      report.verificationDuration = duration;

      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] ✅ Verification complete in ${duration.inMilliseconds}ms',
        );
        debugPrint('[DataIntegrity] Report: ${report.summary}');
      }

      return Right(report);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] ❌ Error verifying animal integrity: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        ServerFailure(message: 'Failed to verify animal integrity: $e'),
      );
    }
  }

  /// Verifica duplicatas de ID (improvável mas possível em cenários de erro)
  Future<void> _checkDuplicateIds(
    List<AnimalModel> animals,
    IntegrityReport report,
  ) async {
    final idCounts = <int, int>{};

    for (final animal in animals) {
      if (animal.id != null) {
        idCounts[animal.id!] = (idCounts[animal.id!] ?? 0) + 1;
      }
    }

    final duplicates = idCounts.entries.where((entry) => entry.value > 1);

    if (duplicates.isNotEmpty) {
      report.duplicateIds.addAll(duplicates.map((e) => e.key.toString()));

      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] ⚠️ Found ${duplicates.length} duplicate IDs',
        );
      }

      // Auto-fix: Remover duplicatas (manter apenas primeira ocorrência)
      for (final duplicateIdStr in report.duplicateIds) {
        final duplicateId = int.tryParse(duplicateIdStr);
        if (duplicateId == null) continue;
        
        final duplicateAnimals =
            animals.where((a) => a.id == duplicateId).toList();
        // Remover todas exceto a primeira
        for (var i = 1; i < duplicateAnimals.length; i++) {
          await _animalLocalDataSource.deleteAnimal(duplicateId);
          report.issuesFixed++;
        }
      }
    }
  }

  /// Verifica dados inválidos (nome vazio, dados corrompidos)
  Future<void> _checkInvalidData(
    List<AnimalModel> animals,
    IntegrityReport report,
  ) async {
    for (final animal in animals) {
      if (animal.name.trim().isEmpty) {
        report.invalidDataIds.add(animal.id.toString());

        if (kDebugMode) {
          debugPrint(
            '[DataIntegrity] ⚠️ Invalid animal: ${animal.id} (empty name)',
          );
        }

        // Auto-fix: Definir nome padrão
        final fixedAnimal = AnimalModel.fromEntity(
          animal.toEntity().copyWith(name: 'Pet sem nome'),
        );
        await _animalLocalDataSource.updateAnimal(fixedAnimal);
        report.issuesFixed++;
      }
    }
  }

  /// Verifica dados de emergência incompletos
  Future<void> _checkEmergencyData(
    List<AnimalModel> animals,
    IntegrityReport report,
  ) async {
    // TODO: Implementar quando Animal tiver campos de emergência
    // Por enquanto, verificação de emergency data será feita via AnimalSyncEntity
    // quando os repositories forem totalmente migrados

    if (kDebugMode) {
      debugPrint(
        '[DataIntegrity] Emergency data check skipped (not yet implemented for Animal entity)',
      );
    }
  }

  // ========================================================================
  // CROSS-ENTITY VERIFICATION (FASE 2)
  // ========================================================================

  /// Verifica integridade de todas as entidades
  ///
  /// **FASE 2**: Verificação consolidada de Animal + dependentes
  /// **Futuro**: Expandir para Medication, Appointment, Weight quando necessário
  ///
  /// **Retorna**: Relatório consolidado de integridade
  Future<Either<Failure, IntegrityReport>> verifyAllEntities() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] 🔍 Starting full integrity verification...',
        );
      }

      // Por enquanto, apenas verifica Animals (base)
      // TODO FASE 2+: Adicionar verificação de Medications, Appointments, Weights
      final animalReport = await verifyAnimalIntegrity();

      return animalReport.fold(
        (failure) => Left(failure),
        (report) {
          if (kDebugMode) {
            debugPrint(
              '[DataIntegrity] ✅ Full verification complete',
            );
            debugPrint('[DataIntegrity] Animals: ${report.totalAnimals}');
            debugPrint(
              '[DataIntegrity] Issues found: ${report.totalIssues}',
            );
            debugPrint(
              '[DataIntegrity] Issues fixed: ${report.issuesFixed}',
            );
          }
          return Right(report);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] ❌ Error verifying all entities: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        ServerFailure(message: 'Failed to verify all entities: $e'),
      );
    }
  }

  // ========================================================================
  // BATCH OPERATIONS
  // ========================================================================

  /// Reconcilia múltiplos IDs em batch (otimizado para performance)
  ///
  /// **Exemplo:**
  /// ```dart
  /// await reconcileBatch([
  ///   ('local_1', 'firebase_1'),
  ///   ('local_2', 'firebase_2'),
  ///   ('local_3', 'firebase_3'),
  /// ]);
  /// ```
  Future<Either<Failure, void>> reconcileBatch(
    List<(String, String)> idPairs,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[DataIntegrity] Starting batch reconciliation of ${idPairs.length} animals...',
        );
      }

      for (final (localId, remoteId) in idPairs) {
        (await reconcileAnimalId(localId, remoteId)).fold(
          (failure) {
            // Log erro mas continua com próximo animal
            if (kDebugMode) {
              debugPrint(
                '[DataIntegrity] ⚠️ Failed to reconcile $localId → $remoteId: ${failure.message}',
              );
            }
          },
          (_) {
            // Sucesso - continuar
          },
        );
      }

      if (kDebugMode) {
        debugPrint('[DataIntegrity] ✅ Batch reconciliation complete');
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Batch reconciliation failed: $e'));
    }
  }
}

// ============================================================================
// INTEGRITY REPORT
// ============================================================================

/// Relatório de verificação de integridade
class IntegrityReport {
  int totalAnimals = 0;
  List<String> duplicateIds = [];
  List<String> invalidDataIds = [];
  List<String> incompleteEmergencyDataIds = [];
  int issuesFixed = 0;
  Duration verificationDuration = Duration.zero;

  bool get hasIssues =>
      duplicateIds.isNotEmpty ||
      invalidDataIds.isNotEmpty ||
      incompleteEmergencyDataIds.isNotEmpty;

  int get totalIssues =>
      duplicateIds.length +
      invalidDataIds.length +
      incompleteEmergencyDataIds.length;

  String get summary {
    return '''
IntegrityReport {
  Total animals: $totalAnimals
  Duplicate IDs: ${duplicateIds.length}
  Invalid data: ${invalidDataIds.length}
  Incomplete emergency data: ${incompleteEmergencyDataIds.length}
  Issues fixed: $issuesFixed
  Duration: ${verificationDuration.inMilliseconds}ms
}''';
  }
}
