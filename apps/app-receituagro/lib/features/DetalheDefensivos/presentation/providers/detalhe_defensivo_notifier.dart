import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/premium_status_notifier.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';

part 'detalhe_defensivo_notifier.g.dart';

/// Detalhe Defensivo state
class DetalheDefensivoState {
  final FitossanitarioHive? defensivoData;
  final List<ComentarioModel> comentarios;
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isLoadingComments;
  final String? errorMessage;

  const DetalheDefensivoState({
    this.defensivoData,
    required this.comentarios,
    required this.isFavorited,
    required this.isPremium,
    required this.isLoading,
    required this.isLoadingComments,
    this.errorMessage,
  });

  factory DetalheDefensivoState.initial() {
    return const DetalheDefensivoState(
      defensivoData: null,
      comentarios: [],
      isFavorited: false,
      isPremium: false,
      isLoading: false,
      isLoadingComments: false,
      errorMessage: null,
    );
  }

  DetalheDefensivoState copyWith({
    FitossanitarioHive? defensivoData,
    List<ComentarioModel>? comentarios,
    bool? isFavorited,
    bool? isPremium,
    bool? isLoading,
    bool? isLoadingComments,
    String? errorMessage,
  }) {
    return DetalheDefensivoState(
      defensivoData: defensivoData ?? this.defensivoData,
      comentarios: comentarios ?? this.comentarios,
      isFavorited: isFavorited ?? this.isFavorited,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DetalheDefensivoState clearError() {
    return copyWith(errorMessage: null);
  }
  bool get hasError => errorMessage != null;
  bool get hasDefensivo => defensivoData != null;
  bool get hasComentarios => comentarios.isNotEmpty;
}

/// Notifier para gerenciar estado de Detalhe Defensivo (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class DetalheDefensivoNotifier extends _$DetalheDefensivoNotifier {
  late final FavoritosHiveRepository _favoritosHiveRepository;
  late final FitossanitarioHiveRepository _fitossanitarioRepository;
  late final ComentariosService _comentariosService;
  late final FavoritosRepositorySimplified _favoritosRepository;

  StreamSubscription<bool>? _premiumStatusSubscription;

  @override
  Future<DetalheDefensivoState> build() async {
    _favoritosRepository = FavoritosDI.get<FavoritosRepositorySimplified>();
    _fitossanitarioRepository = di.sl<FitossanitarioHiveRepository>();
    _comentariosService = di.sl<ComentariosService>();
    _setupPremiumStatusListener();

    return DetalheDefensivoState.initial();
  }

  /// Initialize data with optimized loading
  Future<void> initializeData(String defensivoName, String fabricante) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      await _loadDefensivoData(defensivoName);
      await Future.wait([
        _loadFavoritoState(defensivoName),
        loadComentarios(),
      ]);

      final finalState = state.value;
      if (finalState != null) {
        state = AsyncValue.data(finalState.copyWith(isLoading: false).clearError());
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar dados: $e',
        ),
      );
    }
  }

  /// Load real defensivo data with optimized cache
  Future<void> _loadDefensivoData(String defensivoName) async {
    final currentState = state.value;
    if (currentState == null) return;
    final result = await _fitossanitarioRepository.getAll();
    if (result.isError) {
      throw Exception('Erro ao acessar dados: ${result.error}');
    }

    var defensivos = result.data!.where(
      (d) => d.nomeComum == defensivoName,
    );
    if (defensivos.isEmpty) {
      defensivos = result.data!.where(
        (d) => d.nomeTecnico == defensivoName,
      );
    }

    final defensivoData = defensivos.isNotEmpty ? defensivos.first : null;

    if (defensivoData == null) {
      throw Exception('Defensivo não encontrado');
    }

    state = AsyncValue.data(currentState.copyWith(defensivoData: defensivoData));
  }

  /// Load favorito state using simplified consistent system
  Future<void> _loadFavoritoState(String defensivoName) async {
    final currentState = state.value;
    if (currentState == null) return;

    final itemId = currentState.defensivoData?.idReg ?? defensivoName;

    try {
      final isFavorited = await _favoritosRepository.isFavorito('defensivo', itemId);
      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
    } catch (e) {
      try {
        final isFavorited = await _favoritosRepository.isFavorito('defensivo', itemId);
        state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
      } catch (fallbackError) {
        final isFavorited = await _favoritosRepository.isFavorito('defensivo', itemId);
        state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
      }
    }
  }

  /// Load comentarios
  Future<void> loadComentarios() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingComments: true));

    try {
      final pkIdentificador = currentState.defensivoData?.idReg ?? '';
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          comentarios: comentarios,
          isLoadingComments: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoadingComments: false));
    }
  }

  /// Add new comment
  Future<bool> addComment(String content) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (!_comentariosService.isValidContent(content)) {
      return false;
    }

    if (!_comentariosService.canAddComentario(currentState.comentarios.length)) {
      return false;
    }

    final newComment = ComentarioModel(
      id: _comentariosService.generateId(),
      idReg: _comentariosService.generateIdReg(),
      titulo: '',
      conteudo: content,
      ferramenta: 'defensivos',
      pkIdentificador: currentState.defensivoData?.idReg ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _comentariosService.addComentario(newComment);

      final updatedComentarios = [...currentState.comentarios, newComment];
      state = AsyncValue.data(currentState.copyWith(comentarios: updatedComentarios));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete comment
  Future<bool> deleteComment(String commentId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      await _comentariosService.deleteComentario(commentId);

      final updatedComentarios = currentState.comentarios.where((c) => c.id != commentId).toList();
      state = AsyncValue.data(currentState.copyWith(comentarios: updatedComentarios));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorito using simplified system
  Future<bool> toggleFavorito(String defensivoName, String fabricante) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final wasAlreadyFavorited = currentState.isFavorited;
    final itemId = currentState.defensivoData?.idReg ?? defensivoName;
    state = AsyncValue.data(currentState.copyWith(isFavorited: !wasAlreadyFavorited));

    try {
      final success = await _favoritosRepository.toggleFavorito('defensivo', itemId);

      if (!success) {
        state = AsyncValue.data(
          currentState.copyWith(
            isFavorited: wasAlreadyFavorited,
            errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
          ),
        );
        return false;
      }

      return true;
    } catch (e) {
      try {
        final success = wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('defensivo', itemId)
            : await _favoritosRepository.addFavorito('defensivo', itemId);

        if (!success) {
          state = AsyncValue.data(
            currentState.copyWith(
              isFavorited: wasAlreadyFavorited,
              errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
            ),
          );
          return false;
        }

        return true;
      } catch (fallbackError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isFavorited: wasAlreadyFavorited,
            errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito: ${fallbackError.toString()}',
          ),
        );
        return false;
      }
    }
  }

  /// Refresh data
  Future<void> refresh(String defensivoName, String fabricante) async {
    await initializeData(defensivoName, fabricante);
  }

  /// Setup premium status listener
  void _setupPremiumStatusListener() {
    _premiumStatusSubscription?.cancel();
    _premiumStatusSubscription = PremiumStatusNotifier.instance
        .premiumStatusStream
        .listen((isPremiumStatus) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(isPremium: isPremiumStatus));
      }
    });
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Public getters for external access
  String getValidationErrorMessage() => _comentariosService.getValidationErrorMessage();

  bool canAddComentario(int currentCount) => _comentariosService.canAddComentario(currentCount);

  bool isValidContent(String content) => _comentariosService.isValidContent(content);

  /// Dispose
  void disposeNotifier() {
    _premiumStatusSubscription?.cancel();
  }
}
