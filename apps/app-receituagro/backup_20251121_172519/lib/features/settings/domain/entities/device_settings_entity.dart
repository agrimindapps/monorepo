/// Domain entity representing device-related user settings.
/// Responsible for managing device identification, sync preferences, and connected devices.
///
/// Business Rules:
/// - currentDeviceId must be a valid UUID or identifier
/// - connectedDevices is a list of device identifiers associated with this user
/// - syncEnabled can be toggled to pause sync without removing devices
/// - lastSyncTime tracks the most recent successful sync
class DeviceSettingsEntity {
  final String currentDeviceId;
  final List<String> connectedDevices;
  final bool syncEnabled;
  final DateTime? lastSyncTime;
  final DateTime lastUpdated;

  const DeviceSettingsEntity({
    required this.currentDeviceId,
    required this.connectedDevices,
    required this.syncEnabled,
    this.lastSyncTime,
    required this.lastUpdated,
  });

  /// Creates a copy of this entity with the given fields replaced.
  /// If a field is not provided, the current value is retained.
  DeviceSettingsEntity copyWith({
    String? currentDeviceId,
    List<String>? connectedDevices,
    bool? syncEnabled,
    DateTime? lastSyncTime,
    DateTime? lastUpdated,
  }) {
    return DeviceSettingsEntity(
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Creates default device settings for a new device.
  /// Defaults: Current device as only device, sync enabled, no previous sync
  static DeviceSettingsEntity defaults(String deviceId) {
    return DeviceSettingsEntity(
      currentDeviceId: deviceId,
      connectedDevices: [deviceId],
      syncEnabled: true,
      lastSyncTime: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Check if device settings are valid
  /// Valid when: currentDeviceId is not empty and is in connectedDevices list
  bool get isValid {
    return currentDeviceId.isNotEmpty &&
        connectedDevices.contains(currentDeviceId);
  }

  /// Business rule: Check if current device is the only connected device
  bool get isOnlyDevice {
    return connectedDevices.length == 1 &&
        connectedDevices.contains(currentDeviceId);
  }

  /// Business rule: Get number of connected devices
  int get deviceCount => connectedDevices.length;

  /// Business rule: Get other connected devices (excluding current)
  List<String> get otherDevices {
    return connectedDevices
        .where((device) => device != currentDeviceId)
        .toList();
  }

  /// Business rule: Check if sync is needed
  /// Sync is needed if: sync is enabled AND (never synced OR last sync is older than 24h)
  bool get needsSync {
    if (!syncEnabled) return false;

    if (lastSyncTime == null) return true;

    final timeSinceLastSync = DateTime.now().difference(lastSyncTime!);
    return timeSinceLastSync.inHours >= 24;
  }

  /// Business rule: Check if device is connected
  bool isDeviceConnected(String deviceId) {
    return connectedDevices.contains(deviceId);
  }

  /// Business rule: Add a new device to the connected devices list
  /// Returns a new entity with the device added if not already present
  DeviceSettingsEntity addDevice(String deviceId) {
    if (connectedDevices.contains(deviceId)) {
      return this;
    }

    final updatedDevices = [...connectedDevices, deviceId];
    return copyWith(
      connectedDevices: updatedDevices,
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Remove a device from the connected devices list
  /// Cannot remove the current device
  DeviceSettingsEntity removeDevice(String deviceId) {
    if (deviceId == currentDeviceId) {
      throw ArgumentError('Cannot remove current device');
    }

    final updatedDevices = connectedDevices
        .where((device) => device != deviceId)
        .toList();

    return copyWith(
      connectedDevices: updatedDevices,
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Update sync status
  /// Returns a new entity with updated sync settings and last sync time
  DeviceSettingsEntity updateSyncStatus({
    required bool enabled,
    DateTime? syncTime,
  }) {
    return copyWith(
      syncEnabled: enabled,
      lastSyncTime: syncTime ?? (enabled ? DateTime.now() : lastSyncTime),
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Get time since last sync
  /// Returns null if never synced, otherwise returns Duration
  Duration? get timeSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().difference(lastSyncTime!);
  }

  /// Business rule: Check if device has synced recently (within 1 hour)
  bool get hasSyncedRecently {
    if (lastSyncTime == null) return false;
    final timeSince = DateTime.now().difference(lastSyncTime!);
    return timeSince.inMinutes < 60;
  }

  /// Business rule: Get sync status summary
  String get syncStatusSummary {
    if (!syncEnabled) {
      return 'Sincronização desativada';
    }

    if (lastSyncTime == null) {
      return 'Nunca sincronizado';
    }

    final timeSince = timeSinceLastSync!;
    if (timeSince.inMinutes < 1) {
      return 'Sincronizado agora';
    }
    if (timeSince.inMinutes < 60) {
      return 'Sincronizado há ${timeSince.inMinutes}m';
    }
    if (timeSince.inHours < 24) {
      return 'Sincronizado há ${timeSince.inHours}h';
    }

    return 'Sincronizado há ${timeSince.inDays}d';
  }

  @override
  String toString() {
    return 'DeviceSettingsEntity('
        'currentDeviceId: $currentDeviceId, '
        'connectedDevices: $connectedDevices, '
        'syncEnabled: $syncEnabled, '
        'lastSyncTime: $lastSyncTime, '
        'lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceSettingsEntity &&
        other.currentDeviceId == currentDeviceId &&
        _listEquals(other.connectedDevices, connectedDevices) &&
        other.syncEnabled == syncEnabled &&
        other.lastSyncTime == lastSyncTime &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return currentDeviceId.hashCode ^
        connectedDevices.hashCode ^
        syncEnabled.hashCode ^
        lastSyncTime.hashCode ^
        lastUpdated.hashCode;
  }

  /// Helper function to compare lists
  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
