import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/providers/feature_flags_provider.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/services/receituagro_notification_service.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';

/// Unified provider for all settings functionality
/// Combines Clean Architecture patterns with specific app logic
class SettingsProvider extends ChangeNotifier {
  final GetUserSettingsUseCase _getUserSettingsUseCase;
  final UpdateUserSettingsUseCase _updateUserSettingsUseCase;
  
  // Services from DI
  late final IPremiumService _premiumService;
  late final ReceitaAgroNotificationService _notificationService;
  late final IAnalyticsRepository _analyticsRepository;
  late final ICrashlyticsRepository _crashlyticsRepository;
  late final IAppRatingRepository _appRatingRepository;
  late final DeviceIdentityService _deviceIdentityService;
  late final FeatureFlagsProvider _featureFlagsProvider;
  late final DeviceManagementService _deviceManagementService;
  
  SettingsProvider({
    required GetUserSettingsUseCase getUserSettingsUseCase,
    required UpdateUserSettingsUseCase updateUserSettingsUseCase,
  })  : _getUserSettingsUseCase = getUserSettingsUseCase,
        _updateUserSettingsUseCase = updateUserSettingsUseCase {
    _initializeServices();
  }

  // State
  UserSettingsEntity? _settings;
  bool _isLoading = false;
  String? _error;
  String _currentUserId = '';
  bool _isPremiumUser = false;
  bool _disposed = false;
  
  // Device Management State
  DeviceEntity? _currentDevice;
  List<DeviceEntity> _connectedDevices = [];

  // Getters
  UserSettingsEntity? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSettings => _settings != null;
  bool get isPremiumUser => _isPremiumUser;
  
  // Device Management Getters
  DeviceEntity? get currentDevice => _currentDevice;
  List<DeviceEntity> get connectedDevices => _connectedDevices;
  bool get isDeviceManagementEnabled => _featureFlagsProvider.isDeviceManagementEnabled;
  
  // DeviceEntity → DeviceInfo Adapter Methods
  /// Converts DeviceEntity to DeviceInfo for UI compatibility
  DeviceInfo _convertToDeviceInfo(DeviceEntity entity) {
    return DeviceInfo(
      uuid: entity.uuid,
      name: entity.name,
      model: entity.model,
      platform: entity.platform,
      systemVersion: entity.systemVersion,
      appVersion: entity.appVersion,
      buildNumber: entity.buildNumber,
      identifier: entity.id,
      isPhysicalDevice: entity.isPhysicalDevice,
      manufacturer: entity.manufacturer,
      firstLoginAt: entity.firstLoginAt,
      lastActiveAt: entity.lastActiveAt,
      isActive: entity.isActive,
    );
  }

  /// Current device as DeviceInfo for UI compatibility
  DeviceInfo? get currentDeviceInfo => _currentDevice != null 
      ? _convertToDeviceInfo(_currentDevice!) 
      : null;

  /// Connected devices as DeviceInfo list for UI compatibility
  List<DeviceInfo> get connectedDevicesInfo => _connectedDevices
      .map((device) => _convertToDeviceInfo(device))
      .toList();
  
  // Settings getters for easier access
  bool get isDarkTheme => _settings?.isDarkTheme ?? false;
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get soundEnabled => _settings?.soundEnabled ?? true;
  String get language => _settings?.language ?? 'pt-BR';
  bool get isDevelopmentMode => _settings?.isDevelopmentMode ?? false;
  bool get speechToTextEnabled => _settings?.speechToTextEnabled ?? false;
  bool get analyticsEnabled => _settings?.analyticsEnabled ?? true;

