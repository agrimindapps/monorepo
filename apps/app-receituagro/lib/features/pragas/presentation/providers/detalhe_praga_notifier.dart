import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/plantas_inf_hive.dart';
import '../../../../core/data/models/pragas_hive.dart';
import '../../../../core/data/models/pragas_inf_hive.dart';
import '../../../../core/data/repositories/plantas_inf_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/data/repositories/pragas_inf_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/services/premium_status_notifier.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../../comentarios/domain/comentarios_service.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';

part 'detalhe_praga_notifier.g.dart';

/// Detalhe Praga state
class DetalhePragaState {
  final String pragaName;
  final String pragaScientificName;
  final PragasHive? pragaData;
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isLoadingComments;
  final String? errorMessage;
  final List<ComentarioModel> comentarios;
  final Map<String, dynamic>? defensivoData;
  final PragasInfHive? pragaInfo;
  final PlantasInfHive? plantaInfo;

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
    PragasHive? pragaData,
    bool? isFavorited,
    bool? isPremium,
    bool? isLoading,
    bool? isLoadingComments,
    String? errorMessage,
    List<ComentarioModel>? comentarios,
    Map<String, dynamic>? defensivoData,
    PragasInfHive? pragaInfo,
    PlantasInfHive? plantaInfo,
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
  String get itemId => pragaData?.idReg ?? pragaName;
}

/// Notifier para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
@riverpod
class DetalhePragaNotifier extends _$DetalhePragaNotifier {
  late final FavoritosRepositorySimplified _favoritosRepository;
  late final PragasHiveRepository _pragasRepository;
  late final PragasInfHiveRepository _pragasInfRepository;
  late final PlantasInfHiveRepository _plantasInfRepository;
  late final IPremiumService _premiumService;
  late final ComentariosService _comentariosService;

  StreamSubscription<bool>? _premiumStatusSubscription;

  @override
  Future<DetalhePragaState> build() async {
    _favoritosRepository = FavoritosDI.get<FavoritosRepositorySimplified>();
    _pragasRepository = di.sl<PragasHiveRepository>();
    _pragasInfRepository = di.sl<PragasInfHiveRepository>();
    _plantasInfRepository = di.sl<PlantasInfHiveRepository>();
    _premiumService = di.sl<IPremiumService>();
    _comentariosService = di.sl<ComentariosService>();
    _setupPremiumStatusListener();
    ref.onDispose(() {
      _premiumStatusSubscription?.cancel();
    });

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
  Future<void> initializeAsync(String pragaName, String pragaScientificName) async {
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
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final allPragasResult = await _pragasRepository.getAll();
      PragasHive? pragaData;

      allPragasResult.fold(
        (failure) {
          pragaData = null;
        },
        (allPragas) {
          final matchingPragas = allPragas.where(
            (PragasHive p) => p.idReg == pragaId || p.objectId == pragaId,
          );
          pragaData = matchingPragas.isNotEmpty ? matchingPragas.first : null;
        },
      );

      if (pragaData != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            pragaName: pragaData!.nomeComum,
            pragaScientificName: pragaData!.nomeCientifico,
            pragaData: pragaData,
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
    final allPragasResult = await _pragasRepository.getAll();
    PragasHive? pragaData;

    allPragasResult.fold(
      (failure) {
        pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where((PragasHive p) => p.nomeComum == currentState.pragaName);
        pragaData = pragas.isNotEmpty ? pragas.first : null;
      },
    );

    final itemId = pragaData?.idReg ?? currentState.pragaName;

    try {
      final isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
      state = AsyncValue.data(
        currentState.copyWith(
          pragaData: pragaData,
          isFavorited: isFavorited,
        ),
      );
    } catch (e) {
      final isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
      state = AsyncValue.data(
        currentState.copyWith(
          pragaData: pragaData,
          isFavorited: isFavorited,
        ),
      );
    }
  }

  /// Versão assíncrona que aguarda dados estarem disponíveis
  Future<void> _loadFavoritoStateAsync() async {
    final currentState = state.value;
    if (currentState == null) return;

    final allPragasResult = await _pragasRepository.getAll();
    PragasHive? pragaData;

    allPragasResult.fold(
      (failure) {
        pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where((PragasHive p) => p.nomeComum == currentState.pragaName);
        pragaData = pragas.isNotEmpty ? pragas.first : null;
      },
    );

    final itemId = pragaData?.idReg ?? currentState.pragaName;

    try {
      final isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
      state = AsyncValue.data(
        currentState.copyWith(
          pragaData: pragaData,
          isFavorited: isFavorited,
        ),
      );
    } catch (e) {
      final isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
      state = AsyncValue.data(
        currentState.copyWith(
          pragaData: pragaData,
          isFavorited: isFavorited,
        ),
      );
    }
  }

  /// Carrega informações específicas baseado no tipo da praga
  Future<void> _loadPragaSpecificInfo() async {
    final currentState = state.value;
    if (currentState == null || currentState.pragaData == null) return;

    try {
      PragasInfHive? pragaInfo;
      PlantasInfHive? plantaInfo;
      if (currentState.pragaData!.tipoPraga == '1') {
        pragaInfo = await _pragasInfRepository.findByIdReg(currentState.pragaData!.idReg);
      }
      else if (currentState.pragaData!.tipoPraga == '3') {
        plantaInfo = await _plantasInfRepository.findByIdReg(currentState.pragaData!.idReg);
      }
      else if (currentState.pragaData!.tipoPraga == '2') {
        pragaInfo = await _pragasInfRepository.findByIdReg(currentState.pragaData!.idReg);
      }

      state = AsyncValue.data(
        currentState.copyWith(
          pragaInfo: pragaInfo,
          plantaInfo: plantaInfo,
        ),
      );
    } catch (e) {
    }
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isPremium: _premiumService.isPremium),
    );
  }

