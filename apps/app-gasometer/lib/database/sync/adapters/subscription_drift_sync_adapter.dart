
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../gasometer_database.dart';
import '../../tables/gasometer_tables.dart';

/// Adapter de sincronização para Assinaturas
class SubscriptionDriftSyncAdapter
    extends DriftSyncAdapterBase<SubscriptionEntity, UserSubscription> {

  SubscriptionDriftSyncAdapter(
    GasometerDatabase super.db,
    super.firestore,
    super.connectivityService, {
    StorageEncryptionService? encryptionService,
  }) : _encryptionService = encryptionService ?? StorageEncryptionService();
  final StorageEncryptionService _encryptionService;

  GasometerDatabase get localDb => db as GasometerDatabase;

  @override
  String get collectionName => 'user_subscriptions';

  @override
  TableInfo<UserSubscriptions, UserSubscription> get table =>
      localDb.userSubscriptions;

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.userSubscriptions)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();

      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar assinaturas dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.userSubscriptions,
      )..where((tbl) => tbl.id.equals(localId))).write(
        UserSubscriptionsCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId: firebaseId != null
              ? Value(firebaseId)
              : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao marcar assinatura como sincronizada: $e'),
      );
    }
  }

  @override
  SubscriptionEntity driftToEntity(UserSubscription row) {
    final decryptedProductId = _encryptionService.decrypt(row.productId);
    final decryptedStatus = _encryptionService.decrypt(row.status);
    final decryptedTier = _encryptionService.decrypt(row.tier);

    return SubscriptionEntity(
      id: row.id,
      userId: row.userId,
      productId: decryptedProductId,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == decryptedStatus,
        orElse: () => SubscriptionStatus.unknown,
      ),
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == decryptedTier,
        orElse: () => SubscriptionTier.free,
      ),
      store: Store.values.firstWhere(
        (e) => e.name == row.store,
        orElse: () => Store.unknown,
      ),
      expirationDate: row.expirationDate,
      purchaseDate: row.purchaseDate,
      originalPurchaseDate: row.originalPurchaseDate,
      isSandbox: row.isSandbox,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      isDeleted: row.isDeleted,
      version: row.version,
    );
  }

  @override
  UserSubscriptionsCompanion entityToCompanion(SubscriptionEntity entity) {
    return UserSubscriptionsCompanion(
      id: Value(entity.id),
      userId: Value(entity.userId as String),
      productId: Value(_encryptionService.encrypt(entity.productId)),
      status: Value(_encryptionService.encrypt(entity.status.name)),
      tier: Value(_encryptionService.encrypt(entity.tier.name)),
      store: Value(entity.store.name),
      expirationDate: Value(entity.expirationDate),
      purchaseDate: Value(entity.purchaseDate),
      originalPurchaseDate: Value(entity.originalPurchaseDate),
      isSandbox: Value(entity.isSandbox),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      firebaseId: Value(entity.id),
    );
  }

  @override
  SubscriptionEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return SubscriptionEntity.fromFirebaseMap(data);
  }

  @override
  Map<String, dynamic> toFirestoreMap(SubscriptionEntity entity) {
    return entity.toFirebaseMap();
  }
}
