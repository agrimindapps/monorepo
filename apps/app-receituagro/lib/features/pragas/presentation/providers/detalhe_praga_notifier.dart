import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/premium_notifier.dart';
import '../../../../database/receituagro_database.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../domain/entities/praga_entity.dart';
import 'pragas_providers.dart';

part 'detalhe_praga_notifier.g.dart';

/// Detalhe Praga state
class DetalhePragaState {
  final String pragaName;
  final String pragaScientificName;
  final Praga? pragaData;
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isLoadingComments;
  final String? errorMessage;
  final List<ComentarioModel> comentarios;
  final Map<String, dynamic>? defensivoData;
  final PragasInfData? pragaInfo; // Using Drift generated type
  final PlantasInfData? plantaInfo; // Using Drift generated type (if exists)

  const DetalhePragaState({
    required this.pragaName,
    required this.pragaScientificName,
    this.pragaData,
    required this.isFavorited,
    required this.isPremium,
    required this.isLoading,
    required this.isLoadingComments,
    this.errorMessage,
    required this.comentarios,
    this.defensivoData,
    this.pragaInfo,
    this.plantaInfo,
  });

  factory DetalhePragaState.initial() {
    return const DetalhePragaState(
      pragaName: '',
      pragaScientificName: '',
      pragaData: null,
      isFavorited: false,
      isPremium: false,
      isLoading: false,
      isLoadingComments: false,
      errorMessage: null,
      comentarios: [],
      defensivoData: null,
      pragaInfo: null,
      plantaInfo: null,
    );
  }

  DetalhePragaState copyWith({
    String? pragaName,
    String? pragaScientificName,
    Praga? pragaData,
    bool? isFavorited,
    bool? isPremium,
    bool? isLoading,
    bool? isLoadingComments,
    String? errorMessage,
    List<ComentarioModel>? comentarios,
    Map<String, dynamic>? defensivoData,
    PragasInfData? pragaInfo, // Updated to Drift type
    PlantasInfData? plantaInfo, // Updated to Drift type
  }) {
    return DetalhePragaState(
      pragaName: pragaName ?? this.pragaName,
      pragaScientificName: pragaScientificName ?? this.pragaScientificName,
      pragaData: pragaData ?? this.pragaData,
      isFavorited: isFavorited ?? this.isFavorited,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      errorMessage: errorMessage ?? this.errorMessage,
      comentarios: comentarios ?? this.comentarios,
      defensivoData: defensivoData ?? this.defensivoData,
      pragaInfo: pragaInfo ?? this.pragaInfo,
      plantaInfo: plantaInfo ?? this.plantaInfo,
    );
  }

  DetalhePragaState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasError => errorMessage != null;
  bool get hasComentarios => comentarios.isNotEmpty;
  bool get hasPragaData => pragaData != null;
  // MIGRATION TODO: Praga Drift model uses 'idPraga' not 'idReg'
  // String get itemId => pragaData?.idReg ?? pragaName;
  String get itemId => pragaData?.idPraga ?? pragaName;
}

/// Notifier para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
@Riverpod(keepAlive: true)
class DetalhePragaNotifier extends _$DetalhePragaNotifier {
  @override
  Future<DetalhePragaState> build() async {
    _setupPremiumStatusListener();
    return DetalhePragaState.initial();
  }

  /// Inicializa o provider com dados da praga
  Future<void> initialize(String pragaName, String pragaScientificName) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      state = AsyncValue.data(
        currentState.copyWith(
          pragaName: pragaName,
          pragaScientificName: pragaScientificName,
        ),
      );

