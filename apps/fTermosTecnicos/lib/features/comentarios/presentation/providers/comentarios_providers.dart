import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/comentario.dart';
import '../../domain/repositories/comentarios_repository.dart';
import '../../domain/usecases/add_comentario.dart';
import '../../domain/usecases/delete_comentario.dart';
import '../../domain/usecases/get_comentarios.dart';
import '../../domain/usecases/get_comentarios_by_ferramenta.dart';
import '../../domain/usecases/get_comentarios_count.dart';
import '../../domain/usecases/update_comentario.dart';

part 'comentarios_providers.g.dart';

// ==================== Repository Provider ====================

@riverpod
ComentariosRepository comentariosRepository(ComentariosRepositoryRef ref) {
  return getIt<ComentariosRepository>();
}

// ==================== Use Cases Providers ====================

@riverpod
GetComentarios getComentariosUseCase(GetComentariosUseCaseRef ref) {
  return getIt<GetComentarios>();
}

@riverpod
GetComentariosByFerramenta getComentariosByFerramentaUseCase(
  GetComentariosByFerramentaUseCaseRef ref,
) {
  return getIt<GetComentariosByFerramenta>();
}

@riverpod
AddComentario addComentarioUseCase(AddComentarioUseCaseRef ref) {
  return getIt<AddComentario>();
}

@riverpod
UpdateComentario updateComentarioUseCase(UpdateComentarioUseCaseRef ref) {
  return getIt<UpdateComentario>();
}

@riverpod
DeleteComentario deleteComentarioUseCase(DeleteComentarioUseCaseRef ref) {
  return getIt<DeleteComentario>();
}

@riverpod
GetComentariosCount getComentariosCountUseCase(
  GetComentariosCountUseCaseRef ref,
) {
  return getIt<GetComentariosCount>();
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
  ComentariosByFerramentaRef ref,
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
Future<int> comentariosCount(ComentariosCountRef ref) async {
  final useCase = ref.watch(getComentariosCountUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => 0,
    (count) => count,
  );
}

/// Get max comentarios limit (for free tier)
@riverpod
int maxComentarios(MaxComentariosRef ref) {
  return 10; // TODO: Get from premium service
}

/// Check if can add more comentarios
@riverpod
Future<bool> canAddComentario(CanAddComentarioRef ref) async {
  final count = await ref.watch(comentariosCountProvider.future);
  final maxLimit = ref.watch(maxComentariosProvider);

  return count < maxLimit;
}
