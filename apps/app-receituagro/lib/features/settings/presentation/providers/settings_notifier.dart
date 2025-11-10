import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/providers/feature_flags_notifier.dart';
import '../../../../core/services/promotional_notification_manager.dart';
import '../../../../core/services/receituagro_notification_service.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';


/// Settings notifier for user settings management
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  late final IPremiumService _premiumService;
  late final ReceitaAgroNotificationService _notificationService;
  late final PromotionalNotificationManager _promotionalManager;
  late final IAnalyticsRepository _analyticsRepository;
  late final ICrashlyticsRepository _crashlyticsRepository;
  late final IAppRatingRepository _appRatingRepository;
  late final FeatureFlagsNotifier _featureFlagsNotifier;
  DeviceManagementService? _deviceManagementService;

  @override
  Future<SettingsState> build() async {
    _getUserSettingsUseCase = di.sl<GetUserSettingsUseCase>();
    _updateUserSettingsUseCase = di.sl<UpdateUserSettingsUseCase>();
    _initializeServices();
    ref.onDispose(() {
      unawaited(
        _notificationService.cancelAllNotifications().catchError((Object e) {
          debugPrint('Error cleaning notification resources: $e');
          return false;
        }),
      );
    });

    return SettingsState.initial();
  }

  void _initializeServices() {
    try {
      _premiumService = di.sl<IPremiumService>();
      _notificationService = di.sl<ReceitaAgroNotificationService>();
      _promotionalManager = PromotionalNotificationManager();
      _analyticsRepository = di.sl<IAnalyticsRepository>();
      _crashlyticsRepository = di.sl<ICrashlyticsRepository>();
      _appRatingRepository = di.sl<IAppRatingRepository>();
      _featureFlagsNotifier = ref.read(featureFlagsNotifierProvider.notifier);
      if (di.sl.isRegistered<DeviceManagementService>()) {
        _deviceManagementService = di.sl<DeviceManagementService>();
      } else {
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
      _loadPremiumStatus(),
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

  /// Load premium status
  Future<void> _loadPremiumStatus() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final isPremium = await _premiumService.isPremiumUser();
      state = AsyncValue.data(currentState.copyWith(isPremiumUser: isPremium));
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }

  /// Update theme setting
  Future<bool> setDarkTheme(bool isDark) async {
    return await _updateSingleSetting('isDarkTheme', isDark);
  }

  /// Update notifications setting
  Future<bool> setNotificationsEnabled(bool enabled) async {
    final success = await _updateSingleSetting('notificationsEnabled', enabled);

    if (success) {
      try {
        final currentPrefs =
            await _promotionalManager.getUserNotificationPreferences();
        final newPrefs = currentPrefs.copyWith(promotionalEnabled: enabled);
        await _promotionalManager.saveUserNotificationPreferences(newPrefs);
      } catch (e) {
        debugPrint('Error updating promotional preferences: $e');
      }
    }

    return success;
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
    try {
      await _premiumService.generateTestSubscription();
      await _loadPremiumStatus();
      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error generating test license: $e');
      return false;
    }
  }

  /// Remove test license (development only)
  Future<bool> removeTestLicense() async {
    try {
      await _premiumService.removeTestSubscription();
      await _loadPremiumStatus();
      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error removing test license: $e');
      return false;
    }
  }

  /// Test notification functionality
  Future<bool> testNotification() async {
    try {
      debugPrint('Notification test - not implemented yet');

      await _analyticsRepository.logEvent(
        'notification_test',
        parameters: {'status': 'success'},
      );

      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error testing notification: $e');

      await _analyticsRepository.logEvent(
        'notification_test',
        parameters: {'status': 'error', 'error': e.toString()},
      );

      return false;
    }
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }

  /// Test analytics functionality
  Future<bool> testAnalytics() async {
    try {
      final testData = {
        'test_event': 'settings_test_analytics',
        'timestamp': DateTime.now().toIso8601String(),
        'platform':
            Theme.of(
              NavigationService.navigatorKey.currentContext!,
            ).platform.toString(),
      };

      await _analyticsRepository.logEvent(
        'test_analytics',
        parameters: testData,
      );

      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error testing analytics: $e');
      return false;
    }
  }

  /// Test crashlytics functionality
  Future<bool> testCrashlytics() async {
    try {
      await _crashlyticsRepository.log('Test crashlytics log from settings');

      await _crashlyticsRepository.setCustomKey(
        key: 'test_timestamp',
        value: DateTime.now().toIso8601String(),
      );

      await _crashlyticsRepository.recordError(
        exception: Exception('Test exception from settings'),
        stackTrace: StackTrace.current,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.clearError());
      }

      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error testing crashlytics: $e');
      return false;
    }
  }

  /// Show rate app dialog
  Future<bool> showRateAppDialog(BuildContext context) async {
    try {

      await _appRatingRepository.showRatingDialog();

      await _analyticsRepository.logEvent(
        'rate_app_shown',
        parameters: {'timestamp': DateTime.now().toIso8601String()},
      );

      return true;
    } catch (e) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      }
      debugPrint('Error showing rate app dialog: $e');
      return false;
    }
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
      _loadPremiumStatus(),
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
