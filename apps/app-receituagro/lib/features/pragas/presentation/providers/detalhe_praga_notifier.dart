import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart' as db;
import '../../../../database/receituagro_database.dart';
import '../../../comentarios/data/comentario_model.dart';
import '../../../comentarios/presentation/providers/comentarios_providers.dart';
import '../../../subscription/presentation/providers/subscription_notifier.dart';
import 'pragas_providers.dart';

part 'detalhe_praga_notifier.g.dart';

/// Estado da página de detalhes da praga
///
/// Contém todos os dados necessários para renderizar a página:
/// - Dados básicos da praga (nome, nome científico, tipo)
/// - Informações específicas (sintomas, controle, etc.)
/// - Estado de favorito e premium
/// - Comentários do usuário
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
  final PragasInfData? pragaInfo;
  final PlantasInfData? plantaInfo;

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
    PragasInfData? pragaInfo,
    PlantasInfData? plantaInfo,
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

  /// ID único da praga para favoritos e comentários
  String get itemId => pragaData?.idPraga ?? pragaName;

  /// Tipo da praga: '1' = Inseto, '2' = Doença, '3' = Planta Daninha
  String? get tipoPraga => pragaData?.tipo;
}

/// Notifier para gerenciar estado da página de detalhes da praga
///
/// Responsabilidade: coordenar carregamento de dados da praga, favoritos,
/// informações específicas (sintomas/controle), premium e comentários.
@riverpod
class DetalhePragaNotifier extends _$DetalhePragaNotifier {
  @override
  Future<DetalhePragaState> build() async {
    _setupPremiumStatusListener();
    return DetalhePragaState.initial();
  }

  /// Inicializa o provider usando ID da praga (método principal)
  ///
  /// Este é o método preferido pois usa o ID único para busca precisa.
  /// Se pragaId for null/vazio, tenta buscar por nome.
  Future<void> initialize({
    String? pragaId,
    String? pragaName,
    String? pragaScientificName,
  }) async {
    var currentState = state.value ?? DetalhePragaState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final pragasRepository = ref.read(db.pragasRepositoryProvider);
      Praga? pragaDrift;

      // Estratégia 1: Buscar por ID (preferido)
      if (pragaId != null && pragaId.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('🔍 [DETALHE_PRAGA] Buscando por pragaId: $pragaId');
        }
        pragaDrift = await pragasRepository.findByIdPraga(pragaId);
      }

