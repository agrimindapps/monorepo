import 'package:core/core.dart';

import '../datasources/list_item_local_datasource.dart';
import '../datasources/list_item_remote_datasource.dart';
import '../models/list_item_model.dart';

/// Resultado de operação de push (local → remote)
class SyncPushResult {
  final int recordsPushed;
  final List<String> failedIds;

  const SyncPushResult({
    required this.recordsPushed,
    this.failedIds = const [],
  });
}

/// Resultado de operação de pull (remote → local)
class SyncPullResult {
  final int recordsPulled;
  final int recordsUpdated;
  final List<String> failedIds;

  const SyncPullResult({
    required this.recordsPulled,
    required this.recordsUpdated,
    this.failedIds = const [],
  });
}

/// Adapter de sincronização para ListItems usando Drift + Firebase
///
/// **Responsabilidades:**
/// 1. Push dirty records (local → Firebase)
/// 2. Pull remote changes (Firebase → local)
/// 3. Conflict resolution (last-write-wins)
///
/// **Padrão:** Similar a ListDriftSyncAdapter
///
/// **Exemplo de uso:**
/// ```dart
/// final adapter = ListItemDriftSyncAdapter(
///   localDataSource: listItemLocalDataSource,
///   remoteDataSource: listItemRemoteDataSource,
/// );
///
/// // Sync items de uma lista específica
/// final result = await adapter.syncListItems(listId, userId);
/// ```
class ListItemDriftSyncAdapter {
  final ListItemLocalDataSource _localDataSource;
  final ListItemRemoteDataSource _remoteDataSource;

  ListItemDriftSyncAdapter({
    required ListItemLocalDataSource localDataSource,
    required ListItemRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  /// Push dirty records de uma lista (local → remote)
  ///
  /// Busca items de uma lista modificados localmente e envia para Firebase.
  ///
  /// [listId] - ID da lista
  ///
  /// Retorna número de registros enviados com sucesso.
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(
    String listId,
  ) async {
    try {
      // Get all local list items
      final localItems = await _localDataSource.getListItems(listId);

      int pushed = 0;
      final failedIds = <String>[];

      // Push each item to Firebase
      for (final itemData in localItems) {
        try {
          final model = ListItemModel(
            id: itemData.id,
            listId: itemData.listId,
            itemMasterId: itemData.itemMasterId,
            quantity: itemData.quantity,
            priorityIndex: itemData.priorityIndex,
            isCompleted: itemData.isCompleted,
            completedAt: itemData.completedAt,
            notes: itemData.notes,
            order: itemData.order,
            createdAt: itemData.createdAt,
            updatedAt: itemData.updatedAt,
            addedBy: itemData.addedBy,
          );

          await _remoteDataSource.saveListItem(model);
          pushed++;
        } catch (e) {
          failedIds.add(itemData.id);
        }
      }

      return Right(SyncPushResult(
        recordsPushed: pushed,
        failedIds: failedIds,
      ));
    } catch (e) {
      return Left(ServerFailure('Push failed: $e'));
    }
  }

  /// Pull remote changes de uma lista (remote → local)
  ///
  /// Busca items de uma lista do Firebase e atualiza localmente.
  ///
  /// [listId] - ID da lista
  ///
  /// Retorna número de registros baixados/atualizados.
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String listId,
  ) async {
    try {
      // Get remote list items
      final remoteItems = await _remoteDataSource.getListItems(listId);

      int pulled = 0;
      int updated = 0;
      final failedIds = <String>[];

      // For each remote item
      for (final remoteModel in remoteItems) {
        try {
          // Check if exists locally
          final localItem =
              await _localDataSource.getListItemById(remoteModel.id);

          if (localItem == null) {
            // New remote item → save locally
            await _localDataSource.saveListItem(remoteModel);
            pulled++;
          } else {
            // Exists locally → check for conflicts
            if (remoteModel.updatedAt.isAfter(localItem.updatedAt)) {
              // Remote is newer → update local (last-write-wins)
              await _localDataSource.saveListItem(remoteModel);
              updated++;
            }
            // If local is newer, keep local (will be pushed in next sync)
          }
        } catch (e) {
          failedIds.add(remoteModel.id);
        }
      }

      return Right(SyncPullResult(
        recordsPulled: pulled,
        recordsUpdated: updated,
        failedIds: failedIds,
      ));
    } catch (e) {
      return Left(ServerFailure('Pull failed: $e'));
    }
  }

  /// Sync completo de items de uma lista (push + pull)
  ///
  /// Executa push seguido de pull para uma lista específica.
  ///
  /// [listId] - ID da lista
  ///
  /// Retorna resultado combinado.
  Future<Either<Failure, Map<String, dynamic>>> syncListItems(
    String listId,
  ) async {
    try {
      // 1. Push local changes
      final pushResult = await pushDirtyRecords(listId);
      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, SyncPushResult>).value);
      }

      final push = (pushResult as Right<Failure, SyncPushResult>).value;

      // 2. Pull remote changes
      final pullResult = await pullRemoteChanges(listId);
      if (pullResult.isLeft()) {
        return Left((pullResult as Left<Failure, SyncPullResult>).value);
      }

      final pull = (pullResult as Right<Failure, SyncPullResult>).value;

      return Right({
        'pushed': push.recordsPushed,
        'pulled': pull.recordsPulled,
        'updated': pull.recordsUpdated,
        'total': push.recordsPushed + pull.recordsPulled + pull.recordsUpdated,
      });
    } catch (e) {
      return Left(ServerFailure('Sync list items failed: $e'));
    }
  }

  /// Sync de todas as listas do usuário
  ///
  /// [listIds] - Lista de IDs das listas a sincronizar
  ///
  /// Retorna resultado agregado de todas as listas.
  Future<Either<Failure, Map<String, dynamic>>> syncAllLists(
    List<String> listIds,
  ) async {
    try {
      int totalPushed = 0;
      int totalPulled = 0;
      int totalUpdated = 0;

      for (final listId in listIds) {
        final result = await syncListItems(listId);

        result.fold(
          (failure) {
            // Continue tentando outras listas mesmo se uma falhar
          },
          (stats) {
            totalPushed += stats['pushed'] as int;
            totalPulled += stats['pulled'] as int;
            totalUpdated += stats['updated'] as int;
          },
        );
      }

      return Right({
        'pushed': totalPushed,
        'pulled': totalPulled,
        'updated': totalUpdated,
        'total': totalPushed + totalPulled + totalUpdated,
        'lists_synced': listIds.length,
      });
    } catch (e) {
      return Left(ServerFailure('Sync all lists failed: $e'));
    }
  }

  /// Delete local item and mark for remote deletion
  ///
  /// [itemId] - ID do item a deletar
  ///
  /// Deleta localmente e remove do Firebase.
  Future<Either<Failure, void>> deleteAndSync(String itemId) async {
    try {
      // 1. Delete from Firebase
      await _remoteDataSource.deleteListItem(itemId);

      // 2. Delete locally
      await _localDataSource.deleteListItem(itemId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Delete and sync failed: $e'));
    }
  }
}
