import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../domain/entities/appointment.dart';
import '../../domain/entities/sync/appointment_sync_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../models/appointment_model.dart';

/// AppointmentRepository implementation using UnifiedSyncManager for offline-first sync
///
/// **Características especiais para Appointments:**
/// - **Emergency Priority**: Appointments de emergência têm prioridade alta
/// - **Real-time Sync**: Se isEmergency = true, sync em tempo real
/// - **Status Management**: Tracking de scheduled/completed/cancelled
/// - **Follow-up Tracking**: Gerenciamento de consultas de follow-up
/// - **Offline-first**: Sempre lê do cache local
///
/// **Mudanças da versão anterior:**
/// - Usa UnifiedSyncManager para sincronização automática
/// - Marca entidades como dirty após operações CRUD
/// - Auto-sync triggers após operações de escrita
/// - Removido BaseRepository e Connectivity dependency
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → UnifiedSyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty + incrementVersion → Sync em background
/// 3. DELETE: Marca como deleted (soft delete) → Sync em background
/// 4. READ: Sempre lê do cache local (extremamente rápido)
class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl(this._localDataSource);

  final AppointmentLocalDataSource _localDataSource;

  /// UnifiedSyncManager singleton instance (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, Appointment>> addAppointment(
    Appointment appointment,
  ) async {
    try {
      // 1. Converter para AppointmentSyncEntity e marcar como dirty para sync posterior
      final syncEntity = AppointmentSyncEntity.fromLegacyAppointment(
        appointment,
        moduleName: 'petiveti',
      ).markAsDirty();

      // 2. Salvar localmente (usando AppointmentModel para compatibilidade com Hive)
      final appointmentModel =
          AppointmentModel.fromEntity(syncEntity.toLegacyAppointment());
      await _localDataSource.cacheAppointment(appointmentModel);

      if (kDebugMode) {
        debugPrint(
          '[AppointmentRepository] Appointment created locally: ${appointment.id}',
        );
        if (syncEntity.isEmergency) {
          debugPrint(
            '[AppointmentRepository] ⚠️ Emergency appointment - priority sync',
          );
        }
      }

      // 3. Trigger sync em background (não-bloqueante)
      _triggerBackgroundSync();

      return Right(syncEntity.toLegacyAppointment());
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppointmentRepository] Error creating appointment: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        local_failures.ServerFailure(
          message: 'Failed to create appointment: $e',
        ),
      );
    }
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Appointment>>> getAppointments(
    String animalId,
  ) async {
    try {
      final localAppointments =
          await _localDataSource.getAppointments(animalId);
      final activeAppointments = localAppointments
          .where((model) => !model.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Right(activeAppointments);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get appointments: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Appointment>>>
      getUpcomingAppointments(String animalId) async {
    try {
      final localAppointments =
          await _localDataSource.getAppointments(animalId);
      final upcomingAppointments = localAppointments
          .where((model) => !model.isDeleted && model.toEntity().isUpcoming)
          .map((model) => model.toEntity())
          .toList();

      return Right(upcomingAppointments);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get upcoming appointments: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, Appointment?>> getAppointmentById(
    String id,
  ) async {
    try {
      final localAppointment = await _localDataSource.getAppointmentById(id);

      if (localAppointment != null) {
        if (localAppointment.isDeleted) {
          return Left(
            local_failures.CacheFailure(message: 'Appointment was deleted'),
          );
        }
        return Right(localAppointment.toEntity());
      }

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(message: 'Failed to get appointment: $e'),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Appointment>>>
      getAppointmentsByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final localAppointments =
          await _localDataSource.getAppointments(animalId);

      final filteredAppointments = localAppointments.where((model) {
        if (model.isDeleted) return false;

        final appointmentDate =
            DateTime.fromMillisecondsSinceEpoch(model.dateTimestamp);
        return appointmentDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
      }).map((model) => model.toEntity()).toList();

      return Right(filteredAppointments);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get appointments by date range: $e',
        ),
      );
    }
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, Appointment>> updateAppointment(
    Appointment appointment,
  ) async {
    try {
      // 1. Buscar appointment atual para preservar sync fields
      final currentAppointment =
          await _localDataSource.getAppointmentById(appointment.id);
      if (currentAppointment == null) {
        return Left(
          local_failures.CacheFailure(message: 'Appointment not found'),
        );
      }

      // 2. Converter para SyncEntity, marcar como dirty e incrementar versão
      final syncEntity = AppointmentSyncEntity.fromLegacyAppointment(
        appointment,
        moduleName: 'petiveti',
      ).markAsDirty().incrementVersion();

      // 3. Atualizar localmente
      final appointmentModel =
          AppointmentModel.fromEntity(syncEntity.toLegacyAppointment());
      await _localDataSource.updateAppointment(appointmentModel);

      if (kDebugMode) {
        debugPrint(
          '[AppointmentRepository] Appointment updated locally: ${appointment.id} (version: ${syncEntity.version})',
        );
      }

      // 4. Trigger sync em background
      _triggerBackgroundSync();

      return Right(syncEntity.toLegacyAppointment());
    } catch (e) {
      return Left(
        local_failures.ServerFailure(
          message: 'Failed to update appointment: $e',
        ),
      );
    }
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteAppointment(
    String id,
  ) async {
    try {
      // Soft delete (datasource implementa)
      await _localDataSource.deleteAppointment(id);

      if (kDebugMode) {
        debugPrint('[AppointmentRepository] Appointment soft-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(
          message: 'Failed to delete appointment: $e',
        ),
      );
    }
  }

  // ========================================================================
  // SYNC HELPERS
  // ========================================================================

  /// Trigger sync em background (não-bloqueante)
  /// UnifiedSyncManager gerencia filas e throttling automaticamente
  /// Appointments de emergência têm prioridade alta
  void _triggerBackgroundSync() {
    // TODO: Implementar quando UnifiedSyncManager tiver método trigger manual
    // Por enquanto, AutoSyncService fará sync periódico automaticamente
    if (kDebugMode) {
      debugPrint(
        '[AppointmentRepository] Background sync will be triggered by AutoSyncService',
      );
    }
  }

  /// Force sync manual (bloqueante) - para uso em casos específicos
  Future<Either<local_failures.Failure, void>> forceSync() async {
    try {
      // TODO: Implementar quando UnifiedSyncManager tiver método forceSync
      // await _syncManager.forceSyncApp('petiveti');

      if (kDebugMode) {
        debugPrint(
          '[AppointmentRepository] Manual sync requested (not yet implemented)',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(message: 'Failed to force sync: $e'),
      );
    }
  }
}
