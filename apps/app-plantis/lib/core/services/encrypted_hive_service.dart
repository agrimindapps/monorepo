import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

/// Service for managing encrypted Hive boxes for sensitive data
class EncryptedHiveService {
  static EncryptedHiveService? _instance;
  static EncryptedHiveService get instance => _instance ??= EncryptedHiveService._();
  
  EncryptedHiveService._();
  
  final SecureStorageService _secureStorage = SecureStorageService.instance;
  
  // Box names for encrypted data
  static const String _sensitiveDataBoxName = 'sensitive_data_encrypted';
  static const String _piiDataBoxName = 'pii_data_encrypted';
  static const String _locationDataBoxName = 'location_data_encrypted';
  
  HiveCipher? _encryptionCipher;
  bool _isInitialized = false;
  
  /// Initialize encryption for Hive
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get or create encryption key
      final encryptionKey = await _secureStorage.getOrCreateHiveEncryptionKey();
      
      // Create cipher for encryption
      _encryptionCipher = HiveAesCipher(encryptionKey);
      
      _isInitialized = true;
      debugPrint('🔐 Encrypted Hive service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing encrypted Hive: $e');
      rethrow;
    }
  }
  
  /// Get or open encrypted box for sensitive data
  Future<Box<String>> getSensitiveDataBox() async {
    await initialize();
    
    if (!Hive.isBoxOpen(_sensitiveDataBoxName)) {
      return await Hive.openBox<String>(
        _sensitiveDataBoxName,
        encryptionCipher: _encryptionCipher,
      );
    }
    
    return Hive.box<String>(_sensitiveDataBoxName);
  }
  
  /// Get or open encrypted box for PII data
  Future<Box<String>> getPiiDataBox() async {
    await initialize();
    
    if (!Hive.isBoxOpen(_piiDataBoxName)) {
      return await Hive.openBox<String>(
        _piiDataBoxName,
        encryptionCipher: _encryptionCipher,
      );
    }
    
    return Hive.box<String>(_piiDataBoxName);
  }
  
  /// Get or open encrypted box for location data
  Future<Box<String>> getLocationDataBox() async {
    await initialize();
    
    if (!Hive.isBoxOpen(_locationDataBoxName)) {
      return await Hive.openBox<String>(
        _locationDataBoxName,
        encryptionCipher: _encryptionCipher,
      );
    }
    
    return Hive.box<String>(_locationDataBoxName);
  }
  
  /// Store sensitive plant data (notes with personal info, GPS coordinates)
  Future<void> storeSensitivePlantData(String plantId, SensitivePlantData data) async {
    try {
      final box = await getSensitiveDataBox();
      final jsonString = jsonEncode(data.toJson());
      await box.put('plant_$plantId', jsonString);
      
      debugPrint('🔐 Sensitive plant data stored for plant: $plantId');
    } catch (e) {
      debugPrint('❌ Error storing sensitive plant data: $e');
      rethrow;
    }
  }
  
  /// Retrieve sensitive plant data
  Future<SensitivePlantData?> getSensitivePlantData(String plantId) async {
    try {
      final box = await getSensitiveDataBox();
      final jsonString = box.get('plant_$plantId');
      
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SensitivePlantData.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving sensitive plant data: $e');
      return null;
    }
  }
  
  /// Store PII data separately from main plant data
  Future<void> storePiiData(String userId, UserPiiData data) async {
    try {
      final box = await getPiiDataBox();
      final jsonString = jsonEncode(data.toJson());
      await box.put('user_$userId', jsonString);
      
      debugPrint('🔐 PII data stored for user: $userId');
    } catch (e) {
      debugPrint('❌ Error storing PII data: $e');
      rethrow;
    }
  }
  
  /// Retrieve PII data
  Future<UserPiiData?> getPiiData(String userId) async {
    try {
      final box = await getPiiDataBox();
      final jsonString = box.get('user_$userId');
      
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPiiData.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving PII data: $e');
      return null;
    }
  }
  
  /// Store location data with encryption
  Future<void> storeEncryptedLocation(String key, LocationSnapshot location) async {
    try {
      final box = await getLocationDataBox();
      final jsonString = jsonEncode(location.toJson());
      await box.put(key, jsonString);
      
      debugPrint('🔐 Location data stored with key: $key');
    } catch (e) {
      debugPrint('❌ Error storing location data: $e');
      rethrow;
    }
  }
  
  /// Retrieve encrypted location data
  Future<LocationSnapshot?> getEncryptedLocation(String key) async {
    try {
      final box = await getLocationDataBox();
      final jsonString = box.get(key);
      
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LocationSnapshot.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error retrieving location data: $e');
      return null;
    }
  }
  
  /// Delete sensitive plant data
  Future<void> deleteSensitivePlantData(String plantId) async {
    try {
      final box = await getSensitiveDataBox();
      await box.delete('plant_$plantId');
      debugPrint('🗑️ Sensitive plant data deleted for: $plantId');
    } catch (e) {
      debugPrint('❌ Error deleting sensitive plant data: $e');
      rethrow;
    }
  }
  
  /// Delete PII data
  Future<void> deletePiiData(String userId) async {
    try {
      final box = await getPiiDataBox();
      await box.delete('user_$userId');
      debugPrint('🗑️ PII data deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting PII data: $e');
      rethrow;
    }
  }
  
  /// Clear all encrypted data (for logout/reset)
  Future<void> clearAllEncryptedData() async {
    try {
      if (Hive.isBoxOpen(_sensitiveDataBoxName)) {
        final sensitiveBox = Hive.box<String>(_sensitiveDataBoxName);
        await sensitiveBox.clear();
      }
      
      if (Hive.isBoxOpen(_piiDataBoxName)) {
        final piiBox = Hive.box<String>(_piiDataBoxName);
        await piiBox.clear();
      }
      
      if (Hive.isBoxOpen(_locationDataBoxName)) {
        final locationBox = Hive.box<String>(_locationDataBoxName);
        await locationBox.clear();
      }
      
      debugPrint('🗑️ All encrypted data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing encrypted data: $e');
      rethrow;
    }
  }
  
  /// Get encryption status for monitoring
  Map<String, dynamic> getEncryptionStatus() {
    return {
      'isInitialized': _isInitialized,
      'hasCipher': _encryptionCipher != null,
      'openBoxes': [
        if (Hive.isBoxOpen(_sensitiveDataBoxName)) _sensitiveDataBoxName,
        if (Hive.isBoxOpen(_piiDataBoxName)) _piiDataBoxName,
        if (Hive.isBoxOpen(_locationDataBoxName)) _locationDataBoxName,
      ],
    };
  }
}

