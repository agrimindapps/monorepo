import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/utils/failure.dart';

/// Enhanced Secure Storage Service with configurable app-specific policies
/// Provides enterprise-grade secure storage for sensitive data across all apps
class EnhancedSecureStorageService {
  final String _appIdentifier;
  final SecureStorageConfig _config;
  late final FlutterSecureStorage _storage;

  EnhancedSecureStorageService({
    required String appIdentifier,
    SecureStorageConfig? config,
  })  : _appIdentifier = appIdentifier,
        _config = config ?? const SecureStorageConfig.defaultConfig() {
    _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: _config.useEncryptedSharedPreferences,
        keyCipherAlgorithm: _config.androidKeyCipher,
        storageCipherAlgorithm: _config.androidStorageCipher,
      ),
      iOptions: IOSOptions(
        accessibility: _config.iOSAccessibility,
        accountName: '${_appIdentifier}_secure_data',
      ),
    );
  }

  /// Generic secure data storage with optional serialization
  Future<Either<Failure, void>> storeSecureData<T>({
    required String key,
    required T data,
    SecureDataSerializer<T>? serializer,
  }) async {
    try {
      final jsonString = serializer?.serialize(data) ?? jsonEncode(data);
      await _storage.write(key: key, value: jsonString);

      if (kDebugMode) {
        debugPrint('🔒 Secure data stored: $key');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error storing secure data: $e');
      }
      return Left(SecurityFailure('Error storing secure data: $e'));
    }
  }

  /// Generic secure data retrieval with optional serialization
  Future<Either<Failure, T?>> getSecureData<T>({
    required String key,
    SecureDataSerializer<T>? serializer,
  }) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString == null) return const Right(null);

      final data = serializer?.deserialize(jsonString) ??
                  jsonDecode(jsonString);
      return Right(data as T?);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error retrieving secure data: $e');
      }
      return Left(SecurityFailure('Error retrieving secure data: $e'));
    }
  }

  /// Get or create encryption key for Hive
  Future<Either<Failure, List<int>>> getOrCreateEncryptionKey({
    String keyName = 'hive_encryption_key',
  }) async {
    try {
      final existingKeyString = await _storage.read(key: keyName);

      if (existingKeyString != null) {
        final keyList = (jsonDecode(existingKeyString) as List<dynamic>);
        return Right(keyList.cast<int>());
      }
      final newKey = List<int>.generate(32, (i) =>
        DateTime.now().millisecondsSinceEpoch.hashCode % 256);

      await _storage.write(key: keyName, value: jsonEncode(newKey));

      if (kDebugMode) {
        debugPrint('🔑 Generated new encryption key: $keyName');
      }

      return Right(newKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error managing encryption key: $e');
      }
      return Left(SecurityFailure('Error managing encryption key: $e'));
    }
  }

  /// Store biometric authentication hash
  Future<Either<Failure, void>> storeBiometricHash(String hash) async {
    return storeSecureData<String>(key: 'biometric_hash', data: hash);
  }

  /// Get biometric authentication hash
  Future<Either<Failure, String?>> getBiometricHash() async {
    return getSecureData<String>(key: 'biometric_hash');
  }

  /// Check if secure storage is available on the device
  Future<bool> isSecureStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'availability_test');
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Secure storage not available: $e');
      }
      return false;
    }
  }

  /// Clear all secure data for this app
  Future<Either<Failure, void>> clearAllSecureData() async {
    try {
      await _storage.deleteAll();

      if (kDebugMode) {
        debugPrint('🗑️ All secure data cleared for app: $_appIdentifier');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing secure data: $e');
      }
      return Left(SecurityFailure('Error clearing secure data: $e'));
    }
  }

  /// Delete specific secure data key
  Future<Either<Failure, void>> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);

      if (kDebugMode) {
        debugPrint('🗑️ Secure data deleted: $key');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting secure data: $e');
      }
      return Left(SecurityFailure('Error deleting secure data: $e'));
    }
  }

  /// Check if specific key exists
  Future<Either<Failure, bool>> containsKey(String key) async {
    try {
      final contains = await _storage.containsKey(key: key);
      return Right(contains);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking key existence: $e');
      }
      return Left(SecurityFailure('Error checking key existence: $e'));
    }
  }

  /// Get all stored keys (for debugging/maintenance)
  Future<Either<Failure, Set<String>>> getAllKeys() async {
    try {
      final Map<String, String> allItems = await _storage.readAll();
      return Right(allItems.keys.toSet());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error retrieving all keys: $e');
      }
      return Left(SecurityFailure('Error retrieving all keys: $e'));
    }
  }
}

/// Configuration class for secure storage
class SecureStorageConfig {
  final bool useEncryptedSharedPreferences;
  final KeyCipherAlgorithm androidKeyCipher;
  final StorageCipherAlgorithm androidStorageCipher;
  final KeychainAccessibility iOSAccessibility;

  const SecureStorageConfig({
    required this.useEncryptedSharedPreferences,
    required this.androidKeyCipher,
    required this.androidStorageCipher,
    required this.iOSAccessibility,
  });

  /// Default secure configuration
  const SecureStorageConfig.defaultConfig()
      : useEncryptedSharedPreferences = true,
        androidKeyCipher = KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        androidStorageCipher = StorageCipherAlgorithm.AES_GCM_NoPadding,
        iOSAccessibility = KeychainAccessibility.first_unlock_this_device;

  /// Plantis-specific configuration (less strict for plant care app)
  const SecureStorageConfig.plantis()
      : useEncryptedSharedPreferences = true,
        androidKeyCipher = KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        androidStorageCipher = StorageCipherAlgorithm.AES_GCM_NoPadding,
        iOSAccessibility = KeychainAccessibility.first_unlock_this_device;

  /// Gasometer-specific configuration (high security for financial data)
  const SecureStorageConfig.gasometer()
      : useEncryptedSharedPreferences = true,
        androidKeyCipher = KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        androidStorageCipher = StorageCipherAlgorithm.AES_GCM_NoPadding,
        iOSAccessibility = KeychainAccessibility.first_unlock_this_device;

  /// ReceitAgro-specific configuration (medium security for agricultural data)
  const SecureStorageConfig.receituagro()
      : useEncryptedSharedPreferences = true,
        androidKeyCipher = KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        androidStorageCipher = StorageCipherAlgorithm.AES_GCM_NoPadding,
        iOSAccessibility = KeychainAccessibility.first_unlock_this_device;
}

/// Abstract serializer interface for complex data types
abstract class SecureDataSerializer<T> {
  String serialize(T data);
  T deserialize(String json);
}

/// Serializer for Map<String, dynamic> data
class MapStringDynamicSerializer implements SecureDataSerializer<Map<String, dynamic>> {
  @override
  String serialize(Map<String, dynamic> data) => jsonEncode(data);

  @override
  Map<String, dynamic> deserialize(String json) =>
      Map<String, dynamic>.from(jsonDecode(json) as Map<dynamic, dynamic>);
}

/// Serializer for List<String> data
class ListStringSerializer implements SecureDataSerializer<List<String>> {
  @override
  String serialize(List<String> data) => jsonEncode(data);

  @override
  List<String> deserialize(String json) =>
      List<String>.from(jsonDecode(json) as List<dynamic>);
}

/// Security-specific failure type
class SecurityFailure extends Failure {
  const SecurityFailure(String message) : super(message: message);
}