import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/entities/item_master_entity.dart';
import '../../domain/repositories/i_item_master_repository.dart';
import '../datasources/item_master_local_datasource.dart';
import '../datasources/item_master_remote_datasource.dart';
import '../models/item_master_model.dart';

/// Implementation of ItemMaster repository
/// Offline-first: Hive is primary, Firestore is optional sync
@Injectable(as: IItemMasterRepository)
class ItemMasterRepository implements IItemMasterRepository {
  final ItemMasterLocalDataSource _localDataSource;
  final ItemMasterRemoteDataSource _remoteDataSource;
  final AuthStateNotifier _authNotifier;

  static const int _freeItemMasterLimit = 200;

  ItemMasterRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._authNotifier,
  );

  String? get _currentUserId => _authNotifier.userId;

  @override
  Future<Either<Failure, List<ItemMasterEntity>>> getItemMasters() async {
    try {
      // Get from local storage (offline-first)
      final models = _localDataSource.getItemMasters();
      final entities = models.map((m) => m.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ItemMasterEntity>> getItemMasterById(
    String id,
  ) async {
    try {
      final model = _localDataSource.getItemMasterById(id);

      if (model == null) {
        return const Left(NotFoundFailure('Item não encontrado'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ItemMasterEntity>> createItemMaster(
    ItemMasterEntity itemMaster,
  ) async {
    try {
      if (_currentUserId == null) {
        return const Left(
          AuthFailure('Usuário não autenticado'),
        );
      }

      // Create with generated ID and current user
      final newItem = ItemMasterEntity(
        id: const Uuid().v4(),
        ownerId: _currentUserId!,
        name: itemMaster.name,
        description: itemMaster.description,
        tags: itemMaster.tags,
        category: itemMaster.category,
        photoUrl: itemMaster.photoUrl,
        estimatedPrice: itemMaster.estimatedPrice,
        preferredBrand: itemMaster.preferredBrand,
        notes: itemMaster.notes,
        usageCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = ItemMasterModel.fromEntity(newItem);

      // Save to local storage
      await _localDataSource.saveItemMaster(model);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveItemMaster(model).ignore();

      return Right(newItem);
    } catch (e) {
      return Left(CacheFailure('Erro ao criar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ItemMasterEntity>> updateItemMaster(
    ItemMasterEntity itemMaster,
  ) async {
    try {
      final model = ItemMasterModel.fromEntity(itemMaster);

      // Update in local storage
      await _localDataSource.saveItemMaster(model);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveItemMaster(model).ignore();

      return Right(itemMaster);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItemMaster(String id) async {
    try {
      // Delete from local storage
      await _localDataSource.deleteItemMaster(id);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.deleteItemMaster(id).ignore();

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getItemMastersCount() async {
    try {
      final count = _localDataSource.getItemMastersCount();
      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUsageCount(String id) async {
    try {
      final model = _localDataSource.getItemMasterById(id);

      if (model == null) {
        return const Left(NotFoundFailure('Item não encontrado'));
      }

      // Create updated model with incremented usage count
      final updated = ItemMasterModel(
        id: model.id,
        ownerId: model.ownerId,
        name: model.name,
        description: model.description,
        tags: model.tags,
        category: model.category,
        photoUrl: model.photoUrl,
        estimatedPrice: model.estimatedPrice,
        preferredBrand: model.preferredBrand,
        notes: model.notes,
        usageCount: model.usageCount + 1,
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
      );

      await _localDataSource.saveItemMaster(updated);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveItemMaster(updated).ignore();

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao incrementar contador: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ItemMasterEntity>>> searchItemMasters(
    String query,
  ) async {
    try {
      final models = _localDataSource.searchItemMasters(query);
      final entities = models.map((m) => m.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> canCreateItemMaster() async {
    try {
      // TODO: Check premium status when RevenueCat is integrated
      final isPremium = false; // Placeholder

      if (isPremium) {
        return const Right(true); // Premium has unlimited items
      }

      // Check free tier limit
      final count = _localDataSource.getItemMastersCount();
      return Right(count < _freeItemMasterLimit);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar limite: ${e.toString()}'));
    }
  }
}