      await _loadFavoritoState();
      _loadPremiumStatus();
      await _loadComentarios();
    } finally {
      final updatedState = state.value;
      if (updatedState != null) {
        state = AsyncValue.data(updatedState.copyWith(isLoading: false));
      }
    }
  }

  /// Versão assíncrona de initialize que aguarda dados estarem disponíveis
  Future<void> initializeAsync(
    String pragaName,
    String pragaScientificName,
  ) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      state = AsyncValue.data(
        currentState.copyWith(
          pragaName: pragaName,
          pragaScientificName: pragaScientificName,
        ),
      );

      await _loadFavoritoStateAsync();
      await _loadPragaSpecificInfo();
      _loadPremiumStatus();
      await _loadComentarios();
    } catch (e) {
      final updatedState = state.value;
      if (updatedState != null) {
        state = AsyncValue.data(
          updatedState.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao inicializar dados da praga: $e',
          ),
        );
      }
    }
  }

  /// Initialize usando ID da praga para melhor precisão
  Future<void> initializeById(String pragaId) async {
    // Aguardar o estado inicial ser carregado
    final currentState = state.requireValue;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final pragasRepository = ref.read(iPragasRepositoryProvider);
      final allPragasResult = await pragasRepository.getAll();
      PragaEntity? pragaData;

      allPragasResult.fold((failure) => pragaData = null, (allPragas) {
        final matchingPragas = allPragas.where(
          (PragaEntity p) => p.idReg == pragaId,
        );
        pragaData = matchingPragas.isNotEmpty ? matchingPragas.first : null;
      });

      if (pragaData != null) {
        // MIGRATION NOTE: Convert PragaEntity to Drift Praga model
        // Drift Praga uses: id, idPraga, nome, nomeLatino, tipo, imagemUrl, descricao
        // PragaEntity uses: idReg, nomeComum, nomeCientifico, tipoPraga, etc.
        final pragaDrift = Praga(
          id: 0, // Will be set by database
          idPraga: pragaData!.idReg, // Map idReg to idPraga
          nome: pragaData!.nomeComum, // Map nomeComum to nome
          nomeLatino:
              pragaData!.nomeCientifico, // Map nomeCientifico to nomeLatino
          tipo: pragaData!.tipoPraga, // Map tipoPraga to tipo
          // imagemUrl and descricao not available in PragaEntity
        );

        state = AsyncValue.data(
          currentState.copyWith(
            pragaName: pragaData!.nomeComum,
            pragaScientificName: pragaData!.nomeCientifico,
            pragaData: pragaDrift, // Use Drift model
          ),
        );

        await _loadFavoritoStateAsync();
        await _loadPragaSpecificInfo();
        _loadPremiumStatus();
        await _loadComentarios();
      } else {
        state = AsyncValue.data(
          currentState.copyWith(
            pragaName: '',
            pragaScientificName: '',
            pragaData: null,
          ),
        );
      }
    } finally {
      final updatedState = state.value;
      if (updatedState != null) {
        state = AsyncValue.data(updatedState.copyWith(isLoading: false));
      }
    }
  }

  /// Carrega estado de favorito da praga
  Future<void> _loadFavoritoState() async {
    final currentState = state.value;
    if (currentState == null) return;
    final pragasRepository = ref.read(iPragasRepositoryProvider);
    final allPragasResult = await pragasRepository.getAll();
    PragaEntity? pragaData;

    allPragasResult.fold(
      (failure) {
        pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where(
          (PragaEntity p) => p.nomeComum == currentState.pragaName,
        );
        pragaData = pragas.isNotEmpty ? pragas.first : null;
      },
    );

    final itemId = pragaData?.idReg ?? currentState.pragaName;

    try {
      final favoritosRepository =
          ref.read(favoritosRepositorySimplifiedProvider);
      final result = await favoritosRepository.isFavorito(
        'praga',
        itemId,
      );

      // Unwrap Either<Failure, bool>
      final isFavorited = result.fold(
        (failure) => false,
        (value) => value,
      );

      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
    } catch (e) {
      // On error, assume not favorited
      state = AsyncValue.data(currentState.copyWith(isFavorited: false));
    }
  }

  /// Versão assíncrona que aguarda dados estarem disponíveis
  Future<void> _loadFavoritoStateAsync() async {
    final currentState = state.value;
    if (currentState == null) return;

    final pragasRepository = ref.read(iPragasRepositoryProvider);
    final allPragasResult = await pragasRepository.getAll();
    PragaEntity? pragaData;

    allPragasResult.fold(
      (failure) {
        pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where(
          (PragaEntity p) => p.nomeComum == currentState.pragaName,
        );
        pragaData = pragas.isNotEmpty ? pragas.first : null;
      },
    );

    final itemId = pragaData?.idReg ?? currentState.pragaName;

    try {
      final favoritosRepository =
          ref.read(favoritosRepositorySimplifiedProvider);
      final result = await favoritosRepository.isFavorito(
        'praga',
        itemId,
      );

      // Unwrap Either<Failure, bool>
      final isFavorited = result.fold(
        (failure) => false,
        (value) => value,
      );

      state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
    } catch (e) {
      // On error, assume not favorited
      state = AsyncValue.data(currentState.copyWith(isFavorited: false));
    }
  }

  /// Carrega informações específicas baseado no tipo da praga
  /// MIGRATION TODO: Reimplement with Drift-based repository queries
  Future<void> _loadPragaSpecificInfo() async {
    // TEMPORARILY DISABLED: Legacy repositories removed during Drift migration
    // final currentState = state.value;
    // if (currentState == null || currentState.pragaData == null) return;
    //
    // try {
    //   PragasInfData? pragaInfo;
    //   PlantasInfData? plantaInfo;
    //   if (currentState.pragaData!.tipo == '1') {
    //     // Query PragasInf using Drift database
    //     // pragaInfo = await database.getPragasInfByIdReg(currentState.pragaData!.idPraga);
    //   } else if (currentState.pragaData!.tipo == '3') {
    //     // Query PlantasInf using Drift database
    //     // plantaInfo = await database.getPlantasInfByIdReg(currentState.pragaData!.idPraga);
    //   } else if (currentState.pragaData!.tipo == '2') {
    //     // Query PragasInf using Drift database
    //     // pragaInfo = await database.getPragasInfByIdReg(currentState.pragaData!.idPraga);
    //   }
    //
    //   state = AsyncValue.data(
    //     currentState.copyWith(pragaInfo: pragaInfo, plantaInfo: plantaInfo),
    //   );
    // } catch (e) {
    //   // Error handling
    // }

    // For now, just skip loading specific info
    return;
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    final currentState = state.value;
    if (currentState == null) return;

    final premiumState = ref.read(premiumNotifierProvider).value;
    state = AsyncValue.data(
      currentState.copyWith(isPremium: premiumState?.isPremium ?? false),
    );
  }

  /// Configura listener para mudanças automáticas no status premium
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

  /// Carrega comentários da praga
  Future<void> _loadComentarios() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingComments: true));

    try {
      final pkIdentificador = currentState.itemId;
      final comentariosService = ref.read(comentariosServiceProvider);
      final comentarios = await comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      state = AsyncValue.data(
        currentState
            .copyWith(isLoadingComments: false, comentarios: comentarios)
            .clearError(),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingComments: false,
          errorMessage: 'Erro ao carregar comentários: $e',
        ),
      );
    }
  }

  /// Adiciona um novo comentário
  Future<bool> addComentario(String content) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final comentariosService = ref.read(comentariosServiceProvider);
    if (!comentariosService.isValidContent(content)) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: comentariosService.getValidationErrorMessage(),
        ),
      );
      return false;
    }

    if (!comentariosService.canAddComentario(
      currentState.comentarios.length,
    )) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage:
              'Limite de comentários atingido. Assine o plano premium para mais.',
        ),
      );
      return false;
    }

    try {
      final newComment = ComentarioModel(
        id: comentariosService.generateId(),
        idReg: comentariosService.generateIdReg(),
        titulo: '',
        conteudo: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ferramenta: 'Pragas - ${currentState.pragaName}',
        pkIdentificador: currentState.pragaName.toLowerCase().replaceAll(
              ' ',
              '_',
            ),
        status: true,
      );

      await comentariosService.addComentario(newComment);

      final updatedComentarios = [newComment, ...currentState.comentarios];

      state = AsyncValue.data(
        currentState.copyWith(comentarios: updatedComentarios).clearError(),
      );
      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao adicionar comentário: $e'),
      );
      return false;
    }
  }

  /// Remove um comentário
  Future<bool> deleteComentario(String commentId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      final comentariosService = ref.read(comentariosServiceProvider);
      await comentariosService.deleteComentario(commentId);

      final updatedComentarios =
          currentState.comentarios.where((c) => c.id != commentId).toList();

      state = AsyncValue.data(
        currentState.copyWith(comentarios: updatedComentarios).clearError(),
      );
      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Erro ao excluir comentário: $e'),
      );
      return false;
    }
  }

  /// Alterna estado de favorito
  Future<bool> toggleFavorito() async {
    final currentState = state.value;
    if (currentState == null) return false;

    final wasAlreadyFavorited = currentState.isFavorited;
    final itemId = currentState.itemId;
    state = AsyncValue.data(
      currentState.copyWith(isFavorited: !wasAlreadyFavorited),
    );

    try {
      final favoritosRepository =
          ref.read(favoritosRepositorySimplifiedProvider);
      final result = await favoritosRepository.toggleFavorito(
        'praga',
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
          if (!success) {
            state = AsyncValue.data(
              currentState.copyWith(
                isFavorited: wasAlreadyFavorited,
                errorMessage:
                    'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
              ),
            );
            return false;
          }

          state = AsyncValue.data(
            currentState
                .copyWith(isFavorited: !wasAlreadyFavorited)
                .clearError(),
          );
          return true;
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

  /// Limpa mensagem de erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Recarrega comentários
  Future<void> reloadComentarios() async {
    await _loadComentarios();
  }

  /// Navega para tela premium
  void navigateToPremium() {
    // Navigation handled by widget layer
  }
}
