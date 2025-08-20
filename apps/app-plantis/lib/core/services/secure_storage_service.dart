import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Secure storage service for sensitive data
/// Uses platform keychain/keystore for encryption
class SecureStorageService {
  static SecureStorageService? _instance;
  static SecureStorageService get instance => _instance ??= SecureStorageService._();
  
  SecureStorageService._();
  
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'app_plantis_secure_data',
    ),
  );
  
  // Keys for sensitive data
  static const String _userCredentialsKey = 'user_credentials';
  static const String _locationDataKey = 'location_data';
  static const String _personalInfoKey = 'personal_info';
  static const String _encryptionKeyKey = 'hive_encryption_key';
  static const String _biometricDataKey = 'biometric_data';
  
  /// Store user credentials securely
  Future<void> storeUserCredentials(UserCredentials credentials) async {
    try {
      final jsonString = jsonEncode(credentials.toJson());
      await _storage.write(key: _userCredentialsKey, value: jsonString);
      debugPrint('🔒 User credentials stored securely');
    } catch (e) {
      debugPrint('❌ Error storing user credentials: $e');
      rethrow;
    }
  }
  
  /// Retrieve user credentials
  Future<UserCredentials?> getUserCredentials() async {
    try {
      final jsonString = await _storage.read(key: _userCredentialsKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserCredentials.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving user credentials: $e');
      return null;
    }
  }
  
  /// Store location data securely
  Future<void> storeLocationData(LocationData locationData) async {
    try {
      final jsonString = jsonEncode(locationData.toJson());
      await _storage.write(key: _locationDataKey, value: jsonString);
      debugPrint('🔒 Location data stored securely');
    } catch (e) {
      debugPrint('❌ Error storing location data: $e');
      rethrow;
    }
  }
  
  /// Retrieve location data
  Future<LocationData?> getLocationData() async {
    try {
      final jsonString = await _storage.read(key: _locationDataKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LocationData.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving location data: $e');
      return null;
    }
  }
  
  /// Store personal information securely
  Future<void> storePersonalInfo(PersonalInfo personalInfo) async {
    try {
      final jsonString = jsonEncode(personalInfo.toJson());
      await _storage.write(key: _personalInfoKey, value: jsonString);
      debugPrint('🔒 Personal info stored securely');
    } catch (e) {
      debugPrint('❌ Error storing personal info: $e');
      rethrow;
    }
  }
  
  /// Retrieve personal information
  Future<PersonalInfo?> getPersonalInfo() async {
    try {
      final jsonString = await _storage.read(key: _personalInfoKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PersonalInfo.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving personal info: $e');
      return null;
    }
  }
  
  /// Generate and store Hive encryption key
  Future<List<int>> getOrCreateHiveEncryptionKey() async {
    try {
      final existingKey = await _storage.read(key: _encryptionKeyKey);
      
      if (existingKey != null) {
        // Decode existing key
        final keyList = jsonDecode(existingKey) as List<dynamic>;
        return keyList.cast<int>();
      }
      
      // Generate new 256-bit encryption key
      final newKey = List<int>.generate(32, (index) => 
          DateTime.now().millisecondsSinceEpoch.hashCode % 256);
      
      // Store the key securely
      await _storage.write(key: _encryptionKeyKey, value: jsonEncode(newKey));
      
      debugPrint('🔑 New Hive encryption key generated and stored');
      return newKey;
    } catch (e) {
      debugPrint('❌ Error with Hive encryption key: $e');
      rethrow;
    }
  }
  
  /// Store biometric data hash
  Future<void> storeBiometricData(String biometricHash) async {
    try {
      await _storage.write(key: _biometricDataKey, value: biometricHash);
      debugPrint('🔒 Biometric data stored securely');
    } catch (e) {
      debugPrint('❌ Error storing biometric data: $e');
      rethrow;
    }
  }
  
  /// Retrieve biometric data hash
  Future<String?> getBiometricData() async {
    try {
      return await _storage.read(key: _biometricDataKey);
    } catch (e) {
      debugPrint('❌ Error retrieving biometric data: $e');
      return null;
    }
  }
  
  /// Clear specific secure data
  Future<void> clearUserCredentials() async {
    await _storage.delete(key: _userCredentialsKey);
    debugPrint('🗑️ User credentials cleared');
  }
  
  Future<void> clearLocationData() async {
    await _storage.delete(key: _locationDataKey);
    debugPrint('🗑️ Location data cleared');
  }
  
  Future<void> clearPersonalInfo() async {
    await _storage.delete(key: _personalInfoKey);
    debugPrint('🗑️ Personal info cleared');
  }
  
  Future<void> clearBiometricData() async {
    await _storage.delete(key: _biometricDataKey);
    debugPrint('🗑️ Biometric data cleared');
  }
  
  /// Clear all secure storage (DANGEROUS - use only for logout/reset)
  Future<void> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ All secure data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing secure data: $e');
      rethrow;
    }
  }
  
  /// Check if secure storage is available
  Future<bool> isSecureStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'test_key');
      return true;
    } catch (e) {
      debugPrint('❌ Secure storage not available: $e');
      return false;
    }
  }
  
  /// Get all keys (for debugging)
  Future<Map<String, String>> getAllSecureData() async {
    if (!kDebugMode) {
      throw UnsupportedError('This method is only available in debug mode');
    }
    
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('❌ Error reading all secure data: $e');
      return {};
    }
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
  
  factory UserCredentials.fromJson(Map<String, dynamic> json) => UserCredentials(
    userId: json['userId'] as String,
    email: json['email'] as String,
    accessToken: json['accessToken'] as String?,
    refreshToken: json['refreshToken'] as String?,
    tokenExpiry: json['tokenExpiry'] != null 
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
    dateOfBirth: json['dateOfBirth'] != null 
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null,
    address: json['address'] as String?,
    customFields: json['customFields'] != null 
        ? Map<String, String>.from(json['customFields'] as Map)
        : null,
  );
}