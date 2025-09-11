import 'package:flutter/foundation.dart';

import '../../data/services/defensivos_grouping_service.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import '../../domain/entities/drill_down_navigation_state.dart';

/// Provider para gerenciar estado de drill-down de defensivos
/// Gerencia navegação entre grupos e itens
/// Integra com DefensivosUnificadoProvider para dados
class DefensivosDrillDownProvider extends ChangeNotifier {
  final DefensivosGroupingService _groupingService;

  DefensivosDrillDownProvider({
    required DefensivosGroupingService groupingService,
  }) : _groupingService = groupingService;

  // Estado da navegação
  DrillDownNavigationState _navigationState = 
      DrillDownNavigationState.initial(tipoAgrupamento: 'fabricante');

  // Dados
  List<DefensivoEntity> _allDefensivos = [];
  List<DefensivoGroupEntity> _groups = [];
  List<DefensivoGroupEntity> _filteredGroups = [];
  List<DefensivoEntity> _currentGroupItems = [];
  
  // Estado de carregamento
  bool _isLoading = false;
  String? _errorMessage;

  // Getters públicos
  DrillDownNavigationState get navigationState => _navigationState;
  List<DefensivoGroupEntity> get groups => _filteredGroups;
  List<DefensivoEntity> get currentGroupItems => _currentGroupItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters de conveniência
  bool get isAtGroupLevel => _navigationState.isAtGroupLevel;
  bool get isAtItemLevel => _navigationState.isAtItemLevel;
  bool get canGoBack => _navigationState.canGoBack;
  String get pageTitle => _navigationState.pageTitle;
  String get pageSubtitle => _navigationState.pageSubtitle;
  List<String> get breadcrumbs => _navigationState.breadcrumbs;

  /// Inicializa provider com dados de defensivos
  void initializeWithDefensivos({
    required List<DefensivoEntity> defensivos,
    required String tipoAgrupamento,
  }) {
    _allDefensivos = defensivos;
    _navigationState = DrillDownNavigationState.initial(
      tipoAgrupamento: tipoAgrupamento,
    );
    
    _generateGroups();
    _applyCurrentFilters();
    notifyListeners();
  }

  /// Navegar para drill-down de um grupo
  void drillDownToGroup(DefensivoGroupEntity group) {
    _navigationState = _navigationState.drillDownToGroup(group);
    _updateCurrentGroupItems();
    notifyListeners();
  }

  /// Voltar para vista de grupos
  void goBackToGroups() {
    if (!_navigationState.canGoBack) return;
    
    _navigationState = _navigationState.goBackToGroups();
    _currentGroupItems = [];
    notifyListeners();
  }

  /// Atualizar filtro de busca
  void updateSearchFilter(String searchText) {
    _navigationState = _navigationState.updateSearch(searchText);
    _applyCurrentFilters();
    notifyListeners();
  }

  /// Limpar filtro de busca
  void clearSearchFilter() {
    _navigationState = _navigationState.clearSearch();
    _applyCurrentFilters();
    notifyListeners();
  }

  /// Toggle ordenação
  void toggleSort() {
    _navigationState = _navigationState.toggleSort();
    _applySorting();
    notifyListeners();
  }

  /// Atualizar defensivos
  void updateDefensivos(List<DefensivoEntity> defensivos) {
    _allDefensivos = defensivos;
    _generateGroups();
    _applyCurrentFilters();
    
    // Se estava em um grupo, atualizar itens
    if (_navigationState.isAtItemLevel) {
      _updateCurrentGroupItems();
    }
    
    notifyListeners();
  }

  /// Reset para estado inicial
  void reset() {
    _navigationState = _navigationState.reset();
    _currentGroupItems = [];
    _applyCurrentFilters();
    notifyListeners();
  }

  /// Obter estatísticas dos grupos
  Map<String, dynamic> getGroupStatistics() {
    return _groupingService.obterEstatisticas(grupos: _groups);
  }

  /// Definir estado de carregamento
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Definir erro
  void setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Métodos privados

  /// Gera grupos a partir dos defensivos
  void _generateGroups() {
    try {
      _groups = _groupingService.agruparDefensivos(
        defensivos: _allDefensivos,
        tipoAgrupamento: _navigationState.tipoAgrupamento,
      );
    } catch (e) {
      _groups = [];
      setError('Erro ao agrupar defensivos: $e');
    }
  }

  /// Aplica filtros atuais
  void _applyCurrentFilters() {
    try {
      // Primeiro, filtrar grupos com nomes muito curtos
      var filteredGroups = _groups.where((group) {
        return group.nome.length >= 3;
      }).toList();
      
      if (_navigationState.hasSearchFilter) {
        _filteredGroups = _groupingService.filtrarGrupos(
          grupos: filteredGroups,
          filtroTexto: _navigationState.searchText,
        );
      } else {
        _filteredGroups = filteredGroups;
      }
      
      _applySorting();
    } catch (e) {
      _filteredGroups = [];
      setError('Erro ao filtrar grupos: $e');
    }
  }

  /// Aplica ordenação
  void _applySorting() {
    try {
      _filteredGroups = _groupingService.ordenarGrupos(
        grupos: _filteredGroups,
        ascending: _navigationState.isAscending,
      );
    } catch (e) {
      setError('Erro ao ordenar grupos: $e');
    }
  }

  /// Atualiza itens do grupo atual
  void _updateCurrentGroupItems() {
    final currentGroup = _navigationState.currentGroup;
    if (currentGroup == null) {
      _currentGroupItems = [];
      return;
    }

    try {
      // Aplicar filtros aos itens do grupo
      var items = List<DefensivoEntity>.from(currentGroup.itens);
      
      // Filtrar itens com descrição menor que 3 caracteres
      items = items.where((item) {
        return item.displayName.length >= 3;
      }).toList();
      
      if (_navigationState.hasSearchFilter) {
        final filtroLower = _navigationState.searchText.toLowerCase();
        items = items.where((item) {
          return item.displayName.toLowerCase().contains(filtroLower) ||
                 item.displayIngredient.toLowerCase().contains(filtroLower) ||
                 item.displayFabricante.toLowerCase().contains(filtroLower) ||
                 item.displayClass.toLowerCase().contains(filtroLower);
        }).toList();
      }

      // Ordenar itens
      items.sort((a, b) {
        final comparison = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        return _navigationState.isAscending ? comparison : -comparison;
      });

      _currentGroupItems = items;
    } catch (e) {
      _currentGroupItems = [];
      setError('Erro ao atualizar itens do grupo: $e');
    }
  }

  /// Navegar para um grupo específico por nome
  void navigateToGroupByName(String groupName) {
    final group = _groups.firstWhere(
      (g) => g.nome == groupName,
      orElse: () => DefensivoGroupEntity.empty(
        tipoAgrupamento: _navigationState.tipoAgrupamento,
        nomeGrupo: groupName,
      ),
    );
    
    if (group.hasItems) {
      drillDownToGroup(group);
    }
  }

  /// Obter grupo por ID
  DefensivoGroupEntity? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// Verificar se tipo de agrupamento é válido
  bool isValidGroupingType(String type) {
    return _groupingService.isValidTipoAgrupamento(type);
  }

  @override
  void dispose() {
    // Limpar recursos se necessário
    super.dispose();
  }
}