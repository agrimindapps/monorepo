// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'alimentos_repository.dart';

part 'alimentos_provider.g.dart';

/// Provider for AlimentosRepository instance
@riverpod
AlimentosRepository alimentosRepository(Ref ref) {
  final repository = AlimentosRepository();
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
}

/// Provider for loading alimentos by category
@riverpod
class AlimentosNotifier extends _$AlimentosNotifier {
  @override
  Future<List<dynamic>> build(String categoria) async {
    final repository = ref.watch(alimentosRepositoryProvider);
    return repository.loadAlimentos(categoria);
  }

  /// Refresh alimentos list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(alimentosRepositoryProvider);
    state = await AsyncValue.guard(
      () => repository.loadAlimentos((state.value?.firstOrNull?['categoria'] as String?) ?? '0'),
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id, int index) async {
    final repository = ref.read(alimentosRepositoryProvider);
    final newStatus = await repository.setFavorito(id);

    // Update local state optimistically
    state.whenData((alimentos) {
      if (index < alimentos.length) {
        alimentos[index]['favorito'] = newStatus;
        state = AsyncValue.data([...alimentos]);
      }
    });
  }
}

/// Provider for alimentos properties
@riverpod
List<dynamic> alimentosProperties(Ref ref) {
  final repository = ref.watch(alimentosRepositoryProvider);
  return repository.getAlimentosProperties();
}

/// Provider for categorias
@riverpod
List<Map<String, dynamic>> alimentosCategorias(Ref ref) {
  final repository = ref.watch(alimentosRepositoryProvider);
  return repository.getCategorias();
}
