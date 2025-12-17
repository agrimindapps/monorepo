import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_providers.g.dart';

/// Shared app-level state providers that can be used across different features
/// without creating circular dependencies.

/// Provider to track the currently selected animal ID
/// This avoids circular dependencies between animals and appointments modules
@riverpod
class SelectedAnimalId extends _$SelectedAnimalId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
  void clear() => state = null;
}

/// Provider to track navigation state and selected context
@riverpod
class AppNavigation extends _$AppNavigation {
  @override
  Map<String, dynamic> build() => {};

  void update(Map<String, dynamic> newState) => state = newState;
  void setKey(String key, dynamic value) => state = {...state, key: value};
  void clear() => state = {};
}
