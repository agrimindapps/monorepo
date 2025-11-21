import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'settings_providers.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';

/// @Deprecated("Deprecated - use alternative") Wrapper notifier for backward compatibility
/// 
/// REFACTORED: This notifier now delegates to specialized notifiers:
/// - ThemeNotifier: theme and visual settings
/// - NotificationsNotifier: notification preferences
/// - AnalyticsDebugNotifier: analytics and debug operations
/// 
/// For new code, use the specialized notifiers directly.
/// This wrapper maintains backward compatibility with existing UI code.
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  late final FeatureFlagsNotifier _featureFlagsNotifier;
  DeviceManagementService? _deviceManagementService;

  @override
  Future<SettingsState> build() async {
    _getUserSettingsUseCase = ref.watch(getUserSettingsUseCaseProvider);
    _updateUserSettingsUseCase = ref.watch(updateUserSettingsUseCaseProvider);
    _initializeServices();

    return SettingsState.initial();
  }

  void _initializeServices() {
    try {
      _featureFlagsNotifier = ref.read(featureFlagsNotifierProvider.notifier);
      _deviceManagementService = ref.watch(deviceManagementServiceProvider);
      
      if (_deviceManagementService == null) {
        debugPrint('⚠️  DeviceManagementService not available (Web platform)');
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
      debugPrint('Stack trace:');
      debugPrint(StackTrace.current.toString());
    }
  }

  /// Initialize provider and load settings for user
  Future<void> initialize(String userId) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (userId.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(error: 'Invalid user ID'));
      return;
    }

    state = AsyncValue.data(currentState.copyWith(currentUserId: userId));

    await Future.wait([
      loadSettings(),
      _loadDeviceInfo(),
    ]);
  }

  /// Load user settings
  Future<void> loadSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.currentUserId.isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'User not initialized'),
      );
      return;
    }

    try {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: true).clearError(),
      );

      final settings = await _getUserSettingsUseCase(
        currentState.currentUserId,
      );

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, settings: settings),
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Update theme setting
  Future<bool> setDarkTheme(bool isDark) async {
    return await _updateSingleSetting('isDarkTheme', isDark);
  }

  /// Update notifications setting
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _updateSingleSetting('notificationsEnabled', enabled);
  }

  /// Update sound setting
  Future<bool> setSoundEnabled(bool enabled) async {
    return await _updateSingleSetting('soundEnabled', enabled);
  }

  /// Update language setting
  Future<bool> setLanguage(String language) async {
    return await _updateSingleSetting('language', language);
  }

  /// Update speech to text setting
  Future<bool> setSpeechToTextEnabled(bool enabled) async {
    return await _updateSingleSetting('speechToTextEnabled', enabled);
  }

  /// Update analytics setting
  Future<bool> setAnalyticsEnabled(bool enabled) async {
    return await _updateSingleSetting('analyticsEnabled', enabled);
  }

  /// Generate test license (development only)
  Future<bool> generateTestLicense() async {
    // TODO: Implement analyticsDebugNotifierProvider
    // final debugNotifier = ref.read(analyticsDebugNotifierProvider.notifier);
    // return await debugNotifier.generateTestLicense();
    return false;
  }

  /// Remove test license (development only)
  Future<bool> removeTestLicense() async {
    // TODO: Implement analyticsDebugNotifierProvider
    // final debugNotifier = ref.read(analyticsDebugNotifierProvider.notifier);
    // return await debugNotifier.removeTestLicense();
    return false;
  }

  /// Test notification functionality
  Future<bool> testNotification() async {
    // TODO: Implement notificationsNotifierProvider
    // final notificationNotifier =
    //     ref.read(notificationsNotifierProvider.notifier);
    // return await notificationNotifier.testNotification();
    return false;
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    // TODO: Implement notificationsNotifierProvider
    // final notificationNotifier =
    //     ref.read(notificationsNotifierProvider.notifier);
    // await notificationNotifier.openNotificationSettings();
  }

  /// Test analytics functionality
  Future<bool> testAnalytics() async {
    // TODO: Implement analytics testing
    // final debugNotifier = ref.read(analyticsDebugNotifierProvider.notifier);
    // return await debugNotifier.testAnalytics();
    return false;
  }

  /// Test crashlytics functionality
  Future<bool> testCrashlytics() async {
    // TODO: Implement crashlytics testing
    // final debugNotifier = ref.read(analyticsDebugNotifierProvider.notifier);
    // return await debugNotifier.testCrashlytics();
    return false;
  }

  /// Show rate app dialog
  Future<bool> showRateAppDialog(BuildContext context) async {
    // TODO: Implement rate app dialog
    // final debugNotifier = ref.read(analyticsDebugNotifierProvider.notifier);
    // return await debugNotifier.showRateAppDialog();
    return false;
  }

  /// Update a single setting
  Future<bool> _updateSingleSetting(String key, dynamic value) async {
    final currentState = state.value;
    if (currentState == null || currentState.settings == null) {
      debugPrint('No settings to update');
      return false;
    }

    try {
      final currentSettings = currentState.settings!;
      UserSettingsEntity updatedSettings;

      switch (key) {
        case 'isDarkTheme':
          updatedSettings = currentSettings.copyWith(
            isDarkTheme: value as bool,
          );
          break;
        case 'notificationsEnabled':
          updatedSettings = currentSettings.copyWith(
            notificationsEnabled: value as bool,
          );
          break;
        case 'soundEnabled':
          updatedSettings = currentSettings.copyWith(
            soundEnabled: value as bool,
          );
          break;
        case 'language':
          updatedSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'speechToTextEnabled':
          updatedSettings = currentSettings.copyWith(
            speechToTextEnabled: value as bool,
          );
          break;
        case 'analyticsEnabled':
          updatedSettings = currentSettings.copyWith(
            analyticsEnabled: value as bool,
          );
          break;
        default:
          debugPrint('Unknown setting key: $key');
          return false;
      }

      await _updateUserSettingsUseCase(updatedSettings);

      state = AsyncValue.data(currentState.copyWith(settings: updatedSettings));

      return true;
    } catch (e) {
      debugPrint('Error updating setting $key: $e');
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null) return;

    await Future.wait([
      loadSettings(),
      _loadDeviceInfo(),
    ]);
  }

  /// Load device information
  Future<void> _loadDeviceInfo() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      if (currentState.currentUserId.isEmpty) {
        debugPrint('⚠️  Cannot load device info: User ID not set');
        return;
      }

      if (_deviceManagementService == null) {
        debugPrint(
          '⚠️  DeviceManagementService not available - skipping device load',
        );
        return;
      }

      // Fetch devices from service
      final devicesResult = await _deviceManagementService!.getUserDevices();

      DeviceEntity? currentDevice;
      List<DeviceEntity> connectedDevices = [];

      devicesResult.fold(
        (failure) {
          debugPrint('❌ Error loading devices: ${failure.message}');
        },
        (devices) {
          connectedDevices = devices;
          // Find current device (the active one or first device)
          try {
            currentDevice = devices.firstWhere(
              (device) => device.isActive,
              orElse: () => devices.isNotEmpty ? devices.first : throw Exception('No devices'),
            );
            debugPrint('✅ Loaded ${devices.length} devices, current: ${currentDevice?.uuid}');
          } catch (e) {
            debugPrint('⚠️  No active device found');
          }
        },
      );

      state = AsyncValue.data(
        currentState.copyWith(
          currentDevice: currentDevice,
          connectedDevices: connectedDevices,
        ),
      );
    } catch (e) {
      debugPrint('Unexpected error loading device info: $e');
    }
  }

  /// Revoke a device
  Future<void> revokeDevice(String deviceUuid) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      if (currentState.currentUserId.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(error: 'User not initialized'),
        );
        return;
      }

      if (_deviceManagementService == null) {
        state = AsyncValue.data(
          currentState.copyWith(error: 'Device management not available'),
        );
        return;
      }

      state = AsyncValue.data(currentState.copyWith(isLoading: true));
      final result = await _deviceManagementService!.revokeDevice(deviceUuid);

      await result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, error: failure.message),
          );
        },
        (_) async {
          await _loadDeviceInfo();
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false).clearError(),
          );
        },
      );
    } catch (e) {
      debugPrint('Unexpected error revoking device: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Add a device
  Future<bool> addDevice(DeviceEntity device) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      if (currentState.currentUserId.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(error: 'User not initialized'),
        );
        return false;
      }

      if (_deviceManagementService == null) {
        state = AsyncValue.data(
          currentState.copyWith(error: 'Device management not available'),
        );
        return false;
      }

      state = AsyncValue.data(currentState.copyWith(isLoading: true));

      // Validate device with real service call
      final result = await _deviceManagementService!.validateDevice(device);

      return result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, error: failure.message),
          );
          return false;
        },
        (DeviceEntity registeredDevice) async {
          await _loadDeviceInfo();
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false).clearError(),
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('Unexpected error adding device: $e');
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
      return false;
    }
  }

  /// Check if user can add more devices
  Future<bool> canAddMoreDevices() async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      if (currentState.currentUserId.isEmpty) {
        return false;
      }

      if (_deviceManagementService == null) {
        debugPrint(
          '⚠️  DeviceManagementService not available - using local fallback',
        );
        return currentState.connectedDevices.length < 3;
      }

      final result = await _deviceManagementService!.canAddMoreDevices();
      return result.fold((failure) {
        debugPrint('Error checking if can add more devices: $failure');
        return currentState.connectedDevices.length < 3;
      }, (canAdd) => canAdd);
    } catch (e) {
      debugPrint('Unexpected error checking device limit: $e');
      return currentState.connectedDevices.length < 3;
    }
  }

  /// Get device by UUID
  DeviceEntity? getDeviceByUuid(String uuid) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.connectedDevices.firstWhere(
        (device) => device.uuid == uuid,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if device management is enabled
  bool get isDeviceManagementEnabled =>
      _featureFlagsNotifier.isDeviceManagementEnabled;
}
