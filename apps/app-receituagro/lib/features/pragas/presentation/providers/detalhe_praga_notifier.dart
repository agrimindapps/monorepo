import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/premium_notifier.dart';
import '../../../../database/providers/database_providers.dart' as db;
import '../../../../database/receituagro_database.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../../comentarios/presentation/providers/comentarios_providers.dart';
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

  /// Getter para tipoPraga (mapeia de Drift 'tipo' para 'tipoPraga')
  /// Drift model usa 'tipo', mas a UI espera 'tipoPraga'
  String? get tipoPraga => pragaData?.tipo;
}

/// Notifier para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
@riverpod
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
      // Buscar praga no banco Drift pelo nome para obter o ID correto
      final pragasRepository = ref.read(db.pragasRepositoryProvider);
      final pragaDriftList = await pragasRepository.findByNome(pragaName);

      debugPrint('🔍 [DETALHE_PRAGA] initializeAsync: pragaName=$pragaName');
      debugPrint(
          '🔍 [DETALHE_PRAGA] pragaDrift encontrado: ${pragaDriftList.isNotEmpty}');

      final praga = pragaDriftList.isNotEmpty ? pragaDriftList.first : null;

      if (praga != null) {
        debugPrint(
            '🔍 [DETALHE_PRAGA] praga.id=${praga.id}, idPraga=${praga.idPraga}');
      }

      state = AsyncValue.data(
        currentState.copyWith(
          pragaName: pragaName,
          pragaScientificName: pragaScientificName,
          pragaData: praga, // Usa o model Drift com ID correto do banco
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
    // Usar o estado atual ou criar um inicial se ainda não estiver pronto
    var currentState = state.value ?? DetalhePragaState.initial();

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      // Buscar diretamente no repositório Drift para obter o ID correto
      final pragasRepository = ref.read(db.pragasRepositoryProvider);
      final pragaDrift = await pragasRepository.findByIdPraga(pragaId);

      debugPrint('🔍 [DETALHE_PRAGA] initializeById: pragaId=$pragaId');
      debugPrint(
          '🔍 [DETALHE_PRAGA] pragaDrift encontrado: ${pragaDrift != null}');
      if (pragaDrift != null) {
        debugPrint(
            '🔍 [DETALHE_PRAGA] pragaDrift.id=${pragaDrift.id}, idPraga=${pragaDrift.idPraga}, nome=${pragaDrift.nome}');
      }

      if (pragaDrift != null) {
        // Atualizar currentState para manter consistência
        currentState = currentState.copyWith(
          pragaName: pragaDrift.nome,
          pragaScientificName: pragaDrift.nomeLatino ?? '',
          pragaData: pragaDrift,
        );
        state = AsyncValue.data(currentState);

        await _loadFavoritoStateAsync();
        await _loadPragaSpecificInfo();
        _loadPremiumStatus();
        await _loadComentarios();
      } else {
        // Fallback: tentar buscar via iPragasRepositoryProvider
        debugPrint(
            '⚠️ [DETALHE_PRAGA] Praga não encontrada no Drift, tentando via Entity...');
        final entityRepository = ref.read(iPragasRepositoryProvider);
        final allPragasResult = await entityRepository.getAll();
        PragaEntity? pragaEntity;

        allPragasResult.fold((failure) => pragaEntity = null, (allPragas) {
          final matchingPragas = allPragas.where(
            (PragaEntity p) => p.idReg == pragaId,
          );
          pragaEntity = matchingPragas.isNotEmpty ? matchingPragas.first : null;
        });

        if (pragaEntity != null) {
          // Criar Drift model mas sem o ID real (fallback)
          final pragaDriftFallback = Praga(
            id: 0,
            idPraga: pragaEntity!.idReg,
            nome: pragaEntity!.nomeComum,
            nomeLatino: pragaEntity!.nomeCientifico,
            tipo: pragaEntity!.tipoPraga,
          );

          // Atualizar currentState para manter consistência
          currentState = currentState.copyWith(
            pragaName: pragaEntity!.nomeComum,
            pragaScientificName: pragaEntity!.nomeCientifico,
            pragaData: pragaDriftFallback,
          );
          state = AsyncValue.data(currentState);

          await _loadFavoritoStateAsync();
          await _loadPragaSpecificInfo();
          _loadPremiumStatus();
          await _loadComentarios();
        } else {
          currentState = currentState.copyWith(
            pragaName: '',
            pragaScientificName: '',
            pragaData: null,
          );
          state = AsyncValue.data(currentState);
        }
      }
    } finally {
      // Usar o estado mais recente para finalizar
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
    final currentState = state.value;
    if (currentState == null || currentState.pragaData == null) {
      debugPrint(
          '🐛 [DETALHE_PRAGA] _loadPragaSpecificInfo: state ou pragaData é null');
      return;
    }

    try {
      PragasInfData? pragaInfo;
      PlantasInfData? plantaInfo;

      final pragaIdPraga = currentState.pragaData!.idPraga;
      final pragaId = currentState.pragaData!.id; // ID int da praga
      final pragaTipo = currentState.pragaData!.tipo;

      debugPrint(
          '🐛 [DETALHE_PRAGA] _loadPragaSpecificInfo: id=$pragaId, idPraga=$pragaIdPraga, tipo=$pragaTipo');

      if (pragaTipo == '1' || pragaTipo == '2') {
        // Tipo 1 = Inseto, Tipo 2 = Doença -> usa PragasInf
        final pragasInfRepo = ref.read(db.pragasInfRepositoryProvider);

        // Primeiro tenta por pragaId (int) que é a FK correta
        debugPrint(
            '🐛 [DETALHE_PRAGA] Buscando PragasInf por pragaId (int): $pragaId');
        pragaInfo = await pragasInfRepo.findByPragaId(pragaId);

        // Fallback: tenta por idReg (string)
        if (pragaInfo == null) {
          debugPrint(
              '🐛 [DETALHE_PRAGA] Fallback: Buscando PragasInf por idReg: $pragaIdPraga');
          pragaInfo = await pragasInfRepo.findByIdReg(pragaIdPraga);
        }

        debugPrint(
            '🐛 [DETALHE_PRAGA] PragasInf encontrado: ${pragaInfo != null}');
        if (pragaInfo != null) {
          final sintomasPreview = pragaInfo.sintomas?.isNotEmpty == true
              ? pragaInfo.sintomas!.substring(
                  0,
                  pragaInfo.sintomas!.length > 50
                      ? 50
                      : pragaInfo.sintomas!.length)
              : 'null';
          debugPrint(
              '🐛 [DETALHE_PRAGA] PragasInf.sintomas: $sintomasPreview...');
        }
      } else if (pragaTipo == '3') {
        // Tipo 3 = Planta Daninha -> usa PlantasInf
        final plantasInfRepo = ref.read(db.plantasInfRepositoryProvider);

        // PlantasInf.culturaId é na verdade a FK para Pragas (nome confuso na tabela)
        // O campo culturaId aponta para Pragas.id, não Culturas.id
        debugPrint(
            '🐛 [DETALHE_PRAGA] Buscando PlantasInf por pragaId (via culturaId): $pragaId');
        plantaInfo = await plantasInfRepo.findByCulturaId(pragaId);

        // Fallback: tenta por idReg (string)
        if (plantaInfo == null) {
          debugPrint(
              '🐛 [DETALHE_PRAGA] Fallback: Buscando PlantasInf por idReg: $pragaIdPraga');
          plantaInfo = await plantasInfRepo.findByIdReg(pragaIdPraga);
        }

        debugPrint(
            '🐛 [DETALHE_PRAGA] PlantasInf encontrado: ${plantaInfo != null}');
        if (plantaInfo != null) {
          debugPrint(
              '🐛 [DETALHE_PRAGA] PlantasInf.ciclo: ${plantaInfo.ciclo}');
        }
      } else {
        debugPrint(
            '🐛 [DETALHE_PRAGA] Tipo de praga não reconhecido: $pragaTipo');
      }

      state = AsyncValue.data(
        currentState.copyWith(pragaInfo: pragaInfo, plantaInfo: plantaInfo),
      );
    } catch (e, stack) {
      // Silently handle error - info is optional
      debugPrint('🐛 [DETALHE_PRAGA] Erro ao carregar info específica: $e');
      debugPrint('🐛 [DETALHE_PRAGA] Stack: $stack');
    }
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    final currentState = state.value;
    if (currentState == null) return;

    final premiumState = ref.read(premiumProvider).value;
    state = AsyncValue.data(
      currentState.copyWith(isPremium: premiumState?.isPremium ?? false),
    );
  }

  /// Configura listener para mudanças automáticas no status premium
  void _setupPremiumStatusListener() {
    ref.listen(premiumProvider, (previous, next) {
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
    if (currentState == null) {
      debugPrint('🐛 [TOGGLE_FAVORITO] Estado atual é null');
      return false;
    }

    final wasAlreadyFavorited = currentState.isFavorited;
    final itemId = currentState.itemId;

    debugPrint(
        '🐛 [TOGGLE_FAVORITO] Iniciando toggle: itemId=$itemId, wasAlreadyFavorited=$wasAlreadyFavorited');

    state = AsyncValue.data(
      currentState.copyWith(isFavorited: !wasAlreadyFavorited),
    );

    try {
      final favoritosRepository =
          ref.read(favoritosRepositorySimplifiedProvider);

      debugPrint(
          '🐛 [TOGGLE_FAVORITO] Chamando toggleFavorito no repositório...');

      final result = await favoritosRepository.toggleFavorito(
        'praga',
        itemId,
      );

      debugPrint('🐛 [TOGGLE_FAVORITO] Resultado do repositório: $result');

      // Unwrap Either<Failure, bool>
      return result.fold(
        (failure) {
          debugPrint('🐛 [TOGGLE_FAVORITO] ❌ Failure: ${failure.message}');
          // On failure, revert state
          state = AsyncValue.data(
            currentState.copyWith(
              isFavorited: wasAlreadyFavorited,
              errorMessage:
                  'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito: ${failure.message}',
            ),
          );
          return false;
        },
        (success) {
          debugPrint('🐛 [TOGGLE_FAVORITO] Sucesso: $success');
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
    } catch (e, stack) {
      // On exception, revert state
      debugPrint('🐛 [TOGGLE_FAVORITO] ❌ Exception: $e');
      debugPrint('🐛 [TOGGLE_FAVORITO] Stack: $stack');
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
