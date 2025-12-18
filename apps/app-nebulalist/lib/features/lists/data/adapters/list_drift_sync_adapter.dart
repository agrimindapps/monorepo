import 'package:core/core.dart';

import '../datasources/list_local_datasource.dart';
import '../datasources/list_remote_datasource.dart';
import '../models/list_model.dart';

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

/// Adapter de sincronização para Lists usando Drift + Firebase
///
/// **Responsabilidades:**
/// 1. Push dirty records (local → Firebase)
/// 2. Pull remote changes (Firebase → local)
/// 3. Conflict resolution (last-write-wins)
///
/// **Padrão:** Baseado em app-plantis/SubscriptionDriftSyncAdapter
///
/// **Exemplo de uso:**
/// ```dart
/// final adapter = ListDriftSyncAdapter(
///   localDataSource: listLocalDataSource,
///   remoteDataSource: listRemoteDataSource,
/// );
///
/// // Push local changes
/// final pushResult = await adapter.pushDirtyRecords(userId);
/// pushResult.fold(
///   (failure) => print('Push failed'),
///   (result) => print('Pushed ${result.recordsPushed} lists'),
/// );
///
/// // Pull remote changes
/// final pullResult = await adapter.pullRemoteChanges(userId);
/// ```
class ListDriftSyncAdapter {
  final IListLocalDataSource _localDataSource;
  final IListRemoteDataSource _remoteDataSource;

  ListDriftSyncAdapter({
    required IListLocalDataSource localDataSource,
    required IListRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  /// Push dirty records (local → remote)
  ///
  /// Busca listas modificadas localmente e envia para Firebase.
  ///
  /// [userId] - ID do usuário dono das listas
  ///
  /// Retorna número de registros enviados com sucesso.
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(
    String userId,
  ) async {
    try {
      // 1. Get all local lists (dirty tracking será implementado depois)
      // Por enquanto, envia todas as listas do usuário
      final localLists = await _localDataSource.getAllLists(userId);

      int pushed = 0;
      final failedIds = <String>[];

      // 2. Push each list to Firebase
      for (final listData in localLists) {
        try {
          final model = ListModel(
            id: listData.id,
            name: listData.name,
            ownerId: listData.ownerId,
            description: listData.description,
            tags: listData.tags,
            category: listData.category,
            isFavorite: listData.isFavorite,
            isArchived: listData.isArchived,
            createdAt: listData.createdAt,
            updatedAt: listData.updatedAt,
            shareToken: listData.shareToken,
            isShared: listData.isShared,
            archivedAt: listData.archivedAt,
            itemCount: listData.itemCount,
            completedCount: listData.completedCount,
          );

          await _remoteDataSource.saveList(model);
          pushed++;
        } catch (e) {
          failedIds.add(listData.id);
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

  /// Pull remote changes (remote → local)
  ///
  /// Busca listas do Firebase e atualiza localmente.
  ///
  /// [userId] - ID do usuário dono das listas
  ///
  /// Retorna número de registros baixados/atualizados.
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId,
  ) async {
    try {
      // 1. Get remote lists
      final remoteLists = await _remoteDataSource.getLists(userId);

      int pulled = 0;
      int updated = 0;
      final failedIds = <String>[];

      // 2. For each remote list
      for (final remoteModel in remoteLists) {
        try {
          // Check if exists locally
          final localList = await _localDataSource.getList(remoteModel.id);

          if (localList == null) {
            // New remote list → save locally
            await _localDataSource.saveList(remoteModel);
            pulled++;
          } else {
            // Exists locally → check for conflicts
            if (remoteModel.updatedAt.isAfter(localList.updatedAt)) {
              // Remote is newer → update local (last-write-wins)
              await _localDataSource.saveList(remoteModel);
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

  /// Sync completo (push + pull)
  ///
  /// Executa push seguido de pull.
  ///
  /// [userId] - ID do usuário
  ///
  /// Retorna resultado combinado.
  Future<Either<Failure, Map<String, dynamic>>> syncAll(String userId) async {
    try {
      // 1. Push local changes
      final pushResult = await pushDirtyRecords(userId);
      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, SyncPushResult>).value);
      }

      final push = (pushResult as Right<Failure, SyncPushResult>).value;

      // 2. Pull remote changes
      final pullResult = await pullRemoteChanges(userId);
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
      return Left(ServerFailure('Sync all failed: $e'));
    }
  }

  /// Delete local list and mark for remote deletion
  ///
  /// [listId] - ID da lista a deletar
  ///
  /// Deleta localmente e remove do Firebase.
  Future<Either<Failure, void>> deleteAndSync(String listId) async {
    try {
      // 1. Delete from Firebase
      await _remoteDataSource.deleteList(listId);

      // 2. Delete locally
      await _localDataSource.deleteList(listId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Delete and sync failed: $e'));
    }
  }
}
