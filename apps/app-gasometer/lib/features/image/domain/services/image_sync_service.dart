import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/models/pending_image_upload.dart';
import '../../../../core/services/storage/firebase_storage_service.dart'
    as app_storage;

/// Resultado da sincronização de imagens
class SyncResult {
  final int successful;
  final int failed;
  final int skipped;
  final bool wasOffline;

  SyncResult({
    required this.successful,
    required this.failed,
    this.skipped = 0,
    this.wasOffline = false,
  });

  factory SyncResult.offline() {
    return SyncResult(successful: 0, failed: 0, wasOffline: true);
  }

  factory SyncResult.empty() {
    return SyncResult(successful: 0, failed: 0);
  }

  bool get hasErrors => failed > 0;
  bool get hasSuccess => successful > 0;
  int get total => successful + failed + skipped;

  @override
  String toString() {
    return 'SyncResult(successful: $successful, failed: $failed, skipped: $skipped, wasOffline: $wasOffline)';
  }
}

/// Progresso da sincronização
class SyncProgress {
  final int current;
  final int total;
  final String? currentItemId;
  final bool isCompleted;
  final String? errorMessage;

  SyncProgress({
    required this.current,
    required this.total,
    this.currentItemId,
    this.isCompleted = false,
    this.errorMessage,
  });

  factory SyncProgress.completed() {
    return SyncProgress(current: 0, total: 0, isCompleted: true);
  }

  factory SyncProgress.error(String message) {
    return SyncProgress(
      current: 0,
      total: 0,
      isCompleted: true,
      errorMessage: message,
    );
  }

  double get percentage => total > 0 ? current / total : 0;
}

/// Serviço de sincronização de imagens offline
///
/// Responsável por:
/// - Adicionar imagens à fila de upload quando offline
/// - Sincronizar automaticamente quando volta online
/// - Retry com backoff exponencial
/// - Persistir fila em memória (Drift pode ser usado futuramente)

class ImageSyncService {
  final app_storage.FirebaseStorageService _storageService;
  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firestore;

  final Map<String, PendingImageUpload> _pendingUploads = {};
  bool _initialized = false;

  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();

  /// Stream de progresso da sincronização
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Número de uploads pendentes
  int get pendingCount => _initialized ? _pendingUploads.length : 0;

  /// Lista de uploads pendentes
  List<PendingImageUpload> get pendingUploads =>
      _initialized ? _pendingUploads.values.toList() : [];

  ImageSyncService(this._storageService, this._connectivityService)
    : _firestore = FirebaseFirestore.instance;

  /// Inicializa o serviço
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _initialized = true;

      print(
        '🔄 ImageSyncService initialized with ${pendingCount} pending uploads',
      );

