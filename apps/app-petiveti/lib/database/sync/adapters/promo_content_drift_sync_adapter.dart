import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../entities/sync_promo_content_entity.dart';
import '../../petiveti_database.dart';
import '../../tables/promo_content_table.dart';

/// Adapter de sincronização para Promo Content
/// FIXME: Entity precisa estender BaseSyncEntity
class PromoContentDriftSyncAdapter
    extends DriftSyncAdapterBase<dynamic, PromoContentEntry> {
  PromoContentDriftSyncAdapter(
    PetivetiDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  PetivetiDatabase get localDb => db as PetivetiDatabase;

  @override
  String get collectionName => 'promo_content';

  @override
  TableInfo<PromoContent, PromoContentEntry> get table => localDb.promoContent;

  @override
  Future<Either<Failure, List<dynamic>>> getDirtyRecords(String userId) async {
    try {
      // Promo content não é por usuário
      final query = localDb.select(localDb.promoContent)
        ..where((tbl) => tbl.isDirty.equals(true));

      final results = await query.get();
      final entities = results.map((row) => driftToEntity(row)).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar promo content dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      await (localDb.update(
        localDb.promoContent,
      )..where((tbl) => tbl.id.equals(int.parse(localId)))).write(
        PromoContentCompanion(
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
        CacheFailure('Erro ao marcar promo content como sincronizado: $e'),
      );
    }
  }

  @override
  SyncPromoContentEntity driftToEntity(PromoContentEntry row) {
    return SyncPromoContentEntity(
      id: row.id,
      firebaseId: row.firebaseId,
      title: row.title,
      content: row.content,
      imageUrl: row.imageUrl,
      actionUrl: row.actionUrl,
      expiryDate: row.expiryDate,
      isActive: row.isActive,
      createdAt: row.createdAt,
      isDeleted: row.isDeleted,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      version: row.version,
    );
  }

  @override
  Insertable<PromoContentEntry> entityToCompanion(dynamic entity) {
    final promoEntity = entity as SyncPromoContentEntity;
    return PromoContentCompanion(
      id: promoEntity.id != null
          ? Value(promoEntity.id!)
          : const Value.absent(),
      firebaseId: Value(promoEntity.firebaseId),
      title: Value(promoEntity.title),
      content: Value(promoEntity.content),
      imageUrl: Value(promoEntity.imageUrl),
      actionUrl: Value(promoEntity.actionUrl),
      expiryDate: Value(promoEntity.expiryDate),
      isActive: Value(promoEntity.isActive),
      createdAt: Value(promoEntity.createdAt),
      isDeleted: Value(promoEntity.isDeleted),
      lastSyncAt: Value(promoEntity.lastSyncAt),
      isDirty: Value(promoEntity.isDirty),
      version: Value(promoEntity.version),
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(dynamic entity) {
    final promoEntity = entity as SyncPromoContentEntity;
    return promoEntity.toFirestore();
  }

  @override
  dynamic fromFirestoreDoc(Map<String, dynamic> data) {
    // Note: fromFirestore expects DocumentSnapshot, but we receive Map
    // This adapter may need entity refactoring
    return SyncPromoContentEntity(
      firebaseId: data['id'] as String?,
      title: data['title'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String?,
      actionUrl: data['actionUrl'] as String?,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: false,
      version: data['version'] as int? ?? 1,
    );
  }
}
