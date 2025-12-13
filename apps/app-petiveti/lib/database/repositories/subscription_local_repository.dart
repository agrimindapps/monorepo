import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../petiveti_database.dart';

/// Repositório local para cache de assinaturas do Petiveti
class SubscriptionLocalRepository {
  final PetivetiDatabase _db;
  final StorageEncryptionService _encryptionService;

  SubscriptionLocalRepository(
    this._db, {
    StorageEncryptionService? encryptionService,
  }) : _encryptionService = encryptionService ?? StorageEncryptionService();

  /// Salva ou atualiza uma assinatura no cache local
  Future<void> saveSubscription(SubscriptionEntity subscription) async {
    final companion = UserSubscriptionsCompanion(
      id: Value(subscription.id),
      userId: Value(subscription.userId as String),
      productId: Value(_encryptionService.encrypt(subscription.productId)),
      status: Value(_encryptionService.encrypt(subscription.status.name)),
      tier: Value(_encryptionService.encrypt(subscription.tier.name)),
      store: Value(subscription.store.name),
      expirationDate: Value(subscription.expirationDate),
      purchaseDate: Value(subscription.purchaseDate),
      originalPurchaseDate: Value(subscription.originalPurchaseDate),
      isSandbox: Value(subscription.isSandbox),
      isActive: Value(subscription.isActive),
      updatedAt: Value(DateTime.now()),
      lastSyncAt: Value(DateTime.now()),
      isDirty: const Value(true),
    );

    await _db.into(_db.userSubscriptions).insertOnConflictUpdate(companion);
  }

  /// Obtém a assinatura ativa mais recente do usuário
  Future<SubscriptionEntity?> getActiveSubscription(String userId) async {
    final query = _db.select(_db.userSubscriptions)
      ..where((tbl) => tbl.userId.equals(userId))
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.expirationDate)])
      ..limit(1);

    final result = await query.getSingleOrNull();

    if (result == null) return null;

    return _mapToEntity(result);
  }

  /// Obtém todas as assinaturas do usuário (histórico)
  Future<List<SubscriptionEntity>> getAllSubscriptions(String userId) async {
    final query = _db.select(_db.userSubscriptions)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.purchaseDate)]);

    final results = await query.get();
    return results.map(_mapToEntity).toList();
  }

  /// Remove uma assinatura específica
  Future<void> deleteSubscription(String subscriptionId) async {
    await (_db.delete(
      _db.userSubscriptions,
    )..where((tbl) => tbl.id.equals(subscriptionId))).go();
  }

  /// Limpa todas as assinaturas do usuário
  Future<void> clearUserSubscriptions(String userId) async {
    await (_db.delete(
      _db.userSubscriptions,
    )..where((tbl) => tbl.userId.equals(userId))).go();
  }

  /// Mapeia row Drift para SubscriptionEntity
  SubscriptionEntity _mapToEntity(UserSubscription row) {
    return SubscriptionEntity(
      id: row.id,
      userId: row.userId,
      productId: _encryptionService.decrypt(row.productId),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == _encryptionService.decrypt(row.status),
        orElse: () => SubscriptionStatus.cancelled,
      ),
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == _encryptionService.decrypt(row.tier),
        orElse: () => SubscriptionTier.free,
      ),
      store: Store.values.firstWhere(
        (e) => e.name == row.store,
        orElse: () => Store.appStore,
      ),
      expirationDate: row.expirationDate,
      purchaseDate: row.purchaseDate,
      originalPurchaseDate: row.originalPurchaseDate,
      isSandbox: row.isSandbox,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }
}