      // Se há uploads pendentes, tenta sincronizar
      if (pendingCount > 0) {
        await syncPendingImages();
      }
    } catch (e) {
      print('❌ Error initializing ImageSyncService: $e');
      rethrow;
    }
  }

  /// Adiciona imagem à fila de upload pendente
  ///
  /// Usado quando uma imagem é capturada offline
  Future<String> addPendingUpload({
    required String localPath,
    required String userId,
    required String recordId,
    required String category,
    required String collectionPath,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final id = const Uuid().v4();
    final upload = PendingImageUpload.create(
      id: id,
      localPath: localPath,
      userId: userId,
      recordId: recordId,
      category: category,
      collectionPath: collectionPath,
    );

    _pendingUploads[id] = upload;

    print(
      '📤 Added pending upload: $recordId ($category) - Queue size: ${pendingCount}',
    );

    return id;
  }

  /// Sincroniza todas as imagens pendentes
  ///
  /// Retorna resultado com contadores de sucesso/falha
  Future<SyncResult> syncPendingImages() async {
    if (!_initialized) {
      await initialize();
    }

    // Verifica conectividade
    final isOnline = await _connectivityService.isOnline();
    if (isOnline == false) {
      print('🔌 Offline - cannot sync pending images');
      return SyncResult.offline();
    }

    final pending = _pendingUploads.values.toList();

    if (pending.isEmpty) {
      print('✅ No pending images to sync');
      return SyncResult.empty();
    }

    print('🔄 Starting sync of ${pending.length} pending images...');

    int successful = 0;
    int failed = 0;
    int skipped = 0;

    for (int i = 0; i < pending.length; i++) {
      final upload = pending[i];

      // Emite progresso
      _progressController.add(
        SyncProgress(
          current: i + 1,
          total: pending.length,
          currentItemId: upload.recordId,
        ),
      );

      // Verifica se deve aguardar (backoff)
      if (upload.shouldWaitBeforeRetry) {
        print('⏳ Skipping ${upload.id} - waiting for backoff');
        skipped++;
        continue;
      }

      // Verifica se atingiu máximo de tentativas
      if (upload.hasMaxedRetries) {
        print('❌ Max retries reached for ${upload.id}');
        _pendingUploads.remove(upload.id);
        failed++;
        continue;
      }

      try {
        await _syncSingleImage(upload);
        successful++;
      } catch (e) {
        print('❌ Failed to sync ${upload.id}: $e');

        // Atualiza com erro e incrementa retry count
        final updatedUpload = upload.withRetry(e.toString());
        _pendingUploads[upload.id] = updatedUpload;

        failed++;
      }
    }

    _progressController.add(SyncProgress.completed());

    final result = SyncResult(
      successful: successful,
      failed: failed,
      skipped: skipped,
    );

    print('✅ Sync completed: $result');

    return result;
  }

  /// Sincroniza uma única imagem
  Future<void> _syncSingleImage(PendingImageUpload upload) async {
    print('📤 Syncing image: ${upload.recordId} (${upload.category})');

    // 1. Verifica se arquivo local existe
    final file = File(upload.localPath);
    if (!await file.exists()) {
      throw Exception('Local file not found: ${upload.localPath}');
    }

    // 2. Upload para Firebase Storage
    final String downloadUrl;

    switch (upload.category) {
      case 'fuel':
        downloadUrl = await _storageService.uploadFuelReceiptImage(
          upload.userId,
          upload.recordId,
          upload.localPath,
        );
        break;
      case 'maintenance':
        downloadUrl = await _storageService.uploadMaintenanceReceiptImage(
          upload.userId,
          upload.recordId,
          upload.localPath,
        );
        break;
      case 'expenses':
        downloadUrl = await _storageService.uploadExpenseReceiptImage(
          upload.userId,
          upload.recordId,
          upload.localPath,
        );
        break;
      default:
        throw Exception('Invalid category: ${upload.category}');
    }

    print('✅ Uploaded to Storage: $downloadUrl');

    // 3. Atualizar documento no Firestore com a URL
    await _updateRecordWithImageUrl(
      collectionPath: upload.collectionPath,
      recordId: upload.recordId,
      downloadUrl: downloadUrl,
    );

    print(
      '✅ Updated Firestore document: ${upload.collectionPath}/${upload.recordId}',
    );

    // 4. Remover da fila de pendentes
    _pendingUploads.remove(upload.id);

    print('✅ Removed from pending queue: ${upload.id}');
  }

  /// Atualiza registro no Firestore com URL da imagem
  Future<void> _updateRecordWithImageUrl({
    required String collectionPath,
    required String recordId,
    required String downloadUrl,
  }) async {
    await _firestore.collection(collectionPath).doc(recordId).update({
      'receipt_image_url': downloadUrl,
      'updated_at': FieldValue.serverTimestamp(),
      'is_dirty': true, // Força sync downstream
    });
  }

  /// Remove upload pendente específico
  Future<void> removePendingUpload(String uploadId) async {
    if (!_initialized) {
      await initialize();
    }

    _pendingUploads.remove(uploadId);
    print('🗑️ Removed pending upload: $uploadId');
  }

  /// Limpa todos os uploads pendentes (usar com cuidado!)
  Future<void> clearAllPending() async {
    if (!_initialized) {
      await initialize();
    }

    final count = pendingCount;
    _pendingUploads.clear();
    print('🗑️ Cleared $count pending uploads');
  }

  /// Retry manual de um upload específico
  Future<bool> retryUpload(String uploadId) async {
    if (!_initialized) {
      await initialize();
    }

    final upload = _pendingUploads[uploadId];
    if (upload == null) {
      print('❌ Upload not found: $uploadId');
      return false;
    }

    try {
      await _syncSingleImage(upload);
      return true;
    } catch (e) {
      print('❌ Retry failed: $e');

      // Atualiza com erro
      final updatedUpload = upload.withRetry(e.toString());
      _pendingUploads[uploadId] = updatedUpload;

      return false;
    }
  }

  /// Dispose
  void dispose() {
    _progressController.close();
  }
}
