import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_providers.g.dart';

/// Shared app-level state providers that can be used across different features
/// without creating circular dependencies.

/// Provider to track the currently selected vehicle ID
/// This avoids circular dependencies between vehicles and fuel/maintenance modules
/// Note: Use `selectedVehicleIdProvider` from vehicles_notifier.dart instead if available
@riverpod
class AppContextVehicleId extends _$AppContextVehicleId {
  @override
  String? build() => null;

  void select(String? id) => state = id;
  void clear() => state = null;
}

/// Provider to track navigation state and selected context
@riverpod
class AppNavigation extends _$AppNavigation {
  @override
  Map<String, dynamic> build() => {};

  void update(Map<String, dynamic> nav) => state = nav;
  void clear() => state = {};
}

/// Provider to track app-wide sync status
@riverpod
class AppSyncStatus extends _$AppSyncStatus {
  @override
  bool build() => false;

  void setStatus(bool status) => state = status;
}
