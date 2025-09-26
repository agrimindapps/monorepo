import 'package:core/core.dart';

/// Shared app-level state providers that can be used across different features
/// without creating circular dependencies.

/// Provider to track the currently selected vehicle ID
/// This avoids circular dependencies between vehicles and fuel/maintenance modules
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

/// Provider to track navigation state and selected context
final appNavigationProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider to track app-wide sync status
final appSyncStatusProvider = StateProvider<bool>((ref) => false);