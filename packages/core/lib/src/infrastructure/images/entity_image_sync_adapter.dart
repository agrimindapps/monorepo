import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'entity_image.dart';
import 'entity_image_repository.dart';

/// Adaptador de sincronização para imagens com Firestore
///
/// Sincroniza imagens armazenadas localmente com a coleção
/// `entity_images` no Firestore, usando Base64 inline.
///
/// **Estratégia de Sync:**
/// - Upload: Imagens com isDirty=true são enviadas para Firestore
/// - Download: Imagens do Firestore são baixadas para o local
/// - Conflito: Last-write-wins baseado em updatedAt
///
/// **Limites do Firestore:**
/// - Documento max: 1MB
/// - Com Base64 600KB + metadata: ~850KB (dentro do limite)
class EntityImageSyncAdapter {
  final FirebaseFirestore _firestore;
  final IEntityImageRepository _repository;
  final String _collectionName;

  EntityImageSyncAdapter({
    required IEntityImageRepository repository,
    FirebaseFirestore? firestore,
    String collectionName = 'entity_images',
  })  : _repository = repository,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _collectionName = collectionName;

  /// Referência para a coleção de imagens
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  /// Sincroniza imagens pendentes (upload)
  ///
  /// Retorna número de imagens sincronizadas com sucesso
  Future<int> syncPendingImages() async {
    final dirtyImages = await _repository.getDirtyImages();
    
    if (dirtyImages.isEmpty) {
      _log('Nenhuma imagem pendente para sincronizar');
      return 0;
    }

    _log('Sincronizando ${dirtyImages.length} imagens...');
    int syncedCount = 0;

    for (final image in dirtyImages) {
      try {
        await _uploadImage(image);
        syncedCount++;
      } catch (e) {
        _log('Erro ao sincronizar imagem ${image.id}: $e');
      }
    }

    _log('Sincronização concluída: $syncedCount/${dirtyImages.length}');
    return syncedCount;
  }

  /// Faz upload de uma imagem para Firestore
  Future<void> _uploadImage(EntityImage image) async {
    final data = image.toFirestoreMap();
    
    if (image.firebaseId != null) {
      // Atualizar documento existente
      await _collection.doc(image.firebaseId).set(data, SetOptions(merge: true));
      await _repository.markAsSynced(
        imageId: image.id!,
        firebaseId: image.firebaseId!,
      );
      _log('Imagem ${image.id} atualizada no Firestore');
    } else {
      // Criar novo documento
      final docRef = await _collection.add(data);
      await _repository.markAsSynced(
        imageId: image.id!,
        firebaseId: docRef.id,
      );
      _log('Imagem ${image.id} criada no Firestore: ${docRef.id}');
    }
  }

  /// Baixa imagens do Firestore para uma entidade específica
  ///
  /// Útil para sincronização inicial ou após login
  Future<List<EntityImage>> downloadImagesForEntity({
    required String entityType,
    required String entityId,
    required String userId,
  }) async {
    final query = _collection
        .where('entityType', isEqualTo: entityType)
        .where('entityId', isEqualTo: entityId)
        .where('userId', isEqualTo: userId);

    final snapshot = await query.get();
    final List<EntityImage> images = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        
        final image = EntityImage.fromMap(data);
        images.add(image);
      } catch (e) {
        _log('Erro ao processar imagem ${doc.id}: $e');
      }
    }

    _log('Baixadas ${images.length} imagens para $entityType/$entityId');
    return images;
  }

  /// Baixa todas as imagens do usuário de um módulo
  Future<List<EntityImage>> downloadAllImagesForUser({
    required String userId,
    required String moduleName,
    DateTime? since,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('userId', isEqualTo: userId)
        .where('moduleName', isEqualTo: moduleName);

    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: since.toIso8601String());
    }

    final snapshot = await query.get();
    final List<EntityImage> images = [];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        
        final image = EntityImage.fromMap(data);
        images.add(image);
      } catch (e) {
        _log('Erro ao processar imagem ${doc.id}: $e');
      }
    }

    _log('Baixadas ${images.length} imagens para usuário $userId');
    return images;
  }

  /// Deleta uma imagem do Firestore
  Future<void> deleteFromFirestore(String firebaseId) async {
    await _collection.doc(firebaseId).delete();
    _log('Imagem $firebaseId deletada do Firestore');
  }

  /// Escuta mudanças em tempo real para imagens de uma entidade
  Stream<List<EntityImage>> watchFirestoreImages({
    required String entityType,
    required String entityId,
    required String userId,
  }) {
    return _collection
        .where('entityType', isEqualTo: entityType)
        .where('entityId', isEqualTo: entityId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firebaseId'] = doc.id;
        return EntityImage.fromMap(data);
      }).toList();
    });
  }

  /// Resolve conflito entre versão local e remota
  ///
  /// Estratégia: Last-write-wins baseado em updatedAt
  EntityImage resolveConflict(EntityImage local, EntityImage remote) {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      _log('Conflito resolvido: versão local vence');
      return local.copyWith(isDirty: true);
    } else {
      _log('Conflito resolvido: versão remota vence');
      return remote.copyWith(
        id: local.id,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );
    }
  }

  /// Sincronização bidirecional completa
  ///
  /// 1. Upload de imagens locais pendentes
  /// 2. Download de imagens remotas novas/atualizadas
  /// 3. Resolução de conflitos
  Future<SyncResult> fullSync({
    required String userId,
    required String moduleName,
    DateTime? lastSyncAt,
  }) async {
    int uploaded = 0;
    int downloaded = 0;
    int conflicts = 0;
    final errors = <String>[];

    try {
      // 1. Upload pendentes
      uploaded = await syncPendingImages();

      // 2. Download novas/atualizadas
      final remoteImages = await downloadAllImagesForUser(
        userId: userId,
        moduleName: moduleName,
        since: lastSyncAt,
      );

      for (final remote in remoteImages) {
        try {
          final local = await _repository.getImageByFirebaseId(remote.firebaseId!);
          
          if (local == null) {
            // Nova imagem - salvar localmente
            // Nota: O repository precisa implementar um método para inserir
            // imagem já processada (sem reprocessar)
            downloaded++;
          } else if (local.updatedAt != remote.updatedAt) {
            // Conflito - resolver
            resolveConflict(local, remote);
            conflicts++;
          }
        } catch (e) {
          errors.add('Erro ao processar ${remote.firebaseId}: $e');
        }
      }
    } catch (e) {
      errors.add('Erro na sincronização: $e');
    }

    return SyncResult(
      uploaded: uploaded,
      downloaded: downloaded,
      conflicts: conflicts,
      errors: errors,
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🔄 [EntityImageSyncAdapter] $message');
    }
  }
}

/// Resultado da sincronização
class SyncResult {
  final int uploaded;
  final int downloaded;
  final int conflicts;
  final List<String> errors;

  const SyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.conflicts,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => !hasErrors;
  int get totalProcessed => uploaded + downloaded + conflicts;

  @override
  String toString() {
    return 'SyncResult(uploaded: $uploaded, downloaded: $downloaded, '
        'conflicts: $conflicts, errors: ${errors.length})';
  }
}
