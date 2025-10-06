import 'dart:convert';

import 'package:core/core.dart';

import '../models/location_data.dart';
import '../models/personal_info.dart';
import '../models/user_credentials.dart';

/// Plantis-specific storage adapter providing backward compatibility
/// Bridges enhanced core services with existing Plantis storage interfaces
class PlantisStorageAdapter {
  final EnhancedSecureStorageService _secureStorage;
  final EnhancedEncryptedStorageService _encryptedStorage;

  PlantisStorageAdapter({
    required EnhancedSecureStorageService secureStorage,
    required EnhancedEncryptedStorageService encryptedStorage,
  }) : _secureStorage = secureStorage,
       _encryptedStorage = encryptedStorage;

  /// Store user credentials securely (backward compatible)
  Future<void> storeUserCredentials(UserCredentials credentials) async {
    final result = await _secureStorage.storeSecureData<UserCredentials>(
      key: 'user_credentials',
      data: credentials,
      serializer: UserCredentialsSerializer(),
    );

    result.fold(
      (failure) =>
          throw Exception(
            'Failed to store user credentials: ${failure.message}',
          ),
      (_) => <String, dynamic>{},
    );
  }

  /// Retrieve user credentials (backward compatible)
  Future<UserCredentials?> getUserCredentials() async {
    final result = await _secureStorage.getSecureData<UserCredentials>(
      key: 'user_credentials',
      serializer: UserCredentialsSerializer(),
    );

    return result.fold((failure) => null, (data) => data);
  }