  void _initializeServices() {
    try {
      _premiumService = di.sl<IPremiumService>();
      _notificationService = di.sl<ReceitaAgroNotificationService>();
      _analyticsRepository = di.sl<IAnalyticsRepository>();
      _crashlyticsRepository = di.sl<ICrashlyticsRepository>();
      _appRatingRepository = di.sl<IAppRatingRepository>();
      _deviceIdentityService = di.sl<DeviceIdentityService>();
      _featureFlagsProvider = di.sl<FeatureFlagsProvider>();
      _deviceManagementService = di.sl<DeviceManagementService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  /// Initialize provider and load settings for user
  Future<void> initialize(String userId) async {
    if (userId.isEmpty) {
      _setError('Invalid user ID');
      return;
    }

    _currentUserId = userId;
    await Future.wait([
      loadSettings(),
      _loadPremiumStatus(),
      _loadDeviceInfo(),
    ]);
  }

  /// Load user settings
  Future<void> loadSettings() async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);
      
      _settings = await _getUserSettingsUseCase(_currentUserId);
      
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load premium status
  Future<void> _loadPremiumStatus() async {
    try {
      _isPremiumUser = await _premiumService.isPremiumUser();
      if (!_disposed) {
        notifyListeners();
      }
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

  // Premium Management Methods
  
  /// Generate test license (development only)
  Future<bool> generateTestLicense() async {
    try {
      await _premiumService.generateTestSubscription();
      await _loadPremiumStatus();
      return true;
    } catch (e) {
      _setError(e.toString());
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
      _setError(e.toString());
      debugPrint('Error removing test license: $e');
      return false;
    }
  }

  // Notification Management Methods
  
  /// Test notification functionality
  Future<bool> testNotification() async {
    try {
      // Check if notifications are enabled
      final isEnabled = await _notificationService.areNotificationsEnabled();
      
      if (!isEnabled) {
        // Request permission
        final granted = await _notificationService.requestNotificationPermission();
        if (!granted) {
          _setError('Permissão de notificação negada');
          return false;
        }
      }
      
      // Send test notification
      await _notificationService.showPestDetectedNotification(
        pestName: 'Lagarta-da-soja',
        plantName: 'Plantação Norte',
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error testing notification: $e');
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

  // Analytics and Crashlytics Methods
  
  /// Test analytics functionality
  Future<bool> testAnalytics() async {
    try {
      // Log test event
      await _analyticsRepository.logEvent(
        'test_analytics_button_pressed',
        parameters: {
          'screen': 'settings_page',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'app_version': '1.0.0',
        },
      );
      
      // Set user properties
      await _analyticsRepository.setUserProperties(
        properties: {
          'user_type': 'developer',
          'app_name': 'receituagro',
        },
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error testing analytics: $e');
      return false;
    }
  }

  /// Test crashlytics functionality
  Future<bool> testCrashlytics() async {
    try {
      // Record a test non-fatal error
      await _crashlyticsRepository.recordError(
        exception: Exception('Test error from ReceitaAgro settings'),
        stackTrace: StackTrace.current,
        reason: 'User triggered test error from settings page',
        fatal: false,
      );
      
      // Log a test message
      await _crashlyticsRepository.log('Test Crashlytics from ReceitaAgro settings');
      
      // Set user identifier for testing
      await _crashlyticsRepository.setUserId('test_user_receituagro');
      
      // Set custom keys
      await _crashlyticsRepository.setCustomKey(
        key: 'test_feature', 
        value: 'settings_crashlytics',
      );
      await _crashlyticsRepository.setCustomKey(
        key: 'app_section', 
        value: 'development',
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error testing crashlytics: $e');
      return false;
    }
  }

  // App Rating Methods
  
  /// Show app rating dialog
  Future<bool> showRateAppDialog(BuildContext context) async {
    try {
      // Check if we can show the rating dialog
      final canShow = await _appRatingRepository.canShowRatingDialog();
      
      if (canShow) {
        // Show the rate my app dialog
        // Check if context is still valid before using
        if (context.mounted) {
          await _appRatingRepository.showRatingDialog(context: context);
        }
        return true;
      } else {
        // Fallback: directly open the app store
        final success = await _appRatingRepository.openAppStore();
        return success;
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error showing rate app dialog: $e');
      return false;
    }
  }

  /// Update a single setting
  Future<bool> _updateSingleSetting(String key, dynamic value) async {
    if (_currentUserId.isEmpty) {
      _setError('User not initialized');
      return false;
    }

    try {
      _setError(null);
      
      _settings = await _updateUserSettingsUseCase.updateSingle(
        _currentUserId,
        key,
        value,
      );
      if (!_disposed) {
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating single setting: $e');
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading && !_disposed) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String? error) {
    if (_error != error && !_disposed) {
      _error = error;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadSettings(),
      _loadPremiumStatus(),
      _loadDeviceInfo(),
    ]);
  }

  // Device Management Methods
  
  /// Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      if (_currentUserId.isEmpty) {
        debugPrint('Cannot load device info: User ID is empty');
        return;
      }

      // Get current device info from identity service
      final deviceInfo = await _deviceIdentityService.getDeviceInfo();
      
      // Convert DeviceInfo to DeviceEntity for current device
      _currentDevice = DeviceEntity(
        id: deviceInfo.uuid,
        uuid: deviceInfo.uuid,
        name: deviceInfo.name,
        model: deviceInfo.model,
        platform: deviceInfo.platform,
        systemVersion: deviceInfo.systemVersion,
        appVersion: deviceInfo.appVersion,
        buildNumber: deviceInfo.buildNumber,
        isPhysicalDevice: deviceInfo.isPhysicalDevice,
        manufacturer: deviceInfo.manufacturer,
        firstLoginAt: deviceInfo.firstLoginAt,
        lastActiveAt: deviceInfo.lastActiveAt,
        isActive: deviceInfo.isActive,
      );

      // Get all devices from backend via DeviceManagementService
      final devicesResult = await _deviceManagementService.getUserDevices();
      
      devicesResult.fold(
        (failure) {
          debugPrint('Error loading devices from backend: $failure');
          // Use only current device if backend fails
          _connectedDevices = [_currentDevice!];
        },
        (devices) {
          _connectedDevices = devices;
          
          // Ensure current device is in the list
          final hasCurrentDevice = devices.any((d) => d.uuid == _currentDevice!.uuid);
          if (!hasCurrentDevice) {
            _connectedDevices.insert(0, _currentDevice!);
          }
        },
      );
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading device info: $e');
      // Fallback to empty state
      _currentDevice = null;
      _connectedDevices = [];
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Revoke device access
  Future<void> revokeDevice(String deviceUuid) async {
    try {
      if (_currentUserId.isEmpty) {
        _setError('Usuário não identificado');
        return;
      }

      // Call real DeviceManagementService
      final result = await _deviceManagementService.revokeDevice(deviceUuid);
      
      result.fold(
        (failure) {
          _setError('Erro ao revogar dispositivo: ${failure.message}');
          debugPrint('Error revoking device: $failure');
        },
        (_) {
          // Remove from local list on success
          _connectedDevices.removeWhere((device) => device.uuid == deviceUuid);
          
          if (!_disposed) {
            notifyListeners();
          }
          
          debugPrint('Device $deviceUuid revoked successfully');
        },
      );
      
    } catch (e) {
      _setError('Erro inesperado ao revogar dispositivo: $e');
      debugPrint('Unexpected error revoking device: $e');
    }
  }

  /// Add new device (called during login from new device)
  Future<bool> addDevice(DeviceEntity device) async {
    try {
      if (_currentUserId.isEmpty) {
        _setError('Usuário não identificado');
        return false;
      }

      // Check if user can add more devices via DeviceManagementService
      final canAddResult = await _deviceManagementService.canAddMoreDevices();
      
      return await canAddResult.fold(
        (failure) async {
          _setError('Erro ao verificar limite: ${failure.message}');
          debugPrint('Error checking device limit: $failure');
          return false;
        },
        (canAdd) async {
          if (!canAdd) {
            _setError('Limite de dispositivos atingido');
            return false;
          }

          // Validate and add device via DeviceManagementService
          final validateResult = await _deviceManagementService.validateDevice(device);
          
          return validateResult.fold(
            (failure) {
              _setError('Erro ao validar dispositivo: ${failure.message}');
              debugPrint('Error validating device: $failure');
              return false;
            },
            (validatedDevice) {
              // Add to local list on success
              _connectedDevices.add(validatedDevice);
              
              if (!_disposed) {
                notifyListeners();
              }
              
              debugPrint('Device ${device.uuid} added successfully');
              return true;
            },
          );
        },
      );
      
    } catch (e) {
      _setError('Erro inesperado ao adicionar dispositivo: $e');
      debugPrint('Unexpected error adding device: $e');
      return false;
    }
  }

  /// Check if user can add more devices
  Future<bool> canAddMoreDevices() async {
    try {
      if (_currentUserId.isEmpty) {
        return false;
      }

      final result = await _deviceManagementService.canAddMoreDevices();
      return result.fold(
        (failure) {
          debugPrint('Error checking if can add more devices: $failure');
          // Fallback to local count check
          return _connectedDevices.length < 3;
        },
        (canAdd) => canAdd,
      );
    } catch (e) {
      debugPrint('Unexpected error checking device limit: $e');
      // Fallback to local count check
      return _connectedDevices.length < 3;
    }
  }

  /// Get device by UUID
  DeviceEntity? getDeviceByUuid(String uuid) {
    try {
      return _connectedDevices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    
    // Cleanup notification service
    _notificationService.cancelAllNotifications().catchError((Object e) {
      debugPrint('Error cleaning notification resources: $e');
      return false;
    });
    
    _settings = null;
    super.dispose();
  }
}