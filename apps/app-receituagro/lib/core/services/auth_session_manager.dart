import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../data/models/user_session_data.dart';
import 'device_identity_service.dart';

/// User type enum for authentication state
enum UserType { guest, registered, premium }

/// Gerencia ciclo de vida da sessão do usuário
/// Extraído do AuthProvider para seguir Single Responsibility Principle
class AuthSessionManager {
  final DeviceIdentityService _deviceService;
  final ReceitaAgroAnalyticsService _analytics;

  AuthSessionManager({
    required DeviceIdentityService deviceService,
    required ReceitaAgroAnalyticsService analytics,
  }) : _deviceService = deviceService,
       _analytics = analytics;

  /// Initialize user session with device info and analytics
  Future<UserSessionData> initializeSession(
    UserEntity user,
    UserType userType,
  ) async {
    try {
      final deviceId = await _deviceService.getDeviceUuid();
      final sessionData = UserSessionData(
        userId: user.id,
        deviceId: deviceId,
        loginTime: DateTime.now(),
        isAnonymous: user.isAnonymous,
      );
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties(
        userType: _mapToAnalyticsUserType(userType),
        isPremium: false, // TODO: Check premium status
        deviceCount: 1, // TODO: Get actual device count
      );

      if (kDebugMode) {
        debugPrint(
          '✅ AuthSessionManager: User session initialized for ${user.displayName}',
        );
      }

      return sessionData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthSessionManager: Session initialization error - $e');
      }
      rethrow;
    }
  }

  /// Clear session data on logout
  Future<void> clearSession() async {
    try {
      await _analytics.clearUser();

      if (kDebugMode) {
        debugPrint('✅ AuthSessionManager: Session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthSessionManager: Error clearing session - $e');
      }
      rethrow;
    }
  }

  /// Map UserType to analytics user type enum
  AnalyticsUserType _mapToAnalyticsUserType(UserType userType) {
    switch (userType) {
      case UserType.guest:
        return AnalyticsUserType.guest;
      case UserType.registered:
        return AnalyticsUserType.registered;
      case UserType.premium:
        return AnalyticsUserType.premium;
    }
  }
}
