import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/premium_notifier.dart';
import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../../favoritos/favoritos_di.dart';

part 'detalhe_defensivo_notifier.g.dart';

/// Detalhe Defensivo state
class DetalheDefensivoState {
  final Fitossanitario? defensivoData;
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
    Fitossanitario? defensivoData,
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
///
/// IMPORTANTE: keepAlive mantém o state mesmo quando não há listeners
/// Isso previne perda de dados ao navegar entre tabs ou fazer rebuilds temporários
@Riverpod(keepAlive: true)
class DetalheDefensivoNotifier extends _$DetalheDefensivoNotifier {
  late final FitossanitariosRepository _fitossanitarioRepository;
  late final ComentariosService _comentariosService;
  late final FavoritosRepositorySimplified _favoritosRepository;

  @override
  Future<DetalheDefensivoState> build() async {
    _favoritosRepository = FavoritosDI.get<FavoritosRepositorySimplified>();
    _fitossanitarioRepository = di.sl<FitossanitariosRepository>();
    _comentariosService = di.sl<ComentariosService>();
    _setupPremiumStatusListener();

    return DetalheDefensivoState.initial();
  }

  /// Initialize data with optimized loading
  Future<void> initializeData(String defensivoName, String fabricante) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Set loading without resetting other data
    // Mantém isFavorited para evitar flicker visual
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        defensivoData: null, // Reset apenas dados do defensivo anterior
        comentarios: [], // Reset comentários do defensivo anterior
      ),
    );

    try {
      await _loadDefensivoData(defensivoName);
      await Future.wait([
        _loadFavoritoState(defensivoName),
        loadComentarios(),
        _loadPremiumStatus(),
      ]);

      final finalState = state.value;
      if (finalState != null) {
        state = AsyncValue.data(
          finalState.copyWith(isLoading: false).clearError(),
        );
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
    final defensivos = await _fitossanitarioRepository.findElegiveis();
    final defensivoData = defensivos
        .where((d) => d.nomeComum == defensivoName || d.nome == defensivoName)
        .firstOrNull;

    if (defensivoData == null) {
      throw Exception('Defensivo não encontrado');
    }

    state = AsyncValue.data(
      currentState.copyWith(defensivoData: defensivoData),
    );
  }

  /// Load favorito state using simplified consistent system
  Future<void> _loadFavoritoState(String defensivoName) async {
    final currentState = state.value;
    if (currentState == null) return;

    final itemId = currentState.defensivoData?.idDefensivo ?? defensivoName;

    try {
      final result = await _favoritosRepository.isFavorito(
        'defensivo',
        itemId,
      );

      // Unwrap Either<Failure, bool> and update state
      final isFavorited = result.fold(
        (failure) => false, // On failure, assume not favorited
        (value) => value,
      );

      // Sempre atualiza o estado, mesmo se estiver no mesmo valor
      // Isso garante que o estado correto seja carregado do repositório
      final newState = state.value;
      if (newState != null) {
        state = AsyncValue.data(newState.copyWith(isFavorited: isFavorited));
      }
    } catch (e) {
      // Em caso de erro, assume não favorito
      final newState = state.value;
      if (newState != null) {
        state = AsyncValue.data(newState.copyWith(isFavorited: false));
      }
    }
  }

  /// Load comentarios
  Future<void> loadComentarios() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingComments: true));

    try {
      final pkIdentificador = currentState.defensivoData?.idDefensivo ?? '';
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

    if (!_comentariosService.canAddComentario(
      currentState.comentarios.length,
    )) {
      return false;
    }

    final newComment = ComentarioModel(
      id: _comentariosService.generateId(),
      idReg: _comentariosService.generateIdReg(),
      titulo: '',
      conteudo: content,
      ferramenta: 'defensivos',
      pkIdentificador: currentState.defensivoData?.idDefensivo ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _comentariosService.addComentario(newComment);

      final updatedComentarios = [...currentState.comentarios, newComment];
      state = AsyncValue.data(
        currentState.copyWith(comentarios: updatedComentarios),
      );

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

      final updatedComentarios = currentState.comentarios
          .where((c) => c.id != commentId)
          .toList();
      state = AsyncValue.data(
        currentState.copyWith(comentarios: updatedComentarios),
      );

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
    final itemId = currentState.defensivoData?.idDefensivo ?? defensivoName;
    state = AsyncValue.data(
      currentState.copyWith(isFavorited: !wasAlreadyFavorited),
    );

    try {
      final result = await _favoritosRepository.toggleFavorito(
        'defensivo',
        itemId,
      );

      // Unwrap Either<Failure, bool>
      return result.fold(
        (failure) {
          // On failure, revert state
          state = AsyncValue.data(
            currentState.copyWith(
              isFavorited: wasAlreadyFavorited,
              errorMessage:
                  'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
            ),
          );
          return false;
        },
        (success) {
          // On success, keep the toggled state
          if (!success) {
            state = AsyncValue.data(
              currentState.copyWith(
                isFavorited: wasAlreadyFavorited,
                errorMessage:
                    'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
              ),
            );
          }
          return success;
        },
      );
    } catch (e) {
      // On exception, revert state
      state = AsyncValue.data(
        currentState.copyWith(
          isFavorited: wasAlreadyFavorited,
          errorMessage:
              'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  /// Refresh data
  Future<void> refresh(String defensivoName, String fabricante) async {
    await initializeData(defensivoName, fabricante);
  }

  /// Load premium status
  Future<void> _loadPremiumStatus() async {
    final currentState = state.value;
    if (currentState == null) return;

    final premiumState = ref.read(premiumNotifierProvider).value;
    state = AsyncValue.data(
      currentState.copyWith(isPremium: premiumState?.isPremium ?? false),
    );
  }

  /// Setup premium status listener
  void _setupPremiumStatusListener() {
    ref.listen(premiumNotifierProvider, (previous, next) {
      final currentState = state.value;
      if (currentState != null) {
        next.whenData((premiumState) {
          state = AsyncValue.data(
            currentState.copyWith(isPremium: premiumState.isPremium),
          );
        });
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
  String getValidationErrorMessage() =>
      _comentariosService.getValidationErrorMessage();

  bool canAddComentario(int currentCount) =>
      _comentariosService.canAddComentario(currentCount);

  bool isValidContent(String content) =>
      _comentariosService.isValidContent(content);
}
