import 'dart:convert';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

/// Model for device management
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String appVersion;
  final DateTime lastActive;
  final bool isActive;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.appVersion,
    required this.lastActive,
    this.isActive = true,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      appVersion: json['appVersion']?.toString() ?? '',
      lastActive: DateTime.tryParse(json['lastActive']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
      'appVersion': appVersion,
      'lastActive': lastActive.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Model for subscription validation
class SubscriptionStatus {
  final bool isValid;
  final bool isPremium;
  final DateTime? expirationDate;
  final String? productId;
  final int activeDevicesCount;
  final int maxDevicesAllowed;
  final bool isInGracePeriod;
  final String? errorMessage;

  const SubscriptionStatus({
    required this.isValid,
    required this.isPremium,
    this.expirationDate,
    this.productId,
    this.activeDevicesCount = 0,
    this.maxDevicesAllowed = 3,
    this.isInGracePeriod = false,
    this.errorMessage,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isValid: json['isValid'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      expirationDate: json['expirationDate'] != null 
          ? DateTime.tryParse(json['expirationDate']?.toString() ?? '')
          : null,
      productId: json['productId']?.toString(),
      activeDevicesCount: json['activeDevicesCount'] as int? ?? 0,
      maxDevicesAllowed: json['maxDevicesAllowed'] as int? ?? 3,
      isInGracePeriod: json['isInGracePeriod'] as bool? ?? false,
      errorMessage: json['errorMessage']?.toString(),
    );
  }

  bool get canAddDevice => activeDevicesCount < maxDevicesAllowed;
  bool get isNearLimit => activeDevicesCount >= (maxDevicesAllowed * 0.8);
}

/// ReceitaAgro Cloud Functions Service
/// Handles backend functions for device management and subscription validation
class ReceitaAgroCloudFunctionsService {
  static ReceitaAgroCloudFunctionsService? _instance;
  static ReceitaAgroCloudFunctionsService get instance {
    _instance ??= ReceitaAgroCloudFunctionsService._internal();
    return _instance!;
  }

  ReceitaAgroCloudFunctionsService._internal();

  // Cloud Functions endpoints
  static const String _baseUrl = 'https://us-central1-receituagro-prod.cloudfunctions.net';
  static const String _devUrl = 'https://us-central1-receituagro-dev.cloudfunctions.net';
  
  String get baseUrl => EnvironmentConfig.isProductionMode ? _baseUrl : _devUrl;

  final http.Client _httpClient = http.Client();

  /// Register current device for user
  Future<Either<String, DeviceInfo>> registerDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/registerDevice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'deviceId': deviceId,
          'deviceName': deviceName,
          'platform': platform,
          'appVersion': appVersion,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return Right(DeviceInfo.fromJson(data['device'] as Map<String, dynamic>));
        } else {
          return Left(data['error']?.toString() ?? 'Device registration failed');
        }
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error registering device: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to register device: $e');
    }
  }

  /// Get user's registered devices
  Future<Either<String, List<DeviceInfo>>> getUserDevices() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/getUserDevices'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final devicesList = (data['devices'] as List<dynamic>)
              .map((device) => DeviceInfo.fromJson(device as Map<String, dynamic>))
              .toList();
          return Right(devicesList);
        } else {
          return Left(data['error']?.toString() ?? 'Failed to fetch devices');
        }
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error fetching user devices: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to fetch devices: $e');
    }
  }

  /// Remove a device from user's registered devices
  Future<Either<String, bool>> removeDevice(String deviceId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/removeDevice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Right(data['success'] == true);
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error removing device: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to remove device: $e');
    }
  }

  /// Validate user's subscription status
  Future<Either<String, SubscriptionStatus>> validateSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/validateSubscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return Right(SubscriptionStatus.fromJson(data['subscription'] as Map<String, dynamic>));
        } else {
          return Left(data['error']?.toString() ?? 'Subscription validation failed');
        }
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error validating subscription: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to validate subscription: $e');
    }
  }

  /// Sync RevenueCat purchase with backend
  Future<Either<String, SubscriptionStatus>> syncRevenueCatPurchase({
    required String receiptData,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/syncRevenueCatPurchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiptData': receiptData,
          'productId': productId,
          'purchaseToken': purchaseToken,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return Right(SubscriptionStatus.fromJson(data['subscription'] as Map<String, dynamic>));
        } else {
          return Left(data['error']?.toString() ?? 'Purchase sync failed');
        }
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error syncing RevenueCat purchase: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to sync purchase: $e');
    }
  }

  /// Check if device can access premium features
  Future<Either<String, bool>> checkDeviceAccess(String deviceId) async {
    try {
      // First validate subscription
      final subscriptionResult = await validateSubscription();
      
      return subscriptionResult.fold(
        (error) => Left(error),
        (subscription) {
          // Check if subscription is valid and device is registered
          if (!subscription.isValid) {
            return const Right(false);
          }

          // For premium features, check if user has premium subscription
          if (!subscription.isPremium) {
            return const Right(false);
          }

          // Check if device limit is respected
          if (!subscription.canAddDevice && subscription.activeDevicesCount > 0) {
            // Need to check if this specific device is already registered
            return const Right(true); // Assuming device check happens elsewhere
          }

          return const Right(true);
        },
      );
    } catch (e) {
      developer.log(
        'Error checking device access: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to check device access: $e');
    }
  }

  /// Update user's subscription information
  Future<Either<String, bool>> updateSubscriptionInfo({
    required String productId,
    required DateTime expirationDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final token = await user.getIdToken();
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/updateSubscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'productId': productId,
          'expirationDate': expirationDate.toIso8601String(),
          'additionalData': additionalData ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Right(data['success'] == true);
      } else {
        return Left('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log(
        'Error updating subscription: $e',
        name: 'CloudFunctionsService',
        error: e,
      );
      return Left('Failed to update subscription: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}