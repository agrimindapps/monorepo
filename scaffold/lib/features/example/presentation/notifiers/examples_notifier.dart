import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/usecases/add_example_usecase.dart';
import '../../domain/usecases/update_example_usecase.dart';
import '../../domain/usecases/delete_example_usecase.dart';
import '../../domain/usecases/get_examples_usecase.dart';
import '../providers/example_providers.dart';

part 'examples_notifier.g.dart'; // Generated file

/// State notifier for examples list
/// Manages the list of examples with CRUD operations
@riverpod
class ExamplesNotifier extends _$ExamplesNotifier {
  @override
  Future<List<ExampleEntity>> build() async {
    // Load initial state
    final useCase = ref.watch(getExamplesUseCaseProvider);
    final result = await useCase(NoParams());

    return result.fold(
      (failure) => throw failure, // AsyncValue will capture this
      (examples) => examples,
    );
  }

  /// Add a new example
  Future<void> addExample({
    required String name,
    String? description,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(addExampleUseCaseProvider);

      final result = await useCase(AddExampleParams(
        name: name,
        description: description,
      ));

      return result.fold(
        (failure) => throw failure,
        (_) async {
          // Reload list after adding
          final getUseCase = ref.read(getExamplesUseCaseProvider);
          final getResult = await getUseCase(NoParams());

          return getResult.fold(
            (failure) => throw failure,
            (examples) => examples,
          );
        },
      );
    });
  }

  /// Update an existing example
  Future<void> updateExample({
    required String id,
    String? name,
    String? description,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateExampleUseCaseProvider);

      final result = await useCase(UpdateExampleParams(
        id: id,
        name: name,
        description: description,
      ));

      return result.fold(
        (failure) => throw failure,
        (updatedExample) {
          // Optimistic update - update in current list
          final currentExamples = state.value ?? [];
          return currentExamples.map((example) {
            return example.id == updatedExample.id ? updatedExample : example;
          }).toList();
        },
      );
    });
  }

  /// Delete an example
  Future<void> deleteExample(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(deleteExampleUseCaseProvider);

      final result = await useCase(DeleteExampleParams(id: id));

      return result.fold(
        (failure) => throw failure,
        (_) {
          // Remove from current list
          final currentExamples = state.value ?? [];
          return currentExamples.where((example) => example.id != id).toList();
        },
      );
    });
  }

  /// Refresh the list
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getExamplesUseCaseProvider);
      final result = await useCase(NoParams());

      return result.fold(
        (failure) => throw failure,
        (examples) => examples,
      );
    });
  }
}