  /// Store location data securely (backward compatible)
  Future<void> storeLocationData(LocationData locationData) async {
    final result = await _secureStorage.storeSecureData<LocationData>(
      key: 'location_data',
      data: locationData,
      serializer: LocationDataSerializer(),
    );

    result.fold(
      (failure) =>
          throw Exception('Failed to store location data: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Retrieve location data (backward compatible)
  Future<LocationData?> getLocationData() async {
    final result = await _secureStorage.getSecureData<LocationData>(
      key: 'location_data',
      serializer: LocationDataSerializer(),
    );

    return result.fold((failure) => null, (data) => data);
  }

  /// Store personal information securely (backward compatible)
  Future<void> storePersonalInfo(PersonalInfo personalInfo) async {
    final result = await _secureStorage.storeSecureData<PersonalInfo>(
      key: 'personal_info',
      data: personalInfo,
      serializer: PersonalInfoSerializer(),
    );

    result.fold(
      (failure) =>
          throw Exception('Failed to store personal info: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Retrieve personal information (backward compatible)
  Future<PersonalInfo?> getPersonalInfo() async {
    final result = await _secureStorage.getSecureData<PersonalInfo>(
      key: 'personal_info',
      serializer: PersonalInfoSerializer(),
    );

    return result.fold((failure) => null, (data) => data);
  }

  /// Get or create Hive encryption key (backward compatible)
  Future<List<int>> getOrCreateHiveEncryptionKey() async {
    final result = await _secureStorage.getOrCreateEncryptionKey(
      keyName: 'hive_encryption_key',
    );

    return result.fold(
      (failure) =>
          throw Exception('Failed to get encryption key: ${failure.message}'),
      (key) => key,
    );
  }

  /// Store biometric data (backward compatible)
  Future<void> storeBiometricData(String biometricHash) async {
    final result = await _secureStorage.storeBiometricHash(biometricHash);

    result.fold(
      (failure) =>
          throw Exception('Failed to store biometric data: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Check if secure storage is available (backward compatible)
  Future<bool> isSecureStorageAvailable() async {
    return await _secureStorage.isSecureStorageAvailable();
  }

  /// Clear all secure data (backward compatible)
  Future<void> clearAllSecureData() async {
    final result = await _secureStorage.clearAllSecureData();

    result.fold(
      (failure) =>
          throw Exception('Failed to clear secure data: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Get encrypted box with error handling (backward compatible)
  Future<Box<String>> getEncryptedBox(String boxName) async {
    final result = await _encryptedStorage.getEncryptedBox(boxName);

    return result.fold(
      (failure) =>
          throw Exception('Failed to get encrypted box: ${failure.message}'),
      (box) => box,
    );
  }

  /// Get sensitive data box (backward compatible)
  Future<Box<String>> getSensitiveDataBox() async {
    final result = await _encryptedStorage.getSensitiveDataBox();

    return result.fold(
      (failure) =>
          throw Exception(
            'Failed to get sensitive data box: ${failure.message}',
          ),
      (box) => box,
    );
  }

  /// Get PII data box (backward compatible)
  Future<Box<String>> getPiiDataBox() async {
    final result = await _encryptedStorage.getPiiDataBox();

    return result.fold(
      (failure) =>
          throw Exception('Failed to get PII data box: ${failure.message}'),
      (box) => box,
    );
  }

  /// Get location data box (backward compatible)
  Future<Box<String>> getLocationDataBox() async {
    final result = await _encryptedStorage.getLocationDataBox();

    return result.fold(
      (failure) =>
          throw Exception(
            'Failed to get location data box: ${failure.message}',
          ),
      (box) => box,
    );
  }

  /// Store any type of secure data with type safety
  Future<void> storeSecureDataTyped<T>({
    required String key,
    required T data,
    SecureDataSerializer<T>? serializer,
  }) async {
    final result = await _secureStorage.storeSecureData<T>(
      key: key,
      data: data,
      serializer: serializer,
    );

    result.fold(
      (failure) =>
          throw Exception('Failed to store secure data: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Retrieve any type of secure data with type safety
  Future<T?> getSecureDataTyped<T>({
    required String key,
    SecureDataSerializer<T>? serializer,
  }) async {
    final result = await _secureStorage.getSecureData<T>(
      key: key,
      serializer: serializer,
    );

    return result.fold((failure) => null, (data) => data);
  }

  /// Store encrypted data in custom boxes
  Future<void> storeEncryptedDataTyped<T>({
    required String boxName,
    required String key,
    required T data,
  }) async {
    final result = await _encryptedStorage.storeEncryptedData<T>(
      boxName: boxName,
      key: key,
      data: data,
    );

    result.fold(
      (failure) =>
          throw Exception('Failed to store encrypted data: ${failure.message}'),
      (_) => <String, dynamic>{},
    );
  }

  /// Retrieve encrypted data from custom boxes
  Future<T?> getEncryptedDataTyped<T>({
    required String boxName,
    required String key,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final result = await _encryptedStorage.getEncryptedData<T>(
      boxName: boxName,
      key: key,
      fromJson: fromJson,
    );

    return result.fold((failure) => null, (data) => data);
  }
}

/// Serializer for UserCredentials
class UserCredentialsSerializer
    implements SecureDataSerializer<UserCredentials> {
  @override
  String serialize(UserCredentials data) => jsonEncode(data.toJson());

  @override
  UserCredentials deserialize(String json) =>
      UserCredentials.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

/// Serializer for LocationData
class LocationDataSerializer implements SecureDataSerializer<LocationData> {
  @override
  String serialize(LocationData data) => jsonEncode(data.toJson());

  @override
  LocationData deserialize(String json) =>
      LocationData.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

/// Serializer for PersonalInfo
class PersonalInfoSerializer implements SecureDataSerializer<PersonalInfo> {
  @override
  String serialize(PersonalInfo data) => jsonEncode(data.toJson());

  @override
  PersonalInfo deserialize(String json) =>
      PersonalInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

/// Legacy adapter that provides the same functionality as SecureStorageService
/// Ensures zero breaking changes during migration
class SecureStorageServiceAdapter {
  final PlantisStorageAdapter _adapter;

  SecureStorageServiceAdapter(this._adapter);

  Future<void> storeUserCredentials(UserCredentials credentials) =>
      _adapter.storeUserCredentials(credentials);

  Future<UserCredentials?> getUserCredentials() =>
      _adapter.getUserCredentials();

  Future<void> storeLocationData(LocationData locationData) =>
      _adapter.storeLocationData(locationData);

  Future<LocationData?> getLocationData() => _adapter.getLocationData();

  Future<void> storePersonalInfo(PersonalInfo personalInfo) =>
      _adapter.storePersonalInfo(personalInfo);

  Future<PersonalInfo?> getPersonalInfo() => _adapter.getPersonalInfo();

  Future<List<int>> getOrCreateHiveEncryptionKey() =>
      _adapter.getOrCreateHiveEncryptionKey();

  Future<void> storeBiometricData(String biometricHash) =>
      _adapter.storeBiometricData(biometricHash);

  Future<bool> isSecureStorageAvailable() =>
      _adapter.isSecureStorageAvailable();

  Future<void> clearAllSecureData() => _adapter.clearAllSecureData();
}