  /// Configura listener para mudanças automáticas no status premium
  void _setupPremiumStatusListener() {
    _premiumStatusSubscription?.cancel();
    _premiumStatusSubscription = PremiumStatusNotifier.instance.premiumStatusStream.listen(
      (isPremiumStatus) {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(isPremium: isPremiumStatus));
        }
      },
    );
  }

  /// Carrega comentários da praga
  Future<void> _loadComentarios() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingComments: true));

    try {
      final pkIdentificador = currentState.itemId;
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingComments: false,
          comentarios: comentarios,
        ).clearError(),
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

    if (!_comentariosService.isValidContent(content)) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: _comentariosService.getValidationErrorMessage()),
      );
      return false;
    }

    if (!_comentariosService.canAddComentario(currentState.comentarios.length)) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Limite de comentários atingido. Assine o plano premium para mais.',
        ),
      );
      return false;
    }

    try {
      final newComment = ComentarioModel(
        id: _comentariosService.generateId(),
        idReg: _comentariosService.generateIdReg(),
        titulo: '',
        conteudo: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ferramenta: 'Pragas - ${currentState.pragaName}',
        pkIdentificador: currentState.pragaName.toLowerCase().replaceAll(' ', '_'),
        status: true,
      );

      await _comentariosService.addComentario(newComment);

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
      await _comentariosService.deleteComentario(commentId);

      final updatedComentarios = currentState.comentarios.where((c) => c.id != commentId).toList();

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
    state = AsyncValue.data(currentState.copyWith(isFavorited: !wasAlreadyFavorited));

    try {
      final success = await _favoritosRepository.toggleFavorito('praga', itemId);

      if (!success) {
        state = AsyncValue.data(
          currentState.copyWith(
            isFavorited: wasAlreadyFavorited,
            errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
          ),
        );
        return false;
      }

      state = AsyncValue.data(currentState.copyWith(isFavorited: !wasAlreadyFavorited).clearError());
      return true;
    } catch (e) {
      try {
        final success = wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('praga', itemId)
            : await _favoritosRepository.addFavorito('praga', itemId);

        if (!success) {
          state = AsyncValue.data(
            currentState.copyWith(
              isFavorited: wasAlreadyFavorited,
              errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
            ),
          );
          return false;
        }

        state = AsyncValue.data(currentState.copyWith(isFavorited: !wasAlreadyFavorited).clearError());
        return true;
      } catch (fallbackError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isFavorited: wasAlreadyFavorited,
            errorMessage: 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
          ),
        );
        return false;
      }
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
    _premiumService.navigateToPremium();
  }
}
