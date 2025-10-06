import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/repositories/i_encrypted_storage_repository.dart';
import '../../shared/utils/failure.dart';
import 'enhanced_secure_storage_service.dart';

/// Enhanced Encrypted Storage Service with configurable encryption
/// Provides enterprise-grade encrypted Hive boxes for sensitive data
class EnhancedEncryptedStorageService implements IEncryptedStorageRepository {
  final EnhancedSecureStorageService _secureStorage;
  final Map<String, HiveCipher> _ciphers = {};
  final String _appIdentifier;
  bool _isInitialized = false;

  EnhancedEncryptedStorageService({
    required EnhancedSecureStorageService secureStorage,
    String? appIdentifier,
  })  : _secureStorage = secureStorage,
        _appIdentifier = appIdentifier ?? 'app';

  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) return const Right(null);

    try {
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('🔐 Enhanced Encrypted Storage initialized for: $_appIdentifier');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing Enhanced Encrypted Storage: $e');
      }
      return Left(CacheFailure('Error initializing encryption: $e'));
    }
  }

  @override
  Future<Either<Failure, Box<String>>> getEncryptedBox(
    String boxName, {
    String? keyName,
  }) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return Left(initResult.fold((failure) => failure, (_) => throw Exception()));
        }
      }
      final fullBoxName = '${_appIdentifier}_$boxName';
      HiveCipher cipher;
      if (_ciphers.containsKey(fullBoxName)) {
        cipher = _ciphers[fullBoxName]!;
      } else {
        final keyResult = await _secureStorage.getOrCreateEncryptionKey(
          keyName: keyName ?? '${fullBoxName}_key',
        );

        if (keyResult.isLeft()) {
          return Left(keyResult.fold((failure) => failure, (_) => throw Exception()));
        }

        final key = keyResult.fold((_) => throw Exception(), (key) => key);
        cipher = HiveAesCipher(key);
        _ciphers[fullBoxName] = cipher;
      }
      if (!Hive.isBoxOpen(fullBoxName)) {
        final box = await Hive.openBox<String>(fullBoxName, encryptionCipher: cipher);

        if (kDebugMode) {
          debugPrint('📦 Encrypted box opened: $fullBoxName');
        }

        return Right(box);
      }

      return Right(Hive.box<String>(fullBoxName));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error opening encrypted box: $e');
      }
      return Left(CacheFailure('Error opening encrypted box: $e'));
    }
  }

  /// Store encrypted data in specific box
  Future<Either<Failure, void>> storeEncryptedData<T>({
    required String boxName,
    required String key,
    required T data,
  }) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          final jsonData = jsonEncode(data);
          await box.put(key, jsonData);

          if (kDebugMode) {
            debugPrint('🔐 Encrypted data stored: $boxName -> $key');
          }

          return const Right(null);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error storing encrypted data: $e');
          }
          return Left(CacheFailure('Error storing encrypted data: $e'));
        }
      },
    );
  }

  /// Retrieve encrypted data from specific box
  Future<Either<Failure, T?>> getEncryptedData<T>({
    required String boxName,
    required String key,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          final jsonData = box.get(key);
          if (jsonData == null) return const Right(null);

          if (fromJson != null) {
            final Map<String, dynamic> json = jsonDecode(jsonData) as Map<String, dynamic>;
            return Right(fromJson(json));
          } else {
            return Right(jsonDecode(jsonData) as T);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error retrieving encrypted data: $e');
          }
          return Left(CacheFailure('Error retrieving encrypted data: $e'));
        }
      },
    );
  }

  /// Delete encrypted data from specific box
  Future<Either<Failure, void>> deleteEncryptedData({
    required String boxName,
    required String key,
  }) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          await box.delete(key);

          if (kDebugMode) {
            debugPrint('🗑️ Encrypted data deleted: $boxName -> $key');
          }

          return const Right(null);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error deleting encrypted data: $e');
          }
          return Left(CacheFailure('Error deleting encrypted data: $e'));
        }
      },
    );
  }

  /// Clear all data in specific encrypted box
  @override
  Future<Either<Failure, void>> clearEncryptedBox(String boxName) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          await box.clear();

          if (kDebugMode) {
            debugPrint('🗑️ Encrypted box cleared: $boxName');
          }

          return const Right(null);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error clearing encrypted box: $e');
          }
          return Left(CacheFailure('Error clearing encrypted box: $e'));
        }
      },
    );
  }

  /// Predefined box getters for common use cases

  /// Get sensitive data box (for credentials, tokens, etc.)
  Future<Either<Failure, Box<String>>> getSensitiveDataBox() async {
    return getEncryptedBox('sensitive_data');
  }

  /// Get PII (Personally Identifiable Information) box
  Future<Either<Failure, Box<String>>> getPiiDataBox() async {
    return getEncryptedBox('pii_data');
  }

  /// Get location data box
  Future<Either<Failure, Box<String>>> getLocationDataBox() async {
    return getEncryptedBox('location_data');
  }

  /// Get financial data box (for gasometer app, etc.)
  Future<Either<Failure, Box<String>>> getFinancialDataBox() async {
    return getEncryptedBox('financial_data');
  }

  /// Get backup data box (for encrypted backups)
  Future<Either<Failure, Box<String>>> getBackupDataBox() async {
    return getEncryptedBox('backup_data');
  }

  /// Check if encrypted box exists and has data
  Future<Either<Failure, bool>> hasEncryptedData({
    required String boxName,
    required String key,
  }) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          return Right(box.containsKey(key));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error checking encrypted data existence: $e');
          }
          return Left(CacheFailure('Error checking encrypted data existence: $e'));
        }
      },
    );
  }

  /// Get all keys from encrypted box
  Future<Either<Failure, Set<String>>> getEncryptedBoxKeys(String boxName) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          return Right(box.keys.cast<String>().toSet());
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error getting encrypted box keys: $e');
          }
          return Left(CacheFailure('Error getting encrypted box keys: $e'));
        }
      },
    );
  }

  /// Close specific encrypted box
  Future<Either<Failure, void>> closeEncryptedBox(String boxName) async {
    try {
      final fullBoxName = '${_appIdentifier}_$boxName';

      if (Hive.isBoxOpen(fullBoxName)) {
        await Hive.box<String>(fullBoxName).close();
        _ciphers.remove(fullBoxName);

        if (kDebugMode) {
          debugPrint('📦 Encrypted box closed: $fullBoxName');
        }
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error closing encrypted box: $e');
      }
      return Left(CacheFailure('Error closing encrypted box: $e'));
    }
  }

  /// Close all encrypted boxes for this app
  Future<Either<Failure, void>> closeAllEncryptedBoxes() async {
    try {
      final boxesToClose = _ciphers.keys.toList();

      for (final boxName in boxesToClose) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<String>(boxName).close();
        }
      }

      _ciphers.clear();

      if (kDebugMode) {
        debugPrint('📦 All encrypted boxes closed for: $_appIdentifier');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error closing all encrypted boxes: $e');
      }
      return Left(CacheFailure('Error closing all encrypted boxes: $e'));
    }
  }

  /// Utility method to backup encrypted data as JSON
  Future<Either<Failure, Map<String, dynamic>>> exportEncryptedBoxData(String boxName) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          final Map<String, dynamic> exportData = {};

          for (final key in box.keys) {
            final value = box.get(key);
            if (value != null) {
              exportData[key.toString()] = value;
            }
          }

          if (kDebugMode) {
            debugPrint('📤 Exported encrypted box data: $boxName (${exportData.length} items)');
          }

          return Right(exportData);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error exporting encrypted box data: $e');
          }
          return Left(CacheFailure('Error exporting encrypted box data: $e'));
        }
      },
    );
  }

  /// Store encrypted data with interface signature
  @override
  Future<Either<Failure, void>> storeEncrypted<T extends Object>(
    String key,
    T data,
    String boxName, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    return storeEncryptedData<T>(
      boxName: boxName,
      key: key,
      data: data,
    );
  }

  /// Get encrypted data with interface signature
  @override
  Future<Either<Failure, T?>> getEncrypted<T extends Object>(
    String key,
    String boxName, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return getEncryptedData<T>(
      boxName: boxName,
      key: key,
      fromJson: fromJson,
    );
  }

  /// Delete encrypted data with interface signature
  @override
  Future<Either<Failure, void>> deleteEncrypted(String key, String boxName) async {
    return deleteEncryptedData(boxName: boxName, key: key);
  }

  /// Clear all encrypted data across all boxes
  @override
  Future<Either<Failure, void>> clearAllEncrypted() async {
    try {
      final boxesToClear = _ciphers.keys.toList();

      for (final boxName in boxesToClear) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<String>(boxName).clear();
        }
      }

      if (kDebugMode) {
        debugPrint('🗑️ All encrypted data cleared for: $_appIdentifier');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing all encrypted data: $e');
      }
      return Left(CacheFailure('Error clearing all encrypted data: $e'));
    }
  }

  /// Get encryption status for monitoring
  @override
  Map<String, dynamic> getEncryptionStatus() {
    return {
      'app_identifier': _appIdentifier,
      'initialized': _isInitialized,
      'active_boxes': _ciphers.keys.toList(),
      'total_boxes': _ciphers.length,
      'encryption_algorithm': 'HiveAesCipher',
    };
  }

  /// Check if box is open
  @override
  bool isBoxOpen(String boxName) {
    final fullBoxName = '${_appIdentifier}_$boxName';
    return Hive.isBoxOpen(fullBoxName);
  }

  /// Get all keys from a specific box
  @override
  Future<Either<Failure, List<String>>> getKeysFromBox(String boxName) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          final keys = box.keys.cast<String>().toList();
          return Right(keys);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error getting keys from box: $e');
          }
          return Left(CacheFailure('Error getting keys from box: $e'));
        }
      },
    );
  }

  /// Get box size (number of entries)
  @override
  Future<Either<Failure, int>> getBoxSize(String boxName) async {
    final boxResult = await getEncryptedBox(boxName);

    return boxResult.fold(
      (failure) => Left(failure),
      (box) async {
        try {
          return Right(box.length);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error getting box size: $e');
          }
          return Left(CacheFailure('Error getting box size: $e'));
        }
      },
    );
  }

  /// Clear encrypted box with interface signature
}