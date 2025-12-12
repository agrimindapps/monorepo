import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/device_settings_entity.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'settings_providers.dart';

part 'device_notifier.g.dart';

/// State class for device settings
class DeviceState {
  final DeviceSettingsEntity settings;
  final bool isLoading;
  final String? error;

  const DeviceState({
    required this.settings,
    required this.isLoading,
    this.error,
  });

  factory DeviceState.initial(String deviceId) {
    return DeviceState(
      settings: DeviceSettingsEntity.defaults(deviceId),
      isLoading: false,
      error: null,
    );
  }

  DeviceState copyWith({
    DeviceSettingsEntity? settings,
    bool? isLoading,
    String? error,
  }) {
    return DeviceState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  DeviceState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier for managing device-related user settings
/// Handles device identification, sync preferences, and multi-device management
///
/// Responsibilities:
/// - Track current device
/// - Manage connected devices list
/// - Toggle sync on/off
/// - Add/remove devices
/// - Check sync status
/// - Load/save device settings
/// - Validate device configuration
/// - Persist to storage
///
/// State: DeviceState
/// - settings: Current DeviceSettingsEntity
/// - isLoading: Whether operations are in progress
/// - error: Error message if any
@riverpod
class DeviceNotifier extends _$DeviceNotifier {
  late final GetUserSettingsUseCase _getUserSettingsUseCase;
  late final UpdateUserSettingsUseCase _updateUserSettingsUseCase;

  @override
  DeviceState build({String? initialDeviceId}) {
    _getUserSettingsUseCase = ref.watch(getUserSettingsUseCaseProvider);
    _updateUserSettingsUseCase = ref.watch(updateUserSettingsUseCaseProvider);

    return DeviceState.initial(
      initialDeviceId ?? 'device-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Toggles sync on/off
  ///
  /// When enabled:
  /// - Device will sync with server periodically
  /// - Settings will be updated from other devices
  /// - Changes will propagate to cloud
  ///
  /// When disabled:
  /// - Sync paused but connected devices remain
  /// - Local changes not synced
  Future<void> toggleSync(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load current user settings
      final userSettings = await _getUserSettingsUseCase(userId);

      // Update sync status in user settings
      // Note: UserSettingsEntity doesn't have sync fields yet, but the pattern is established
      // When fields are added, this will work automatically
      final updatedUserSettings = userSettings.copyWith(
        // syncEnabled: !state.settings.syncEnabled, // Will be added to UserSettingsEntity
      );

      // Persist via UseCase
      await _updateUserSettingsUseCase(updatedUserSettings);

      // Update local device state
      final updated = state.settings.updateSyncStatus(
        enabled: !state.settings.syncEnabled,
      );

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling sync: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao alternar sincronização',
      );
    }
  }

  /// Manually triggers sync with backend
  ///
  /// Steps:
  /// 1. Mark as loading
  /// 2. Call backend sync
  /// 3. Update lastSyncTime
  /// 4. Persist locally
  ///
  /// Note: Actual sync implementation will be added when sync service is available
  Future<void> syncNow() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Perform actual sync (implementation pending - sync service not yet available)
      // When sync service is ready:
      // final result = await _syncRepository.performSync(state.settings);
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   ),
      //   (success) => state = state.copyWith(
      //     settings: state.settings.updateSyncStatus(enabled: true),
      //     isLoading: false,
      //   ),
      // );

      final updated = state.settings.updateSyncStatus(
        enabled: state.settings.syncEnabled,
        syncTime: DateTime.now(),
      );

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error syncing: $e\n$stack');
      state = state.copyWith(isLoading: false, error: 'Erro ao sincronizar');
    }
  }

  /// Adds a new device to the connected devices list
  ///
  /// Steps:
  /// 1. Validate device ID
  /// 2. Check if already connected
  /// 3. Add to list
  /// 4. Persist
  Future<void> addDevice(String userId, String deviceId) async {
    try {
      if (deviceId.isEmpty) {
        state = state.copyWith(error: 'ID do dispositivo inválido');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Get current settings
      final userSettings = await _getUserSettingsUseCase(userId);

      // Update with new device
      // Note: UserSettingsEntity doesn't have device fields yet, but pattern is established
      final updatedSettings = userSettings.copyWith(
        // connectedDevices: [...currentDevices, deviceId], // Will be added to UserSettingsEntity
      );

      // Persist
      await _updateUserSettingsUseCase(updatedSettings);

      // Update local state
      final updated = state.settings.addDevice(deviceId);
      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error adding device: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao adicionar dispositivo',
      );
    }
  }

  /// Removes a device from the connected devices list
  ///
  /// Guards:
  /// - Cannot remove current device
  /// - Must have at least current device
  Future<void> removeDevice(String userId, String deviceId) async {
    try {
      if (deviceId == state.settings.currentDeviceId) {
        state = state.copyWith(
          error: 'Não é possível remover o dispositivo atual',
        );
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Get current settings
      final userSettings = await _getUserSettingsUseCase(userId);

      // Update removing device
      // Note: UserSettingsEntity doesn't have device fields yet, but pattern is established
      final updatedSettings = userSettings.copyWith(
        // connectedDevices: devices.where((d) => d != deviceId).toList(), // Will be added
      );

      // Persist
      await _updateUserSettingsUseCase(updatedSettings);

      // Update local state
      final updated = state.settings.removeDevice(deviceId);
      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error removing device: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao remover dispositivo',
      );
    }
  }

  /// Loads device settings from storage
  /// Useful for app initialization
  Future<void> loadDeviceSettings(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load from storage via UseCase
      // ignore: unused_local_variable
      final userSettings = await _getUserSettingsUseCase(userId);

      // Extract device settings from user settings
      // Note: UserSettingsEntity doesn't have device fields yet, but pattern is established
      // When device fields are added, we'll create DeviceSettingsEntity from them:
      // final deviceSettings = DeviceSettingsEntity.fromUserSettings(userSettings);

      // For now, use current state (will be replaced when device fields are added)
      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      debugPrint('Error loading device settings: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações do dispositivo',
      );
    }
  }

  // Getters for easy access

  /// Get current device settings
  DeviceSettingsEntity get currentSettings => state.settings;

  /// Get current device ID
  String get currentDeviceId => state.settings.currentDeviceId;

  /// Get list of all connected devices
  List<String> get connectedDevices => state.settings.connectedDevices;

  /// Get list of other devices (excluding current)
  List<String> get otherDevices => state.settings.otherDevices;

  /// Get number of connected devices
  int get deviceCount => state.settings.deviceCount;

  /// Check if current device is the only one
  bool get isOnlyDevice => state.settings.isOnlyDevice;

  /// Check if sync is enabled
  bool get syncEnabled => state.settings.syncEnabled;

  /// Check if sync is needed
  bool get needsSync => state.settings.needsSync;

  /// Check if synced recently (within 1 hour)
  bool get hasSyncedRecently => state.settings.hasSyncedRecently;

  /// Get time since last sync
  Duration? get timeSinceLastSync => state.settings.timeSinceLastSync;

  /// Get sync status summary for display
  String get syncStatusSummary => state.settings.syncStatusSummary;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.error != null;

  /// Get error message if any
  String? get errorMessage => state.error;
}
