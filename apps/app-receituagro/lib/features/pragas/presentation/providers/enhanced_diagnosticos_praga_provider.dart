import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/diagnostico_compatibility_service.dart';
import '../../../../core/services/diagnostico_entity_resolver.dart';
import '../../../../core/services/diagnostico_grouping_service.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';

/// Provider aprimorado para gerenciar diagnósticos relacionados à praga
/// 
/// Utiliza os novos serviços centralizados para:
/// - Cache otimizado com índices invertidos
/// - Resolução consistente de nomes de entidades
/// - Agrupamento unificado por cultura
/// - Validação de compatibilidade
/// - Busca por texto avançada
class EnhancedDiagnosticosPragaProvider extends ChangeNotifier {
  late final IDiagnosticosRepository _repository = sl<IDiagnosticosRepository>();
  
  // Serviços centralizados
  final _resolver = DiagnosticoEntityResolver.instance;
  final _groupingService = DiagnosticoGroupingService.instance;
  final _compatibilityService = DiagnosticoCompatibilityService.instance;

  // Estado dos diagnósticos
  List<DiagnosticoEntity> _diagnosticos = [];
  bool _isLoading = false;
  bool _isLoadingFilters = false;
  String? _errorMessage;
  String? _currentPragaId;
  String? _currentPragaName;

  // Estado dos filtros
  String _searchQuery = '';
  String _selectedCultura = 'Todas';
  List<String> _availableCulturas = ['Todas'];

  // Cache de agrupamentos
  Map<String, List<DiagnosticoEntity>>? _cachedGrouping;
  DateTime? _lastGroupingUpdate;
  static const Duration _groupingCacheTTL = Duration(minutes: 5);

  // Getters públicos
  List<DiagnosticoEntity> get diagnosticos => _diagnosticos;
  List<DiagnosticoEntity> get filteredDiagnosticos => _applyFilters();
  Map<String, List<DiagnosticoEntity>> get groupedDiagnosticos => _cachedGrouping ?? {};
  
  bool get isLoading => _isLoading;
  bool get isLoadingFilters => _isLoadingFilters;
  bool get hasData => _diagnosticos.isNotEmpty;
  bool get hasError => _errorMessage != null;
  bool get hasFilters => _searchQuery.isNotEmpty || _selectedCultura != 'Todas';
  
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCultura => _selectedCultura;
  List<String> get availableCulturas => _availableCulturas;
  String? get currentPragaId => _currentPragaId;
  String? get currentPragaName => _currentPragaName;

  // Estatísticas
  int get totalDiagnosticos => _diagnosticos.length;
  int get filteredCount => filteredDiagnosticos.length;
  int get cultureGroupsCount => groupedDiagnosticos.length;

  /// Inicializa o provider
  Future<void> initialize() async {
    try {
      // Inicializa serviços se necessário
      // Cache temporariamente desabilitado
      // if (_cacheService.performanceStats.indexSize == 0) {
      //   await _cacheService.initialize();
      // }
    } catch (e) {
      // Initialization errors are logged internally
    }
  }

  /// Carrega diagnósticos para uma praga específica por ID
  Future<void> loadDiagnosticos(String pragaId) async {

    _currentPragaId = pragaId;
    _currentPragaName = await _resolver.resolvePragaNome(idPraga: pragaId);
    _setLoadingState(true);

    try {
      // Direct repository call for optimal performance
      final result = await _repository.getByPraga(pragaId);

      await result.fold(
        (failure) async {
          _setErrorState('Erro ao carregar diagnósticos: ${failure.toString()}');
        },
        (entities) async {
          _setSuccessState(entities);
          await _updateAvailableCulturas();
        },
      );
    } catch (e) {
      _setErrorState('Erro ao carregar diagnósticos: $e');
    }
  }


  /// Busca diagnósticos por texto usando cache otimizado
  Future<void> searchByText(String query) async {
    if (query.trim().isEmpty) {
      updateSearchQuery('');
      return;
    }

    _setLoadingState(true);

    try {
      // Usa cache service para busca por texto otimizada
      // Cache temporariamente desabilitado - usando repository direto
      final diagnosticos = await _repository.searchByPattern(query);
      final diagnosticosHive = diagnosticos.fold(
        (failure) => <DiagnosticoEntity>[],
        (data) => data,
      );
      
      if (diagnosticosHive.isNotEmpty) {
        // Converte para entidades se necessário
        final ids = diagnosticosHive.map((d) => d.id).toList();
        final filteredResults = <DiagnosticoEntity>[];
        
        for (final id in ids) {
          final result = await _repository.getById(id);
          result.fold(
            (failure) => null,
            (entity) {
              if (entity != null) filteredResults.add(entity);
            },
          );
        }
        
        _setSuccessState(filteredResults);
        await _updateAvailableCulturas();
        updateSearchQuery(query);
      } else {
        _setSuccessState([]);
        updateSearchQuery(query);
      }
    } catch (e) {
      _setErrorState('Erro na busca por texto: $e');
    }
  }

  /// Atualiza query de pesquisa com debounce
  void updateSearchQuery(String query) {
    _isLoadingFilters = true;
    notifyListeners();
    
    _searchQuery = query;
    _invalidateGroupingCache();
    
    _isLoadingFilters = false;
    notifyListeners();
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    _isLoadingFilters = true;
    notifyListeners();
    
    _selectedCultura = cultura;
    _invalidateGroupingCache();
    
    _isLoadingFilters = false;
    notifyListeners();
  }

