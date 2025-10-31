import 'package:injectable/injectable.dart';

import '../../domain/entities/premium_status.dart';

/// Service responsible for mapping between PremiumStatus and Firebase data
/// Follows SRP by handling only data conversion logic
@lazySingleton
class PremiumStatusMapper {
  /// Map PremiumStatus to Firebase data
  Map<String, dynamic> statusToFirebaseMap(PremiumStatus status) {
    return {
      'app_name': 'gasometer',
      'is_premium': status.isPremium,
      'is_expired': status.isExpired,
      'premium_source': status.premiumSource,
      'expiration_date': status.expirationDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'limits': _limitsToMap(status),
      'features': status.features,
    };
  }

  /// Map Firebase data to PremiumStatus
  PremiumStatus firebaseMapToStatus(Map<String, dynamic> data) {
    final isPremium = data['is_premium'] as bool? ?? false;

    if (!isPremium) {
      return PremiumStatus.free;
    }

    final expirationDate = _parseExpirationDate(data['expiration_date']);
    final premiumSource = data['premium_source'] as String?;

    if (premiumSource == 'local_license') {
      return PremiumStatus.localLicense(
        expiration: expirationDate ?? DateTime.now(),
      );
    }

    return PremiumStatus.premium(
      expirationDate:
          expirationDate ?? DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Map PremiumStatus with cache metadata
  Map<String, dynamic> statusToCachedMap(PremiumStatus status, Duration ttl) {
    final baseMap = statusToFirebaseMap(status);
    final now = DateTime.now();

    return {
      ...baseMap,
      'cache_expires_at': now.add(ttl).toIso8601String(),
      'cached_at': now.toIso8601String(),
    };
  }

  /// Check if cached data is still valid
  bool isCacheValid(Map<String, dynamic> data) {
    final expiresAtStr = data['cache_expires_at'] as String?;

    if (expiresAtStr == null) return false;

    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  /// Extract cache expiration date
  DateTime? getCacheExpiration(Map<String, dynamic> data) {
    final expiresAtStr = data['cache_expires_at'] as String?;

    if (expiresAtStr == null) return null;

    try {
      return DateTime.parse(expiresAtStr);
    } catch (e) {
      return null;
    }
  }

  /// Extract cache creation date
  DateTime? getCacheCreationDate(Map<String, dynamic> data) {
    final cachedAtStr = data['cached_at'] as String?;

    if (cachedAtStr == null) return null;

    try {
      return DateTime.parse(cachedAtStr);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  Map<String, dynamic> _limitsToMap(PremiumStatus status) {
    return {
      'max_vehicles': status.limits.maxVehicles,
      'max_fuel_records': status.limits.maxFuelRecords,
      'max_maintenance_records': status.limits.maxMaintenanceRecords,
    };
  }

  DateTime? _parseExpirationDate(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
