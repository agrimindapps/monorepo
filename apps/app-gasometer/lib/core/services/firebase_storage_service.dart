import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Service for uploading and managing files in Firebase Storage
/// Handles receipt images for fuel, maintenance, and expense records
class FirebaseStorageService {
  static const String _receiptsBasePath = 'receipts';
  static const int _uploadTimeoutSeconds = 60;
  
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload receipt image for fuel supply
  Future<String> uploadFuelReceiptImage(
    String userId,
    String fuelSupplyId,
    String imagePath,
  ) async {
    return _uploadReceiptImage(
      userId: userId,
      recordId: fuelSupplyId,
      imagePath: imagePath,
      category: 'fuel',
    );
  }

  /// Upload receipt image for maintenance
  Future<String> uploadMaintenanceReceiptImage(
    String userId,
    String maintenanceId,
    String imagePath,
  ) async {
    return _uploadReceiptImage(
      userId: userId,
      recordId: maintenanceId,
      imagePath: imagePath,
      category: 'maintenance',
    );
  }

  /// Upload receipt image for expense
  Future<String> uploadExpenseReceiptImage(
    String userId,
    String expenseId,
    String imagePath,
  ) async {
    return _uploadReceiptImage(
      userId: userId,
      recordId: expenseId,
      imagePath: imagePath,
      category: 'expenses',
    );
  }

  /// Upload receipt image from bytes
  Future<String> uploadReceiptImageBytes(
    String userId,
    String recordId,
    String category,
    Uint8List imageBytes,
  ) async {
    try {
      final fileName = _generateFileName(recordId, 'webp');
      final ref = _getStorageReference(userId, category, fileName);
      
      final metadata = SettableMetadata(
        contentType: 'image/webp',
        customMetadata: {
          'userId': userId,
          'recordId': recordId,
          'category': category,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(imageBytes, metadata);
      
      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Can emit progress events here if needed
      });

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: _uploadTimeoutSeconds),
      );
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      throw Exception('Failed to upload receipt image: $e');
    }
  }

  /// Generic method to upload receipt images
  Future<String> _uploadReceiptImage({
    required String userId,
    required String recordId,
    required String imagePath,
    required String category,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }

      final fileExtension = path.extension(imagePath).toLowerCase();
      final fileName = _generateFileName(recordId, fileExtension.replaceAll('.', ''));
      final ref = _getStorageReference(userId, category, fileName);
      
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
        customMetadata: {
          'userId': userId,
          'recordId': recordId,
          'category': category,
          'originalFileName': path.basename(imagePath),
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // Can emit progress events here if needed
      });

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: _uploadTimeoutSeconds),
      );
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      throw Exception('Failed to upload receipt image: $e');
    }
  }

  /// Delete receipt image from Firebase Storage
  Future<void> deleteReceiptImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // Silently handle deletion errors - image might already be deleted
    }
  }

  /// Get storage reference for receipt image
  Reference _getStorageReference(String userId, String category, String fileName) {
    return _storage.ref().child('$_receiptsBasePath/$userId/$category/$fileName');
  }

  /// Generate unique filename for receipt image
  String _generateFileName(String recordId, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${recordId}_$timestamp.$extension';
  }

  /// Get content type based on file extension
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Get upload progress stream for monitoring
  Stream<double> getUploadProgress(String userId, String recordId, String category) {
    // This would need to be implemented with a state management solution
    // For now, returning empty stream
    return const Stream.empty();
  }

  /// Check if user has enough storage quota (Firebase has generous limits)
  Future<bool> hasStorageQuota(String userId) async {
    try {
      // Firebase Storage has very generous free tier (5GB)
      // For basic receipt images, this should rarely be an issue
      // Could implement actual quota checking if needed
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get storage usage for user (if quota monitoring is needed)
  Future<int> getUserStorageUsage(String userId) async {
    try {
      // This would require listing all user files and summing their sizes
      // Firebase doesn't provide direct quota API
      // For now, returning 0
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// List all receipt images for a user (for cleanup operations)
  Future<List<Reference>> listUserReceiptImages(String userId) async {
    try {
      final userRef = _storage.ref().child('$_receiptsBasePath/$userId');
      final result = await userRef.listAll();
      
      final List<Reference> allFiles = [];
      for (final prefix in result.prefixes) {
        final prefixResult = await prefix.listAll();
        allFiles.addAll(prefixResult.items);
      }
      allFiles.addAll(result.items);
      
      return allFiles;
    } catch (e) {
      return [];
    }
  }

  /// Cleanup old receipt images (older than specified days)
  Future<void> cleanupOldImages(String userId, {int daysOld = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final userImages = await listUserReceiptImages(userId);
      
      for (final imageRef in userImages) {
        try {
          final metadata = await imageRef.getMetadata();
          final uploadedAt = metadata.customMetadata?['uploadedAt'];
          
          if (uploadedAt != null) {
            final uploadDate = DateTime.parse(uploadedAt);
            if (uploadDate.isBefore(cutoffDate)) {
              await imageRef.delete();
            }
          }
        } catch (e) {
          // Continue with next image if one fails
        }
      }
    } catch (e) {
      // Silently handle cleanup errors
    }
  }

  /// Batch delete receipt images
  Future<void> batchDeleteImages(List<String> downloadUrls) async {
    final futures = downloadUrls.map((url) => deleteReceiptImage(url));
    await Future.wait(futures, eagerError: false);
  }

  /// Get image metadata
  Future<FullMetadata?> getImageMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      return null;
    }
  }

  /// Update image metadata
  Future<void> updateImageMetadata(
    String downloadUrl,
    Map<String, String> customMetadata,
  ) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = SettableMetadata(customMetadata: customMetadata);
      await ref.updateMetadata(metadata);
    } catch (e) {
      // Silently handle metadata update errors
    }
  }

  /// Download image to local file
  Future<File?> downloadImageToFile(String downloadUrl, String localPath) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final file = File(localPath);
      
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Get download URL for a storage reference path
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}