  /// Aplica filtros aos diagnósticos
  List<DiagnosticoEntity> _applyFilters() {
    var filtered = List<DiagnosticoEntity>.from(_diagnosticos);

    // Filtro por texto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((diag) {
        final query = _searchQuery.toLowerCase();
        return (diag.nomeDefensivo?.toLowerCase().contains(query) ?? false) ||
               (diag.nomeCultura?.toLowerCase().contains(query) ?? false) ||
               (diag.nomePraga?.toLowerCase().contains(query) ?? false) ||
               diag.idDefensivo.toLowerCase().contains(query);
      }).toList();
    }

    // Filtro por cultura - usa dados já resolvidos no nomeCultura se disponível
    if (_selectedCultura != 'Todas') {
      filtered = filtered.where((diag) {
        final culturaNome = diag.nomeCultura ?? '';
        return culturaNome == _selectedCultura;
      }).toList();
    }

    return filtered;
  }

  /// Atualiza agrupamentos de forma assíncrona
  Future<void> updateGroupings() async {
    // Verifica cache de agrupamento
    if (_isGroupingCacheValid() && _cachedGrouping != null) {
      return;
    }

    // Gera novo agrupamento usando serviço centralizado
    final filtered = filteredDiagnosticos;
    final grouped = await _groupingService.groupDiagnosticoEntitiesByCultura(
      filtered,
      sortByRelevance: true,
    );

    // Cache resultado
    _cachedGrouping = grouped;
    _lastGroupingUpdate = DateTime.now();
    notifyListeners();
  }

  /// Verifica se cache de agrupamento é válido
  bool _isGroupingCacheValid() {
    return _lastGroupingUpdate != null &&
           DateTime.now().difference(_lastGroupingUpdate!) < _groupingCacheTTL;
  }

  /// Invalida cache de agrupamento
  void _invalidateGroupingCache() {
    _cachedGrouping = null;
    _lastGroupingUpdate = null;
  }

  /// Atualiza lista de culturas disponíveis
  Future<void> _updateAvailableCulturas() async {
    final culturas = <String>{'Todas'};

    for (final diag in _diagnosticos) {
      // ✅ CORRETO: Resolve apenas usando ID, NUNCA nomeCultura cached
      if (diag.idCultura.isNotEmpty) {
        final culturaNome = await _resolver.resolveCulturaNome(
          idCultura: diag.idCultura,
        );
        if (culturaNome.isNotEmpty && culturaNome != 'Cultura não especificada') {
          culturas.add(culturaNome);
        }
      }
    }

    _availableCulturas = culturas.toList()..sort();
  }

  /// Valida compatibilidade para um diagnóstico específico
  Future<CompatibilityValidation?> validateCompatibility(DiagnosticoEntity diagnostico) async {
    if (_currentPragaId?.isNotEmpty != true) return null;

    try {
      return await _compatibilityService.validateFullCompatibility(
        idDefensivo: diagnostico.idDefensivo,
        idCultura: diagnostico.idCultura,
        idPraga: _currentPragaId!,
        includeAlternatives: false,
      );
    } catch (e) {
      debugPrint('❌ Erro ao validar compatibilidade: $e');
      return null;
    }
  }

  /// Obtém sugestões de busca
  List<String> getSuggestions(String partialQuery) {
    // Cache temporariamente desabilitado - retornando lista vazia
    return [];
  }

  /// Obtém estatísticas dos dados
  DiagnosticosStats get stats {
    final grouping = groupedDiagnosticos;
    
    return DiagnosticosStats(
      total: totalDiagnosticos,
      filtered: filteredCount,
      groups: grouping.length,
      avgGroupSize: grouping.isNotEmpty 
          ? grouping.values.map((list) => list.length).reduce((a, b) => a + b) / grouping.length
          : 0.0,
      hasFilters: hasFilters,
      cacheHitRate: 0.0, // Cache temporariamente desabilitado
    );
  }

  /// Estados internos

  void _setLoadingState(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setErrorState(String error) {
    _errorMessage = error;
    _isLoading = false;
    debugPrint('❌ $_errorMessage');
    notifyListeners();
  }

  void _setSuccessState(List<DiagnosticoEntity> diagnosticos) {
    _diagnosticos = diagnosticos;
    _errorMessage = null;
    _isLoading = false;
    _invalidateGroupingCache();
    notifyListeners();
  }

  /// Limpa todos os dados e filtros
  void clear() {
    _diagnosticos.clear();
    _searchQuery = '';
    _selectedCultura = 'Todas';
    _availableCulturas = ['Todas'];
    _errorMessage = null;
    _isLoading = false;
    _isLoadingFilters = false;
    _currentPragaId = null;
    _currentPragaName = null;
    _invalidateGroupingCache();
    notifyListeners();
  }

  /// Limpa apenas filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCultura = 'Todas';
    _isLoadingFilters = false;
    _invalidateGroupingCache();
    notifyListeners();
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Força recarregamento dos dados
  Future<void> refresh() async {
    if (_currentPragaId?.isNotEmpty == true) {
      await loadDiagnosticos(_currentPragaId!);
    }
  }

  @override
  void dispose() {
    _diagnosticos.clear();
    _cachedGrouping?.clear();
    super.dispose();
  }
}

/// Classe para estatísticas dos diagnósticos
class DiagnosticosStats {
  final int total;
  final int filtered;
  final int groups;
  final double avgGroupSize;
  final bool hasFilters;
  final double cacheHitRate;

  const DiagnosticosStats({
    required this.total,
    required this.filtered,
    required this.groups,
    required this.avgGroupSize,
    required this.hasFilters,
    required this.cacheHitRate,
  });

  @override
  String toString() {
    return 'DiagnosticosStats{total: $total, filtered: $filtered, '
           'groups: $groups, hitRate: ${cacheHitRate.toStringAsFixed(1)}%}';
  }
}