/// Data classes for encrypted storage
class SensitivePlantData {
  final String plantId;
  final String? sensitiveNotes; // Personal notes that might contain PII
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String? locationAddress;
  final DateTime? lastLocationUpdate;
  final Map<String, String>? customSensitiveFields;
  
  const SensitivePlantData({
    required this.plantId,
    this.sensitiveNotes,
    this.gpsLatitude,
    this.gpsLongitude,
    this.locationAddress,
    this.lastLocationUpdate,
    this.customSensitiveFields,
  });
  
  Map<String, dynamic> toJson() => {
    'plantId': plantId,
    'sensitiveNotes': sensitiveNotes,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'locationAddress': locationAddress,
    'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    'customSensitiveFields': customSensitiveFields,
  };
  
  factory SensitivePlantData.fromJson(Map<String, dynamic> json) => SensitivePlantData(
    plantId: json['plantId'] as String,
    sensitiveNotes: json['sensitiveNotes'] as String?,
    gpsLatitude: json['gpsLatitude'] as double?,
    gpsLongitude: json['gpsLongitude'] as double?,
    locationAddress: json['locationAddress'] as String?,
    lastLocationUpdate: json['lastLocationUpdate'] != null 
        ? DateTime.parse(json['lastLocationUpdate'] as String)
        : null,
    customSensitiveFields: json['customSensitiveFields'] != null 
        ? Map<String, String>.from(json['customSensitiveFields'] as Map)
        : null,
  );
}

class UserPiiData {
  final String userId;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? emergencyContact;
  final Map<String, String>? personalPreferences;
  
  const UserPiiData({
    required this.userId,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.emergencyContact,
    this.personalPreferences,
  });
  
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'address': address,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'emergencyContact': emergencyContact,
    'personalPreferences': personalPreferences,
  };
  
  factory UserPiiData.fromJson(Map<String, dynamic> json) => UserPiiData(
    userId: json['userId'] as String,
    fullName: json['fullName'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    address: json['address'] as String?,
    dateOfBirth: json['dateOfBirth'] != null 
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null,
    emergencyContact: json['emergencyContact'] as String?,
    personalPreferences: json['personalPreferences'] != null 
        ? Map<String, String>.from(json['personalPreferences'] as Map)
        : null,
  );
}

class LocationSnapshot {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? source; // GPS, Network, etc.
  
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
    'source': source,
  };
  
  factory LocationSnapshot.fromJson(Map<String, dynamic> json) => LocationSnapshot(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    accuracy: json['accuracy'] as double?,
    timestamp: DateTime.parse(json['timestamp'] as String),
    source: json['source'] as String?,
  );
}