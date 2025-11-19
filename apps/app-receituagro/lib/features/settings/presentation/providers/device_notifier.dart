import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/device_settings_entity.dart';

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
  @override
  DeviceState build({String? initialDeviceId}) {
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
  Future<void> toggleSync() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.updateSyncStatus(
        enabled: !state.settings.syncEnabled,
      );

      // TODO: Persist to storage
      // await _persistDeviceSettings(updated);

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
  Future<void> syncNow() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Perform actual sync
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
  Future<void> addDevice(String deviceId) async {
    try {
      if (deviceId.isEmpty) {
        state = state.copyWith(error: 'ID do dispositivo inválido');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.addDevice(deviceId);

      // TODO: Persist to storage and notify backend
      // await _persistDeviceSettings(updated);
      // await _notifyBackendOfNewDevice(deviceId);

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
  Future<void> removeDevice(String deviceId) async {
    try {
      if (deviceId == state.settings.currentDeviceId) {
        state = state.copyWith(
          error: 'Não é possível remover o dispositivo atual',
        );
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.removeDevice(deviceId);

      // TODO: Persist to storage and notify backend
      // await _persistDeviceSettings(updated);
      // await _notifyBackendOfDeviceRemoval(deviceId);

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
  Future<void> loadDeviceSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Load from storage
      // final result = await _deviceRepository.getDeviceSettings();
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   ),
      //   (settings) => state = DeviceState(
      //     settings: settings,
      //     isLoading: false,
      //     error: null,
      //   ),
      // );

      // For now, use current state
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
