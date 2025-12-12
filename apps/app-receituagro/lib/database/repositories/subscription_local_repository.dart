import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório local para cache de assinaturas
class SubscriptionLocalRepository {
  final ReceituagroDatabase _db;
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
      store: Value(subscription.store.name), // Store usually not sensitive
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
    // We query by userId and isActive (boolean, not encrypted)
    // expirationDate is also not encrypted so we can sort
    final query = _db.select(_db.userSubscriptions)
      ..where((tbl) => tbl.userId.equals(userId))
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.expirationDate)])
      ..limit(1);

    final result = await query.getSingleOrNull();

    if (result == null) return null;

    return _mapToEntity(result);
  }

  /// Mapeia o registro do banco para a entidade
  SubscriptionEntity _mapToEntity(UserSubscription record) {
    final decryptedProductId = _encryptionService.decrypt(record.productId);
    final decryptedStatus = _encryptionService.decrypt(record.status);
    final decryptedTier = _encryptionService.decrypt(record.tier);

    return SubscriptionEntity(
      id: record.id,
      userId: record.userId,
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
        (e) => e.name == record.store,
        orElse: () => Store.unknown,
      ),
      expirationDate: record.expirationDate,
      purchaseDate: record.purchaseDate,
      originalPurchaseDate: record.originalPurchaseDate,
      isSandbox: record.isSandbox,
      // Campos padrão
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      lastSyncAt: record.lastSyncAt,
      isDirty: false,
      isDeleted: false,
      version: 1,
    );
  }

  /// Limpa cache de assinaturas do usuário
  Future<void> clearUserSubscriptions(String userId) async {
    await (_db.delete(
      _db.userSubscriptions,
    )..where((tbl) => tbl.userId.equals(userId))).go();
  }
}
