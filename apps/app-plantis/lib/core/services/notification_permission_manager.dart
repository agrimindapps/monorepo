import 'package:flutter/material.dart';

import 'interfaces/i_permission_manager.dart';
import 'notification_permission_status.dart';
import 'plantis_notification_service.dart';

/// Service responsible for managing notification permissions
/// Follows Single Responsibility Principle - handles only permission management
class NotificationPermissionManager implements IPermissionManager {
  final PlantisNotificationService _notificationService;

  NotificationPermissionManager(this._notificationService);

  /// Request notification permissions from the user
  @override
  Future<bool> requestNotificationPermissions() async {
    try {
      final currentPermission =
          await _notificationService.areNotificationsEnabled();
      if (currentPermission) {
        debugPrint('✅ Notifications already enabled');
        return true;
      }

      final permissionGranted = await _notificationService.requestPermission();

      if (!permissionGranted) {
        debugPrint('⚠️ User denied notification permissions');
      } else {
        debugPrint('✅ Notification permissions granted');
      }

      return permissionGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Get current permission status
  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    try {
      final hasPermission =
          await _notificationService.areNotificationsEnabled();
      return hasPermission
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    } catch (e) {
      debugPrint('❌ Error getting permission status: $e');
      return NotificationPermissionStatus.denied;
    }
  }

  /// Open system notification settings
  @override
  Future<bool> openNotificationSettings() async {
    try {
      final result = await _notificationService.openNotificationSettings();
      debugPrint('✅ Opened notification settings: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error opening notification settings: $e');
      return false;
    }
  }
}
