import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/result.dart';

/// Serviço para exclusão completa de dados do Firestore e Storage
/// Gerencia exclusão de documentos, subcoleções e arquivos armazenados
class FirestoreDeletionService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreDeletionService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Deleta todos os dados do usuário do Firestore e Storage
  ///
  /// [userId] ID do usuário no Firebase Auth
  /// [subcollections] Lista de subcoleções a serem deletadas
  /// [deleteStorage] Se deve deletar arquivos do Storage (padrão: true)
  Future<Result<FirestoreDeletionResult>> deleteUserData({
    required String userId,
    List<String> subcollections = const [
      'tasks',
      'plants',
      'vehicles',
      'pets',
      'reminders',
      'fuel_records',
      'maintenance_records',
      'prescriptions',
      'diagnoses',
    ],
    bool deleteStorage = true,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔥 FirestoreDeletionService: Starting Firestore deletion for user $userId',
        );
      }

      final result = FirestoreDeletionResult();
      await _deleteUserDocument(userId, result);
      await _deleteSubcollections(userId, subcollections, result);
      if (deleteStorage) {
        await _deleteStorageFiles(userId, result);
      }

      result.completedAt = DateTime.now();

      if (kDebugMode) {
        debugPrint('✅ FirestoreDeletionService: Deletion completed');
        debugPrint(
          '   User document: ${result.userDocumentDeleted ? "✅" : "❌"}',
        );
        debugPrint('   Subcollections: ${result.subcollectionsDeleted.length}');
        debugPrint('   Storage files: ${result.storageFilesDeleted}');
        debugPrint('   Errors: ${result.errors.length}');
      }

      return Result.success(result);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirestoreDeletionService: Unexpected error: $e');
      }

      return Result.error(
        AppErrorFactory.fromFailure(
          UnexpectedFailure('Erro ao deletar dados do Firestore: $e'),
        ),
      );
    }
  }

  /// Deleta o documento principal do usuário
  Future<void> _deleteUserDocument(
    String userId,
    FirestoreDeletionResult result,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Deleting user document: users/$userId');
      }

      await _firestore.collection('users').doc(userId).delete();
      result.userDocumentDeleted = true;

      if (kDebugMode) {
        debugPrint('✅ User document deleted');
      }
    } catch (e) {
      result.errors.add('Failed to delete user document: $e');
      if (kDebugMode) {
        debugPrint('❌ Error deleting user document: $e');
      }
    }
  }

  /// Deleta todas as subcoleções do usuário
  Future<void> _deleteSubcollections(
    String userId,
    List<String> subcollections,
    FirestoreDeletionResult result,
  ) async {
    for (final subcollection in subcollections) {
      try {
        if (kDebugMode) {
          debugPrint(
            '🗑️ Deleting subcollection: users/$userId/$subcollection',
          );
        }

        final snapshot =
            await _firestore
                .collection('users')
                .doc(userId)
                .collection(subcollection)
                .get();

        if (snapshot.docs.isEmpty) {
          if (kDebugMode) {
            debugPrint('   No documents found in $subcollection');
          }
          continue;
        }
        await _deleteBatchedDocuments(snapshot.docs, subcollection, result);

        result.subcollectionsDeleted[subcollection] = snapshot.docs.length;

        if (kDebugMode) {
          debugPrint(
            '✅ Deleted ${snapshot.docs.length} documents from $subcollection',
          );
        }
      } catch (e) {
        result.errors.add('Failed to delete subcollection $subcollection: $e');
        if (kDebugMode) {
          debugPrint('❌ Error deleting $subcollection: $e');
        }
      }
    }
  }

  /// Deleta documentos em batches para respeitar limite do Firestore
  Future<void> _deleteBatchedDocuments(
    List<QueryDocumentSnapshot> docs,
    String subcollection,
    FirestoreDeletionResult result,
  ) async {
    const batchSize = 500;
    final batches = <WriteBatch>[];
    var currentBatch = _firestore.batch();
    var operationCount = 0;

    for (final doc in docs) {
      currentBatch.delete(doc.reference);
      operationCount++;

      if (operationCount == batchSize) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      batches.add(currentBatch);
    }
    for (var i = 0; i < batches.length; i++) {
      try {
        await batches[i].commit();
        if (kDebugMode && batches.length > 1) {
          debugPrint('   Batch ${i + 1}/${batches.length} committed');
        }
      } catch (e) {
        result.errors.add('Failed to commit batch $i for $subcollection: $e');
        if (kDebugMode) {
          debugPrint('❌ Error committing batch $i: $e');
        }
      }
    }
  }

  /// Deleta todos os arquivos do usuário no Storage
  Future<void> _deleteStorageFiles(
    String userId,
    FirestoreDeletionResult result,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Deleting storage files for user $userId');
      }

      final userStorageRef = _storage.ref().child('users/$userId');
      final listResult = await userStorageRef.listAll();
      for (final item in listResult.items) {
        try {
          await item.delete();
          result.storageFilesDeleted++;
        } catch (e) {
          result.errors.add('Failed to delete storage file ${item.name}: $e');
          if (kDebugMode) {
            debugPrint('❌ Error deleting file ${item.name}: $e');
          }
        }
      }
      for (final prefix in listResult.prefixes) {
        await _deleteStoragePrefix(prefix, result);
      }

      if (kDebugMode) {
        debugPrint('✅ Deleted ${result.storageFilesDeleted} storage files');
      }
    } catch (e) {
      result.errors.add('Failed to delete storage files: $e');
      if (kDebugMode) {
        debugPrint('❌ Error deleting storage files: $e');
      }
    }
  }

  /// Recursively delete all files in a storage prefix
  Future<void> _deleteStoragePrefix(
    Reference prefix,
    FirestoreDeletionResult result,
  ) async {
    try {
      final listResult = await prefix.listAll();

      for (final item in listResult.items) {
        try {
          await item.delete();
          result.storageFilesDeleted++;
        } catch (e) {
          result.errors.add('Failed to delete storage file ${item.name}: $e');
        }
      }

      for (final subPrefix in listResult.prefixes) {
        await _deleteStoragePrefix(subPrefix, result);
      }
    } catch (e) {
      result.errors.add('Failed to list storage prefix ${prefix.name}: $e');
    }
  }

  /// Verifica se um usuário tem dados no Firestore
  Future<bool> hasUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking user data: $e');
      }
      return false;
    }
  }

  /// Obtém estatísticas de dados antes da exclusão
  Future<Map<String, dynamic>> getDataStats(
    String userId, {
    List<String> subcollections = const [
      'tasks',
      'plants',
      'vehicles',
      'pets',
      'reminders',
    ],
  }) async {
    final stats = <String, dynamic>{
      'userId': userId,
      'hasUserDocument': false,
      'subcollections': <String, int>{},
      'totalDocuments': 0,
    };

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      stats['hasUserDocument'] = userDoc.exists;
      for (final subcollection in subcollections) {
        try {
          final snapshot =
              await _firestore
                  .collection('users')
                  .doc(userId)
                  .collection(subcollection)
                  .count()
                  .get();

          final count = snapshot.count ?? 0;
          if (count > 0) {
            stats['subcollections'][subcollection] = count;
            stats['totalDocuments'] = (stats['totalDocuments'] as int) + count;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error counting $subcollection: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting data stats: $e');
      }
    }

    return stats;
  }
}

/// Resultado detalhado da exclusão de dados do Firestore
class FirestoreDeletionResult {
  bool userDocumentDeleted = false;
  Map<String, int> subcollectionsDeleted = {};
  int storageFilesDeleted = 0;
  List<String> errors = [];
  DateTime? completedAt;

  bool get isSuccess => userDocumentDeleted && errors.isEmpty;

  int get totalDocumentsDeleted =>
      subcollectionsDeleted.values.fold(0, (sum, count) => sum + count);

  Map<String, dynamic> toMap() {
    return {
      'userDocumentDeleted': userDocumentDeleted,
      'subcollectionsDeleted': subcollectionsDeleted,
      'totalDocumentsDeleted': totalDocumentsDeleted,
      'storageFilesDeleted': storageFilesDeleted,
      'errors': errors,
      'completedAt': completedAt?.toIso8601String(),
      'isSuccess': isSuccess,
    };
  }

  @override
  String toString() {
    return 'FirestoreDeletionResult('
        'isSuccess: $isSuccess, '
        'userDocument: $userDocumentDeleted, '
        'documents: $totalDocumentsDeleted, '
        'files: $storageFilesDeleted, '
        'errors: ${errors.length})';
  }
}
