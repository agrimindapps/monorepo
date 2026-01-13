import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// Firebase Storage service for task attachments
/// Pattern based on app-gasometer's FirebaseStorageService
class TaskAttachmentStorageService {
  final FirebaseStorage _storage;

  TaskAttachmentStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Storage path pattern: attachments/{userId}/{taskId}/{attachmentId}_{fileName}
  String _buildStoragePath({
    required String userId,
    required String taskId,
    required String attachmentId,
    required String fileName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\.]'), '_');
    return 'attachments/$userId/$taskId/${attachmentId}_${timestamp}_$sanitizedFileName';
  }

  /// Upload file to Firebase Storage
  Future<Either<Failure, String>> uploadAttachment({
    required File file,
    required String userId,
    required String taskId,
    required String attachmentId,
    required String fileName,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final path = _buildStoragePath(
        userId: userId,
        taskId: taskId,
        attachmentId: attachmentId,
        fileName: fileName,
      );

      final ref = _storage.ref().child(path);
      
      // Set metadata
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'userId': userId,
          'taskId': taskId,
          'attachmentId': attachmentId,
          'originalFileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload with progress tracking
      final uploadTask = ref.putFile(file, metadata);

      // Listen to progress
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        if (onProgress != null && taskSnapshot.totalBytes > 0) {
          final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          onProgress(progress);
        }
      });

      // Wait for upload with 60 second timeout
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout after 60 seconds'),
      );

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(Failure('Firebase error: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Upload failed: $e'));
    }
  }

  /// Upload bytes (for web or already compressed data)
  Future<Either<Failure, String>> uploadBytes({
    required List<int> bytes,
    required String userId,
    required String taskId,
    required String attachmentId,
    required String fileName,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final path = _buildStoragePath(
        userId: userId,
        taskId: taskId,
        attachmentId: attachmentId,
        fileName: fileName,
      );

      final ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'userId': userId,
          'taskId': taskId,
          'attachmentId': attachmentId,
          'originalFileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(bytes as Uint8List, metadata);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        if (onProgress != null && taskSnapshot.totalBytes > 0) {
          final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          onProgress(progress);
        }
      });

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout after 60 seconds'),
      );

      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(Failure('Firebase error: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Upload failed: $e'));
    }
  }

  /// Delete attachment from storage
  Future<Either<Failure, void>> deleteAttachment(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // Already deleted, not an error
        return const Right(null);
      }
      return Left(Failure('Delete failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Delete failed: $e'));
    }
  }

  /// Delete all attachments for a task
  Future<Either<Failure, int>> deleteTaskAttachments({
    required String userId,
    required String taskId,
  }) async {
    try {
      final path = 'attachments/$userId/$taskId/';
      final ref = _storage.ref().child(path);
      
      final listResult = await ref.listAll();
      int deletedCount = 0;

      for (final item in listResult.items) {
        try {
          await item.delete();
          deletedCount++;
        } catch (e) {
          // Log but continue
          print('Failed to delete ${item.fullPath}: $e');
        }
      }

      return Right(deletedCount);
    } on FirebaseException catch (e) {
      return Left(Failure('Batch delete failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Batch delete failed: $e'));
    }
  }

  /// Get metadata for an attachment
  Future<Either<Failure, Map<String, dynamic>>> getMetadata(
    String downloadUrl,
  ) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      
      return Right({
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      });
    } on FirebaseException catch (e) {
      return Left(Failure('Get metadata failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Get metadata failed: $e'));
    }
  }
}