      // Estratégia 2: Fallback por nome
      if (pragaDrift == null && pragaName != null && pragaName.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '🔍 [DETALHE_PRAGA] Fallback: buscando por nome: $pragaName',
          );
        }
        final pragaDriftList = await pragasRepository.findByNome(pragaName);
        pragaDrift = pragaDriftList.isNotEmpty ? pragaDriftList.first : null;
      }

      if (pragaDrift != null) {
        if (kDebugMode) {
          debugPrint(
            '✅ [DETALHE_PRAGA] Praga encontrada: idPraga=${pragaDrift.idPraga}',
          );
        }

        currentState = currentState.copyWith(
          pragaName: pragaDrift.nome,
          pragaScientificName:
              pragaDrift.nomeLatino ?? pragaScientificName ?? '',
          pragaData: pragaDrift,
        );
        state = AsyncValue.data(currentState);

        // Carrega dados auxiliares em paralelo para melhor performance
        await Future.wait([
          _loadFavoritoState(),
          _loadPragaSpecificInfo(),
          _loadComentarios(),
        ]);

        _loadPremiumStatus();
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ [DETALHE_PRAGA] Praga não encontrada');
        }
        currentState = currentState.copyWith(
          pragaName: pragaName ?? '',
          pragaScientificName: pragaScientificName ?? '',
          pragaData: null,
          errorMessage: 'Praga não encontrada',
        );
        state = AsyncValue.data(currentState);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DETALHE_PRAGA] Erro ao inicializar: $e');
      }
      final updatedState = state.value ?? currentState;
      state = AsyncValue.data(
        updatedState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar dados da praga: $e',
        ),
      );
      return;
    }

    // Finaliza loading
    final updatedState = state.value;
    if (updatedState != null) {
      state = AsyncValue.data(updatedState.copyWith(isLoading: false));
    }
  }

  /// Carrega estado de favorito da praga
  Future<void> _loadFavoritoState() async {
    final currentState = state.value;
    if (currentState == null) return;

    final itemId = currentState.itemId;
    if (itemId.isEmpty) return;

    try {
      final favoritosRepository = ref.read(
        favoritosRepositorySimplifiedProvider,
      );
      final result = await favoritosRepository.isFavorito('praga', itemId);

      final isFavorited = result.fold((failure) => false, (value) => value);

      // Atualiza estado apenas se ainda válido
      final freshState = state.value;
      if (freshState != null) {
        state = AsyncValue.data(freshState.copyWith(isFavorited: isFavorited));
      }
    } catch (e) {
      // Erro silencioso - favorito é opcional
      if (kDebugMode) {
        debugPrint('⚠️ [DETALHE_PRAGA] Erro ao carregar favorito: $e');
      }
    }
  }

  /// Carrega informações específicas baseado no tipo da praga (sintomas, controle, etc.)
  Future<void> _loadPragaSpecificInfo() async {
    final currentState = state.value;
    if (currentState == null || currentState.pragaData == null) {
      return;
    }

    try {
      PragasInfData? pragaInfo;
      PlantasInfData? plantaInfo;

      final pragaIdPraga = currentState.pragaData!.idPraga;
      final pragaTipo = currentState.pragaData!.tipo;

      if (kDebugMode) {
        debugPrint(
          '🔍 [DETALHE_PRAGA] _loadPragaSpecificInfo: tipo=$pragaTipo',
        );
      }

      if (pragaTipo == '1' || pragaTipo == '2') {
        // Tipo 1 = Inseto, Tipo 2 = Doença -> usa PragasInf
        final pragasInfRepo = ref.read(db.pragasInfRepositoryProvider);
        pragaInfo = await pragasInfRepo.findByPragaId(pragaIdPraga);
        pragaInfo ??= await pragasInfRepo.findByIdReg(pragaIdPraga);
      } else if (pragaTipo == '3') {
        // Tipo 3 = Planta Daninha -> usa PlantasInf (refs pragas!)
        final plantasInfRepo = ref.read(db.plantasInfRepositoryProvider);
        plantaInfo = await plantasInfRepo.findByPragaId(pragaIdPraga);
        plantaInfo ??= await plantasInfRepo.findByIdReg(pragaIdPraga);
      }

      // Atualiza estado apenas se ainda válido
      final freshState = state.value;
      if (freshState != null) {
        state = AsyncValue.data(
          freshState.copyWith(pragaInfo: pragaInfo, plantaInfo: plantaInfo),
        );
      }
    } catch (e) {
      // Erro silencioso - info é opcional
      if (kDebugMode) {
        debugPrint('⚠️ [DETALHE_PRAGA] Erro ao carregar info específica: $e');
      }
    }
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    final currentState = state.value;
    if (currentState == null) return;

    // ✅ Usa subscriptionManagementProvider para verificação correta na web
    final subscriptionState = ref.read(subscriptionManagementProvider).value;
    state = AsyncValue.data(
      currentState.copyWith(
        isPremium: subscriptionState?.hasActiveSubscription ?? false,
      ),
    );
  }

  /// Configura listener para mudanças automáticas no status premium
  void _setupPremiumStatusListener() {
    // ✅ Usa subscriptionManagementProvider para verificação correta na web
    ref.listen(subscriptionManagementProvider, (previous, next) {
      final currentState = state.value;
      if (currentState != null) {
        next.whenData((subscriptionState) {
          state = AsyncValue.data(
            currentState.copyWith(
              isPremium: subscriptionState.hasActiveSubscription,
            ),
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

    if (!comentariosService.canAddComentario(currentState.comentarios.length)) {
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

      final updatedComentarios = currentState.comentarios
          .where((c) => c.id != commentId)
          .toList();

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

  /// Alterna estado de favorito (otimistic update)
  Future<bool> toggleFavorito() async {
    final currentState = state.value;
    if (currentState == null) return false;

    final wasAlreadyFavorited = currentState.isFavorited;
    final itemId = currentState.itemId;

    // Optimistic update
    state = AsyncValue.data(
      currentState.copyWith(isFavorited: !wasAlreadyFavorited),
    );

    try {
      final favoritosRepository = ref.read(
        favoritosRepositorySimplifiedProvider,
      );
      final result = await favoritosRepository.toggleFavorito('praga', itemId);

      return result.fold(
        (failure) {
          // Revert on failure
          state = AsyncValue.data(
            currentState.copyWith(
              isFavorited: wasAlreadyFavorited,
              errorMessage: 'Erro ao alterar favorito: ${failure.message}',
            ),
          );
          return false;
        },
        (success) {
          if (!success) {
            state = AsyncValue.data(
              currentState.copyWith(
                isFavorited: wasAlreadyFavorited,
                errorMessage: 'Erro ao alterar favorito',
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
      // Revert on exception
      state = AsyncValue.data(
        currentState.copyWith(
          isFavorited: wasAlreadyFavorited,
          errorMessage: 'Erro ao alterar favorito: $e',
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
