import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared app-level state providers that can be used across different features
/// without creating circular dependencies.

/// Provider to track the currently selected animal ID
/// This avoids circular dependencies between animals and appointments modules
final selectedAnimalIdProvider = StateProvider<String?>((ref) => null);

/// Provider to track navigation state and selected context
final appNavigationProvider = StateProvider<Map<String, dynamic>>((ref) => {});