import 'dart:io';
import 'dart:typed_data';
import 'package:core/core.dart' as core;
import 'firebase_storage_service.dart';

/// Result of image processing operation
class ImageProcessingResult {

  const ImageProcessingResult({
    required this.localPath,
    this.downloadUrl,
    this.compressionStats = const {},
    this.wasCompressed = false,
  });
  final String localPath;
  final String? downloadUrl;
  final Map<String, dynamic> compressionStats;
  final bool wasCompressed;
}

/// Unified service for handling receipt images
/// Combines compression and upload in a single operation
class ReceiptImageService {

  ReceiptImageService(
    this._compressionService,
    this._storageService,
    this._connectivityService,
  );
  final core.ImageCompressionService _compressionService;
  final FirebaseStorageService _storageService;
  final core.ConnectivityService _connectivityService;

  /// Process and upload fuel receipt image
  Future<ImageProcessingResult> processFuelReceiptImage({
    required String userId,
    required String fuelSupplyId,
    required String imagePath,
    bool compressImage = true,
    bool uploadToFirebase = true,
  }) async {
    return _processReceiptImage(
      userId: userId,
      recordId: fuelSupplyId,
      imagePath: imagePath,
      category: 'fuel',
      compressImage: compressImage,
      uploadToFirebase: uploadToFirebase,
    );
  }

  /// Process and upload maintenance receipt image
  Future<ImageProcessingResult> processMaintenanceReceiptImage({
    required String userId,
    required String maintenanceId,
    required String imagePath,
    bool compressImage = true,
    bool uploadToFirebase = true,
  }) async {
    return _processReceiptImage(
      userId: userId,
      recordId: maintenanceId,
      imagePath: imagePath,
      category: 'maintenance',
      compressImage: compressImage,
      uploadToFirebase: uploadToFirebase,
    );
  }

  /// Process and upload expense receipt image
  Future<ImageProcessingResult> processExpenseReceiptImage({
    required String userId,
    required String expenseId,
    required String imagePath,
    bool compressImage = true,
    bool uploadToFirebase = true,
  }) async {
    return _processReceiptImage(
      userId: userId,
      recordId: expenseId,
      imagePath: imagePath,
      category: 'expenses',
      compressImage: compressImage,
      uploadToFirebase: uploadToFirebase,
    );
  }

  /// Generic method to process receipt images
  Future<ImageProcessingResult> _processReceiptImage({
    required String userId,
    required String recordId,
    required String imagePath,
    required String category,
    bool compressImage = true,
    bool uploadToFirebase = true,
  }) async {
    try {
      String finalImagePath = imagePath;
      Map<String, dynamic> compressionStats = {};
      bool wasCompressed = false;
      bool shouldAggressivelyCompress = false;
      final connectivityResult = await _connectivityService.getConnectivityType();
      connectivityResult.fold(
        (failure) => print('🔌 Erro ao verificar conectividade: ${failure.message}'),
        (connectivityType) {
          shouldAggressivelyCompress = connectivityType == core.ConnectivityType.mobile;
          print('🔌 Conexão: $connectivityType, compressão agressiva: $shouldAggressivelyCompress');
        },
      );
      if (compressImage) {
        final needsCompression = await _compressionService.needsCompression(imagePath);
        if (needsCompression || shouldAggressivelyCompress) {
          final compressedPath = await _compressionService.compressImage(imagePath);
          compressionStats = await _compressionService.getCompressionStats(
            imagePath,
            compressedPath,
          );
          finalImagePath = compressedPath;
          wasCompressed = true;
        }
      }

      String? downloadUrl;
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((failure) => false, (online) => online);
      if (uploadToFirebase && isOnline) {
        print('🔌 Uploading receipt online...');
        switch (category) {
          case 'fuel':
            downloadUrl = await _storageService.uploadFuelReceiptImage(
              userId,
              recordId,
              finalImagePath,
            );
            break;
          case 'maintenance':
            downloadUrl = await _storageService.uploadMaintenanceReceiptImage(
              userId,
              recordId,
              finalImagePath,
            );
            break;
          case 'expenses':
            downloadUrl = await _storageService.uploadExpenseReceiptImage(
              userId,
              recordId,
              finalImagePath,
            );
            break;
          default:
            throw Exception('Invalid category: $category');
        }
      } else if (uploadToFirebase && !isOnline) {
        print('🔌 Offline - receipt saved locally, will upload when online');
      }

      return ImageProcessingResult(
        localPath: finalImagePath,
        downloadUrl: downloadUrl,
        compressionStats: {
          ...compressionStats,
          'connectivity_aware': true,
          'was_offline': !isOnline,
          'aggressive_compression': shouldAggressivelyCompress,
        },
        wasCompressed: wasCompressed,
      );
    } catch (e) {
      throw Exception('Failed to process receipt image: $e');
    }
  }

