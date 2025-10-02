import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Secure storage service for sensitive data
/// Wrapper around EnhancedSecureStorageService from core package
class SecureStorageService {
  static SecureStorageService? _instance;
  static SecureStorageService get instance =>
      _instance ??= SecureStorageService._();

  SecureStorageService._();

  // Use core's EnhancedSecureStorageService
  late final EnhancedSecureStorageService _coreStorage =
      EnhancedSecureStorageService(
    appIdentifier: 'plantis',
    config: const SecureStorageConfig.plantis(),
  );

  // Keys for sensitive data
  static const String _userCredentialsKey = 'user_credentials';
  static const String _locationDataKey = 'location_data';
  static const String _personalInfoKey = 'personal_info';
  static const String _encryptionKeyKey = 'hive_encryption_key';
  static const String _biometricDataKey = 'biometric_data';

  /// Store user credentials securely
  Future<void> storeUserCredentials(UserCredentials credentials) async {
    final result = await _coreStorage.storeSecureData(
      key: _userCredentialsKey,
      data: credentials.toJson(),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Error storing user credentials: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🔒 User credentials stored securely'),
    );
  }

  /// Retrieve user credentials
  Future<UserCredentials?> getUserCredentials() async {
    final result = await _coreStorage.getSecureData<Map<String, dynamic>>(
      key: _userCredentialsKey,
    );

    return result.fold(
      (failure) {
        debugPrint('❌ Error retrieving user credentials: ${failure.message}');
        return null;
      },
      (json) => json != null ? UserCredentials.fromJson(json) : null,
    );
  }

  /// Store location data securely
  Future<void> storeLocationData(LocationData locationData) async {
    final result = await _coreStorage.storeSecureData(
      key: _locationDataKey,
      data: locationData.toJson(),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Error storing location data: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🔒 Location data stored securely'),
    );
  }

  /// Retrieve location data
  Future<LocationData?> getLocationData() async {
    final result = await _coreStorage.getSecureData<Map<String, dynamic>>(
      key: _locationDataKey,
    );

    return result.fold(
      (failure) {
        debugPrint('❌ Error retrieving location data: ${failure.message}');
        return null;
      },
      (json) => json != null ? LocationData.fromJson(json) : null,
    );
  }

  /// Store personal information securely
  Future<void> storePersonalInfo(PersonalInfo personalInfo) async {
    final result = await _coreStorage.storeSecureData(
      key: _personalInfoKey,
      data: personalInfo.toJson(),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Error storing personal info: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🔒 Personal info stored securely'),
    );
  }

  /// Retrieve personal information
  Future<PersonalInfo?> getPersonalInfo() async {
    final result = await _coreStorage.getSecureData<Map<String, dynamic>>(
      key: _personalInfoKey,
    );

    return result.fold(
      (failure) {
        debugPrint('❌ Error retrieving personal info: ${failure.message}');
        return null;
      },
      (json) => json != null ? PersonalInfo.fromJson(json) : null,
    );
  }

  /// Generate and store Hive encryption key
  Future<List<int>> getOrCreateHiveEncryptionKey() async {
    final result = await _coreStorage.getOrCreateEncryptionKey(
      keyName: _encryptionKeyKey,
    );

    return result.fold(
      (failure) {
        debugPrint('❌ Error with Hive encryption key: ${failure.message}');
        throw Exception(failure.message);
      },
      (key) => key,
    );
  }

  /// Store biometric data hash
  Future<void> storeBiometricData(String biometricHash) async {
    final result = await _coreStorage.storeBiometricHash(biometricHash);

    result.fold(
      (failure) {
        debugPrint('❌ Error storing biometric data: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🔒 Biometric data stored securely'),
    );
  }

  /// Retrieve biometric data hash
  Future<String?> getBiometricData() async {
    final result = await _coreStorage.getBiometricHash();

    return result.fold(
      (failure) {
        debugPrint('❌ Error retrieving biometric data: ${failure.message}');
        return null;
      },
      (hash) => hash,
    );
  }

  /// Clear specific secure data
  Future<void> clearUserCredentials() async {
    await _coreStorage.deleteSecureData(_userCredentialsKey);
    debugPrint('🗑️ User credentials cleared');
  }

  Future<void> clearLocationData() async {
    await _coreStorage.deleteSecureData(_locationDataKey);
    debugPrint('🗑️ Location data cleared');
  }

  Future<void> clearPersonalInfo() async {
    await _coreStorage.deleteSecureData(_personalInfoKey);
    debugPrint('🗑️ Personal info cleared');
  }

  Future<void> clearBiometricData() async {
    await _coreStorage.deleteSecureData(_biometricDataKey);
    debugPrint('🗑️ Biometric data cleared');
  }

  /// Clear all secure storage (DANGEROUS - use only for logout/reset)
  Future<void> clearAllSecureData() async {
    final result = await _coreStorage.clearAllSecureData();

    result.fold(
      (failure) {
        debugPrint('❌ Error clearing secure data: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) => debugPrint('🗑️ All secure data cleared'),
    );
  }

  /// Check if secure storage is available
  Future<bool> isSecureStorageAvailable() async {
    return await _coreStorage.isSecureStorageAvailable();
  }

  /// Generic methods for simple data types
  Future<String?> getString(String key) async {
    final result = await _coreStorage.getSecureData<String>(key: key);
    return result.fold(
      (failure) {
        debugPrint('❌ Error reading string for key $key: ${failure.message}');
        return null;
      },
      (value) => value,
    );
  }

  Future<void> setString(String key, String value) async {
    final result = await _coreStorage.storeSecureData<String>(
      key: key,
      data: value,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Error writing string for key $key: ${failure.message}');
        throw Exception(failure.message);
      },
      (_) {},
    );
  }

  Future<bool?> getBool(String key) async {
    final stringValue = await getString(key);
    if (stringValue == null) return null;
    return stringValue.toLowerCase() == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final stringValue = await getString(key);
    if (stringValue == null) return null;
    return int.tryParse(stringValue);
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// Get all keys (for debugging)
  Future<Map<String, String>> getAllSecureData() async {
    if (!kDebugMode) {
      throw UnsupportedError('This method is only available in debug mode');
    }

    final result = await _coreStorage.getAllKeys();
    return result.fold(
      (failure) {
        debugPrint('❌ Error reading all secure data: ${failure.message}');
        return {};
      },
      (keys) async {
        final allData = <String, String>{};
        for (final key in keys) {
          final value = await getString(key);
          if (value != null) {
            allData[key] = value;
          }
        }
        return allData;
      },
    );
  }
}

/// Data classes for secure storage
class UserCredentials {
  final String userId;
  final String email;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiry;

  const UserCredentials({
    required this.userId,
    required this.email,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenExpiry': tokenExpiry?.toIso8601String(),
  };

  factory UserCredentials.fromJson(Map<String, dynamic> json) =>
      UserCredentials(
        userId: json['userId'] as String,
        email: json['email'] as String,
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
        tokenExpiry:
            json['tokenExpiry'] != null
                ? DateTime.parse(json['tokenExpiry'] as String)
                : null,
      );
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    address: json['address'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class PersonalInfo {
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final Map<String, String>? customFields;

  const PersonalInfo({
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'address': address,
    'customFields': customFields,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    fullName: json['fullName'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    dateOfBirth:
        json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
    address: json['address'] as String?,
    customFields:
        json['customFields'] != null
            ? Map<String, String>.from(json['customFields'] as Map)
            : null,
  );
}
