import 'package:core/core.dart';

import '../datasources/item_master_local_datasource.dart';
import '../datasources/item_master_remote_datasource.dart';
import '../models/item_master_model.dart';

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

/// Adapter de sincronização para ItemMasters usando Drift + Firebase
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
/// final adapter = ItemMasterDriftSyncAdapter(
///   localDataSource: itemMasterLocalDataSource,
///   remoteDataSource: itemMasterRemoteDataSource,
/// );
///
/// // Push local changes
/// final pushResult = await adapter.pushDirtyRecords(userId);
///
/// // Pull remote changes
/// final pullResult = await adapter.pullRemoteChanges(userId);
/// ```
class ItemMasterDriftSyncAdapter {
  final ItemMasterLocalDataSource _localDataSource;
  final ItemMasterRemoteDataSource _remoteDataSource;

  ItemMasterDriftSyncAdapter({
    required ItemMasterLocalDataSource localDataSource,
    required ItemMasterRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  /// Push dirty records (local → remote)
  ///
  /// Busca item masters modificados localmente e envia para Firebase.
  ///
  /// [userId] - ID do usuário dono dos items
  ///
  /// Retorna número de registros enviados com sucesso.
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(
    String userId,
  ) async {
    try {
      // Get all local item masters
      final localItems = await _localDataSource.getItemMasters(userId);

      int pushed = 0;
      final failedIds = <String>[];

      // Push each item to Firebase
      for (final itemData in localItems) {
        try {
          final model = ItemMasterModel(
            id: itemData.id,
            ownerId: itemData.ownerId,
            name: itemData.name,
            description: itemData.description,
            tags: itemData.tags,
            category: itemData.category,
            photoUrl: itemData.photoUrl,
            estimatedPrice: itemData.estimatedPrice,
            preferredBrand: itemData.preferredBrand,
            notes: itemData.notes,
            usageCount: itemData.usageCount,
            createdAt: itemData.createdAt,
            updatedAt: itemData.updatedAt,
          );

          await _remoteDataSource.saveItemMaster(model);
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

  /// Pull remote changes (remote → local)
  ///
  /// Busca item masters do Firebase e atualiza localmente.
  ///
  /// [userId] - ID do usuário dono dos items
  ///
  /// Retorna número de registros baixados/atualizados.
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId,
  ) async {
    try {
      // Get remote item masters
      final remoteItems = await _remoteDataSource.getItemMasters(userId);

      int pulled = 0;
      int updated = 0;
      final failedIds = <String>[];

      // For each remote item
      for (final remoteModel in remoteItems) {
        try {
          // Check if exists locally
          final localItem =
              await _localDataSource.getItemMasterById(remoteModel.id);

          if (localItem == null) {
            // New remote item → save locally
            await _localDataSource.saveItemMaster(remoteModel);
            pulled++;
          } else {
            // Exists locally → check for conflicts
            if (remoteModel.updatedAt.isAfter(localItem.updatedAt)) {
              // Remote is newer → update local (last-write-wins)
              await _localDataSource.saveItemMaster(remoteModel);
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

  /// Delete local item and mark for remote deletion
  ///
  /// [itemId] - ID do item a deletar
  ///
  /// Deleta localmente e remove do Firebase.
  Future<Either<Failure, void>> deleteAndSync(String itemId) async {
    try {
      // 1. Delete from Firebase
      await _remoteDataSource.deleteItemMaster(itemId);

      // 2. Delete locally
      await _localDataSource.deleteItemMaster(itemId);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Delete and sync failed: $e'));
    }
  }
}