  /// Process image from bytes (for camera capture)
  Future<ImageProcessingResult> processImageFromBytes({
    required String userId,
    required String recordId,
    required String category,
    required Uint8List imageBytes,
    bool compressImage = true,
    bool uploadToFirebase = true,
  }) async {
    try {
      Uint8List finalImageBytes = imageBytes;
      Map<String, dynamic> compressionStats = {};
      bool wasCompressed = false;
      if (compressImage) {
        final compressedBytes = await _compressionService.compressImageBytes(imageBytes);
        if (compressedBytes.length < imageBytes.length) {
          finalImageBytes = compressedBytes;
          wasCompressed = true;
          compressionStats = {
            'originalSize': imageBytes.length,
            'compressedSize': compressedBytes.length,
            'spaceSaved': imageBytes.length - compressedBytes.length,
            'spaceSavedPercent': ((imageBytes.length - compressedBytes.length) / imageBytes.length * 100).round(),
          };
        }
      }

      String? downloadUrl;
      if (uploadToFirebase) {
        downloadUrl = await _storageService.uploadReceiptImageBytes(
          userId,
          recordId,
          category,
          finalImageBytes,
        );
      }
      final localPath = await _saveImageBytesLocally(finalImageBytes, recordId);

      return ImageProcessingResult(
        localPath: localPath,
        downloadUrl: downloadUrl,
        compressionStats: compressionStats,
        wasCompressed: wasCompressed,
      );
    } catch (e) {
      throw Exception('Failed to process image from bytes: $e');
    }
  }

  /// Save image bytes to local storage
  Future<String> _saveImageBytesLocally(Uint8List bytes, String recordId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${recordId}_$timestamp.webp';
      final tempFile = File('/tmp/$fileName');
      await tempFile.writeAsBytes(bytes);
      final finalPath = await _compressionService.compressImage(tempFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      return finalPath;
    } catch (e) {
      throw Exception('Failed to save image locally: $e');
    }
  }

  /// Delete receipt image (both local and remote)
  Future<void> deleteReceiptImage({
    String? localPath,
    String? downloadUrl,
  }) async {
    final futures = <Future<void>>[];
    if (localPath != null) {
      futures.add(_compressionService.deleteCompressedImage(localPath));
    }
    if (downloadUrl != null) {
      futures.add(_storageService.deleteReceiptImage(downloadUrl));
    }

    await Future.wait(futures, eagerError: false);
  }

  /// Validate image file
  Future<bool> isValidImage(String imagePath) async {
    return await _compressionService.isValidImage(imagePath);
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(String imagePath) async {
    return await _compressionService.getImageDimensions(imagePath);
  }

  /// Get image file size
  Future<int> getImageSize(String imagePath) async {
    return await _compressionService.getImageSize(imagePath);
  }

  /// Check if image needs compression
  Future<bool> needsCompression(String imagePath) async {
    return await _compressionService.needsCompression(imagePath);
  }

  /// Cleanup old images (both local and remote)
  Future<void> cleanupOldImages(String userId, {int daysOld = 30}) async {
    final futures = [
      _compressionService.cleanupOldImages(),
      _storageService.cleanupOldImages(userId, daysOld: daysOld),
    ];
    
    await Future.wait(futures, eagerError: false);
  }

  /// Batch delete multiple images
  Future<void> batchDeleteImages({
    List<String>? localPaths,
    List<String>? downloadUrls,
  }) async {
    final futures = <Future<void>>[];
    if (localPaths != null) {
      for (final path in localPaths) {
        futures.add(_compressionService.deleteCompressedImage(path));
      }
    }
    if (downloadUrls != null) {
      futures.add(_storageService.batchDeleteImages(downloadUrls));
    }

    await Future.wait(futures, eagerError: false);
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats(String userId) async {
    try {
      final localStats = await _getLocalStorageStats();
      final remoteStats = await _storageService.getUserStorageUsage(userId);
      
      return {
        'localUsage': localStats,
        'remoteUsage': remoteStats,
        'totalUsage': localStats + remoteStats,
      };
    } catch (e) {
      return {
        'localUsage': 0,
        'remoteUsage': 0,
        'totalUsage': 0,
      };
    }
  }

  /// Get local storage usage
  Future<int> _getLocalStorageStats() async {
    return 0;
  }

  /// Sync local images to Firebase (for offline scenarios)
  Future<List<String>> syncLocalImagesToFirebase({
    required String userId,
    required List<String> localPaths,
    required String category,
    required List<String> recordIds,
  }) async {
    if (localPaths.length != recordIds.length) {
      throw Exception('Local paths and record IDs must have the same length');
    }

    final downloadUrls = <String>[];
    
    for (int i = 0; i < localPaths.length; i++) {
      try {
        final downloadUrl = await _storageService.uploadReceiptImageBytes(
          userId,
          recordIds[i],
          category,
          await File(localPaths[i]).readAsBytes(),
        );
        downloadUrls.add(downloadUrl);
      } catch (e) {
        downloadUrls.add('');
      }
    }
    
    return downloadUrls;
  }
}