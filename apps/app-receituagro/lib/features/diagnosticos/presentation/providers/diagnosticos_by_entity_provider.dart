import 'package:core/core.dart' show Either, Failure;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import 'diagnosticos_providers.dart';

part 'diagnosticos_by_entity_provider.g.dart';

/// Tipo de entidade para busca de diagnósticos
enum DiagnosticoEntityType {
  praga,
  defensivo,
  cultura,
}

/// Parâmetros para o provider de diagnósticos por entidade
class DiagnosticosByEntityParams {
  final DiagnosticoEntityType entityType;
  final String entityId;
  final String? entityName;

  const DiagnosticosByEntityParams({
    required this.entityType,
    required this.entityId,
    this.entityName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticosByEntityParams &&
          entityType == other.entityType &&
          entityId == other.entityId;

  @override
  int get hashCode => Object.hash(entityType, entityId);
}

/// Item de diagnóstico enriquecido com nomes resolvidos
class DiagnosticoDisplayItem {
  final DiagnosticoEntity entity;
  final String nomeDefensivo;
  final String nomeCultura;
  final String nomePraga;
  final String ingredienteAtivo;

  const DiagnosticoDisplayItem({
    required this.entity,
    required this.nomeDefensivo,
    required this.nomeCultura,
    required this.nomePraga,
    this.ingredienteAtivo = 'Não especificado',
  });

  String get id => entity.id;
  String get dosagem => entity.dosagem.displayDosagem;
  String get aplicacaoTerrestre => entity.aplicacao.terrestre?.displayVolume ?? '';
  String get aplicacaoAerea => entity.aplicacao.aerea?.displayVolume ?? '';
  String get intervaloSeguranca => entity.aplicacao.intervaloReaplicacao ?? '';
}

/// Estado dos diagnósticos por entidade
class DiagnosticosByEntityState {
  final List<DiagnosticoDisplayItem> items;
  final String searchQuery;
  final String selectedCultura;
  final List<String> culturas;
  final bool isLoading;
  final String? errorMessage;

  const DiagnosticosByEntityState({
    required this.items,
    required this.searchQuery,
    required this.selectedCultura,
    required this.culturas,
    required this.isLoading,
    this.errorMessage,
  });

  factory DiagnosticosByEntityState.initial() {
    return const DiagnosticosByEntityState(
      items: [],
      searchQuery: '',
      selectedCultura: 'Todas',
      culturas: ['Todas'],
      isLoading: false,
      errorMessage: null,
    );
  }

  DiagnosticosByEntityState copyWith({
    List<DiagnosticoDisplayItem>? items,
    String? searchQuery,
    String? selectedCultura,
    List<String>? culturas,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiagnosticosByEntityState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCultura: selectedCultura ?? this.selectedCultura,
      culturas: culturas ?? this.culturas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get hasData => items.isNotEmpty;
  bool get hasError => errorMessage != null;

  /// Itens filtrados por pesquisa e cultura
  List<DiagnosticoDisplayItem> get filteredItems {
    return items.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.nomeDefensivo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.nomePraga.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.ingredienteAtivo.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCulture = selectedCultura == 'Todas' || 
          item.nomeCultura == selectedCultura;

      return matchesSearch && matchesCulture;
    }).toList();
  }

  /// Itens agrupados por cultura
  Map<String, List<DiagnosticoDisplayItem>> get groupedItems {
    final grouped = <String, List<DiagnosticoDisplayItem>>{};
    for (final item in filteredItems) {
      grouped.putIfAbsent(item.nomeCultura, () => []).add(item);
    }
    return grouped;
  }
}

/// Provider de diagnósticos por entidade (Family)
/// 
/// Uso:
/// ```dart
/// // Para pragas
/// ref.watch(diagnosticosByEntityProvider(
///   DiagnosticosByEntityParams(entityType: DiagnosticoEntityType.praga, entityId: 'abc123')
/// ));
/// 
/// // Para defensivos
/// ref.watch(diagnosticosByEntityProvider(
///   DiagnosticosByEntityParams(entityType: DiagnosticoEntityType.defensivo, entityId: 'def456')
/// ));
/// ```
@Riverpod(keepAlive: true)
class DiagnosticosByEntity extends _$DiagnosticosByEntity {
  @override
  Future<DiagnosticosByEntityState> build(DiagnosticosByEntityParams params) async {
    // Carrega automaticamente ao criar
    final initialState = DiagnosticosByEntityState.initial();
    
    // Agenda carregamento após build (ignorar resultado do Future)
    // ignore: unawaited_futures
    Future.microtask(() => loadDiagnosticos());
    
    return initialState;
  }

  /// Verifica se o notifier ainda está ativo
  bool _isMounted() {
    try {
      // ignore: unnecessary_statements
      state;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Carrega diagnósticos para a entidade especificada
  Future<void> loadDiagnosticos() async {
    if (!_isMounted()) return;

    // Aguarda o estado inicial se ainda não estiver disponível
    DiagnosticosByEntityState currentState;
    if (state.value != null) {
      currentState = state.value!;
    } else {
      try {
        currentState = await future;
      } catch (e) {
        currentState = DiagnosticosByEntityState.initial();
      }
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true, errorMessage: null));

    try {
      final repository = ref.read(iDiagnosticosRepositoryProvider);
      final params = this.params;
      
      // Busca diagnósticos baseado no tipo de entidade
      final result = await _fetchByEntityType(repository, params);

      if (!_isMounted()) return;

      await result.fold(
        (failure) async {
          if (!_isMounted()) return;
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao carregar: ${failure.message}',
              items: [],
            ),
          );
        },
        (entities) async {
          if (!_isMounted()) return;
          
          // Enriquece entidades com nomes resolvidos
          final displayItems = await _enrichEntities(entities, params);
          
          if (!_isMounted()) return;

          // Extrai culturas únicas
          final culturasUnicas = displayItems
              .map((item) => item.nomeCultura)
              .where((c) => c.isNotEmpty && c != 'Não especificado')
              .toSet()
              .toList()
            ..sort();

          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              items: displayItems,
              culturas: ['Todas', ...culturasUnicas],
              errorMessage: null,
            ),
          );
        },
      );
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      
      state = AsyncValue.data(
        (state.value ?? DiagnosticosByEntityState.initial()).copyWith(
          isLoading: false,
          errorMessage: 'Erro inesperado: $e',
          items: [],
        ),
      );
    }
  }

  /// Busca diagnósticos baseado no tipo de entidade
  Future<Either<Failure, List<DiagnosticoEntity>>> _fetchByEntityType(
    IDiagnosticosRepository repository,
    DiagnosticosByEntityParams params,
  ) async {
    switch (params.entityType) {
      case DiagnosticoEntityType.praga:
        return repository.queryByPraga(params.entityId);
      case DiagnosticoEntityType.defensivo:
        return repository.queryByDefensivo(params.entityId);
      case DiagnosticoEntityType.cultura:
        return repository.queryByCultura(params.entityId);
    }
  }

  /// Enriquece entidades com nomes resolvidos
  Future<List<DiagnosticoDisplayItem>> _enrichEntities(
    List<DiagnosticoEntity> entities,
    DiagnosticosByEntityParams params,
  ) async {
    final items = <DiagnosticoDisplayItem>[];

    for (final entity in entities) {
      if (!_isMounted()) break;

      // Resolve nomes das entidades relacionadas
      final nomeCultura = await _resolveCulturaNome(entity.idCultura);
      
      // nomePraga: só usa entityName se o entityType for praga
      // Para defensivo/cultura, sempre resolve pelo idPraga
      final nomePraga = params.entityType == DiagnosticoEntityType.praga
          ? (params.entityName ?? await _resolvePragaNome(entity.idPraga))
          : await _resolvePragaNome(entity.idPraga);
      
      // nomeDefensivo: só usa entityName se o entityType for defensivo
      // Para praga/cultura, sempre resolve pelo idDefensivo
      final (nomeDefensivoResolvido, ingredienteAtivo) = await _resolveDefensivoData(entity.idDefensivo);
      final nomeDefensivo = params.entityType == DiagnosticoEntityType.defensivo
          ? (params.entityName ?? nomeDefensivoResolvido)
          : nomeDefensivoResolvido;

      items.add(DiagnosticoDisplayItem(
        entity: entity,
        nomeDefensivo: nomeDefensivo.isNotEmpty ? nomeDefensivo : 'Defensivo não especificado',
        nomeCultura: nomeCultura.isNotEmpty ? nomeCultura : 'Não especificado',
        nomePraga: nomePraga.isNotEmpty ? nomePraga : 'Praga não identificada',
        ingredienteAtivo: ingredienteAtivo,
      ));
    }

    return items;
  }

  /// Resolve nome da cultura
  Future<String> _resolveCulturaNome(String idCultura) async {
    try {
      final id = int.tryParse(idCultura);
      if (id == null) return '';
      
      final culturaRepo = ref.read(culturasRepositoryProvider);
      final data = await culturaRepo.findById(id);
      return data?.nome ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Resolve nome da praga
  Future<String> _resolvePragaNome(String idPraga) async {
    try {
      final id = int.tryParse(idPraga);
      if (id == null) return '';
      
      final pragaRepo = ref.read(pragasRepositoryProvider);
      final data = await pragaRepo.findById(id);
      return data?.nome ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Resolve dados do defensivo (nome e ingrediente ativo)
  Future<(String, String)> _resolveDefensivoData(String idDefensivo) async {
    try {
      debugPrint('🔍 [DiagByEntity] _resolveDefensivoData: idDefensivo="$idDefensivo"');
      
      // Tenta primeiro como int (ID numérico do banco)
      final id = int.tryParse(idDefensivo);
      if (id != null) {
        final defensivoRepo = ref.read(fitossanitariosRepositoryProvider);
        final data = await defensivoRepo.findById(id);
        if (data != null) {
          debugPrint('✅ [DiagByEntity] Defensivo encontrado por ID int: ${data.nome}');
          final nome = data.nome;
          final ingrediente = data.ingredienteAtivo?.isNotEmpty == true
              ? data.ingredienteAtivo!
              : 'Não especificado';
          return (nome, ingrediente);
        }
      }
      
      // Tenta como string (idDefensivo original)
      final defensivoRepo = ref.read(fitossanitariosRepositoryProvider);
      final data = await defensivoRepo.getById(idDefensivo);
      if (data != null) {
        debugPrint('✅ [DiagByEntity] Defensivo encontrado por idDefensivo string: ${data.nome}');
        final nome = data.nome;
        final ingrediente = data.ingredienteAtivo?.isNotEmpty == true
            ? data.ingredienteAtivo!
            : 'Não especificado';
        return (nome, ingrediente);
      }
      
      debugPrint('❌ [DiagByEntity] Defensivo NÃO encontrado: idDefensivo="$idDefensivo"');
    } catch (e) {
      debugPrint('❌ [DiagByEntity] Erro ao resolver defensivo: $e');
    }
    return ('', 'Não especificado');
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedCultura: cultura));
  }

  /// Limpa filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(searchQuery: '', selectedCultura: 'Todas'),
    );
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }
}
