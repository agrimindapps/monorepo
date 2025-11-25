import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_providers.dart';
import '../providers/animals_ui_state_provider.dart';

part 'animals_ui_state_notifier.g.dart';

// Re-export the AnimalsUIState and AnimalsUIStateNotifier from the provider file
// to maintain backward compatibility
export '../providers/animals_ui_state_provider.dart' show AnimalsUIState;

/// Computed provider for filtered and paginated animals
/// This is kept for backward compatibility - use filteredAnimalsProvider from animals_ui_state_provider.dart
@riverpod
List<Animal> filteredAnimalsComputed(Ref ref) {
  final animalsState = ref.watch(animalsProvider);
  final uiState = ref.watch(animalsUIStateNotifierProvider);
  final animals = animalsState.animals;
  final maxItems = uiState.displayItemCount;

  return animals.take(maxItems).toList();
}
