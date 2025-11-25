import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/database_providers.dart';
import '../../data/datasources/local/comentarios_local_datasource.dart';
import '../../data/repositories/comentarios_repository_impl.dart';
import '../../domain/entities/comentario.dart';
import '../../domain/repositories/comentarios_repository.dart';
import '../../domain/usecases/add_comentario.dart';
import '../../domain/usecases/delete_comentario.dart';
import '../../domain/usecases/get_comentarios.dart';
import '../../domain/usecases/get_comentarios_by_ferramenta.dart';
import '../../domain/usecases/get_comentarios_count.dart';
import '../../domain/usecases/update_comentario.dart';

part 'comentarios_providers.g.dart';

// ==================== Data Source Provider ====================

@riverpod
ComentariosLocalDataSource comentariosLocalDataSource(Ref ref) {
  final database = ref.watch(termosTecnicosDatabaseProvider);
  return ComentariosLocalDataSourceImpl(database);
}

// ==================== Repository Provider ====================

@riverpod
ComentariosRepository comentariosRepository(Ref ref) {
  final dataSource = ref.watch(comentariosLocalDataSourceProvider);
  return ComentariosRepositoryImpl(dataSource);
}

// ==================== Use Cases Providers ====================

@riverpod
GetComentarios getComentariosUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return GetComentarios(repository);
}

@riverpod
GetComentariosByFerramenta getComentariosByFerramentaUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return GetComentariosByFerramenta(repository);
}

@riverpod
AddComentario addComentarioUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return AddComentario(repository);
}

@riverpod
UpdateComentario updateComentarioUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return UpdateComentario(repository);
}

@riverpod
DeleteComentario deleteComentarioUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return DeleteComentario(repository);
}

@riverpod
GetComentariosCount getComentariosCountUseCase(Ref ref) {
  final repository = ref.watch(comentariosRepositoryProvider);
  return GetComentariosCount(repository);
}

// ==================== State Notifier ====================

/// Main state notifier for Comentarios list
@riverpod
class ComentariosNotifier extends _$ComentariosNotifier {
  @override
  Future<List<Comentario>> build() async {
    return _loadComentarios();
  }

  Future<List<Comentario>> _loadComentarios() async {
    final useCase = ref.read(getComentariosUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (comentarios) => comentarios,
    );
  }

  /// Add new comentario
  Future<void> addComentario(Comentario comentario) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(addComentarioUseCaseProvider);
      final result = await useCase(comentario);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async => await _loadComentarios(),
      );
    });
  }

  /// Update existing comentario
  Future<void> updateComentario(Comentario comentario) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateComentarioUseCaseProvider);
      final result = await useCase(comentario);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async => await _loadComentarios(),
      );
    });
  }

  /// Delete comentario by ID
  Future<void> deleteComentario(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(deleteComentarioUseCaseProvider);
      final result = await useCase(id);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async => await _loadComentarios(),
      );
    });
  }

  /// Refresh comentarios list
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _loadComentarios();
    });
  }
}

// ==================== Filtered Providers ====================

/// Get comentarios by ferramenta
@riverpod
Future<List<Comentario>> comentariosByFerramenta(
  Ref ref,
  String ferramenta,
) async {
  final useCase = ref.watch(getComentariosByFerramentaUseCaseProvider);
  final result = await useCase(ferramenta);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (comentarios) => comentarios,
  );
}

// ==================== Statistics Provider ====================

/// Get count of comentarios
@riverpod
Future<int> comentariosCount(Ref ref) async {
  final useCase = ref.watch(getComentariosCountUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => 0,
    (count) => count,
  );
}

/// Get max comentarios limit (for free tier)
@riverpod
int maxComentarios(Ref ref) {
  return 10; // TODO: Get from premium service
}

/// Check if can add more comentarios
@riverpod
Future<bool> canAddComentario(Ref ref) async {
  final count = await ref.watch(comentariosCountProvider.future);
  final maxLimit = ref.watch(maxComentariosProvider);

  return count < maxLimit;
}
