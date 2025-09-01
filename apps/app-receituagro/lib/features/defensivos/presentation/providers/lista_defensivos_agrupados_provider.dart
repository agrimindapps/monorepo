import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../models/defensivo_agrupado_item_model.dart';
import '../../models/defensivos_agrupados_category.dart';
import '../../models/defensivos_agrupados_state.dart';
import '../../models/defensivos_agrupados_view_mode.dart';

/// Provider para gerenciar estado da Lista de Defensivos Agrupados
/// Segue padrão Provider estabelecido no app-receituagro
class ListaDefensivosAgrupadosProvider extends ChangeNotifier {
  final FitossanitarioHiveRepository _repository = sl<FitossanitarioHiveRepository>();
  Timer? _searchDebounceTimer;
  
  DefensivosAgrupadosState _state = const DefensivosAgrupadosState();
  late DefensivosAgrupadosCategory _category;
  
  // Getters para state
  DefensivosAgrupadosState get state => _state;
  DefensivosAgrupadosCategory get category => _category;
  
  // Getters específicos
  List<DefensivoAgrupadoItemModel> get defensivosList => _state.defensivosList;
  List<DefensivoAgrupadoItemModel> get defensivosListFiltered => _state.defensivosListFiltered;
  bool get isLoading => _state.isLoading;
  bool get isSearching => _state.isSearching;
  String get searchText => _state.searchText;
  String get title => _state.title;
  bool get isDark => _state.isDark;
  DefensivosAgrupadosViewMode get selectedViewMode => _state.selectedViewMode;
  bool get isAscending => _state.isAscending;
  int get navigationLevel => _state.navigationLevel;
  bool get canNavigateBack => _state.canNavigateBack;
  String get selectedGroupId => _state.selectedGroupId;
  List<DefensivoAgrupadoItemModel> get categoriesList => _state.categoriesList;

  /// Inicializa o provider com parâmetros
  void initialize(String tipoAgrupamento, bool isDarkTheme) {
    _category = DefensivosAgrupadosCategory.fromString(tipoAgrupamento);
    _updateState(_state.copyWith(
      categoria: tipoAgrupamento,
      title: _category.title,
      isDark: isDarkTheme,
    ));
    _loadInitialData();
  }

  void _updateState(DefensivosAgrupadosState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Carrega dados iniciais do repositório
  Future<void> _loadInitialData() async {
    try {
      _updateState(_state.copyWith(isLoading: true));
      
      // Carrega dados reais do repositório Hive
      final defensivosHive = _repository.getActiveDefensivos();
      
      // Performance optimization: Early exit if no data
      if (defensivosHive.isEmpty) {
        _updateState(_state.copyWith(
          defensivosList: <DefensivoAgrupadoItemModel>[],
          defensivosListFiltered: <DefensivoAgrupadoItemModel>[],
          isLoading: false,
        ));
        return;
      }
      
      // Converte e agrupa dados conforme o tipo de agrupamento
      final realData = _convertAndGroupData(defensivosHive);
      
      _updateState(_state.copyWith(
        defensivosList: realData,
        defensivosListFiltered: realData,
        isLoading: false,
      ));
      
    } catch (e) {
      debugPrint('Erro ao carregar dados iniciais: $e');
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  /// Converte e agrupa dados do Hive conforme tipo de agrupamento
  List<DefensivoAgrupadoItemModel> _convertAndGroupData(List<FitossanitarioHive> defensivos) {
    switch (_category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return _groupByFabricante(defensivos);
      case DefensivosAgrupadosCategory.classeAgronomica:
        return _groupByClasseAgronomica(defensivos);
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return _groupByIngredienteAtivo(defensivos);
      case DefensivosAgrupadosCategory.modoAcao:
        return _groupByModoAcao(defensivos);
      default:
        return _convertToDefensivoItems(defensivos);
    }
  }

  /// Valida se o nome do grupo é válido (mais de 2 caracteres após limpeza)
  bool _isValidGroupName(String? name) {
    if (name == null || name.isEmpty) return false;
    final cleanName = name.trim().replaceAll(',', '').replaceAll(' ', '');
    return cleanName.length > 2;
  }
  
  /// Agrupa por fabricante
  List<DefensivoAgrupadoItemModel> _groupByFabricante(List<FitossanitarioHive> defensivos) {
    final grouped = <String, List<FitossanitarioHive>>{};
    
    for (final defensivo in defensivos) {
      final fabricante = defensivo.fabricante;
      if (_isValidGroupName(fabricante)) {
        grouped.putIfAbsent(fabricante!, () => []).add(defensivo);
      }
    }
    
    return grouped.entries.map((entry) {
      return DefensivoAgrupadoItemModel(
        idReg: entry.key.hashCode.toString(),
        line1: entry.key,
        line2: 'Fabricante de defensivos agrícolas',
        count: entry.value.length.toString(),
        categoria: 'fabricante',
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }
  
  /// Agrupa por classe agronômica
  List<DefensivoAgrupadoItemModel> _groupByClasseAgronomica(List<FitossanitarioHive> defensivos) {
    final grouped = <String, List<FitossanitarioHive>>{};
    
    for (final defensivo in defensivos) {
      final classe = defensivo.classeAgronomica;
      if (_isValidGroupName(classe)) {
        grouped.putIfAbsent(classe!, () => []).add(defensivo);
      }
    }
    
    return grouped.entries.map((entry) {
      return DefensivoAgrupadoItemModel(
        idReg: entry.key.hashCode.toString(),
        line1: entry.key,
        line2: _getClasseDescription(entry.key),
        count: entry.value.length.toString(),
        categoria: 'classe',
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }
  
  /// Agrupa por ingrediente ativo
  List<DefensivoAgrupadoItemModel> _groupByIngredienteAtivo(List<FitossanitarioHive> defensivos) {
    final grouped = <String, List<FitossanitarioHive>>{};
    
    for (final defensivo in defensivos) {
      final ingrediente = defensivo.ingredienteAtivo;
      if (_isValidGroupName(ingrediente)) {
        grouped.putIfAbsent(ingrediente!, () => []).add(defensivo);
      }
    }
    
    return grouped.entries.map((entry) {
      return DefensivoAgrupadoItemModel(
        idReg: entry.key.hashCode.toString(),
        line1: entry.key,
        line2: 'Ingrediente ativo',
        count: entry.value.length.toString(),
        ingredienteAtivo: entry.key,
        categoria: 'ingrediente',
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }
  
  /// Agrupa por modo de ação
  List<DefensivoAgrupadoItemModel> _groupByModoAcao(List<FitossanitarioHive> defensivos) {
    final grouped = <String, List<FitossanitarioHive>>{};
    
    for (final defensivo in defensivos) {
      final modo = defensivo.modoAcao;
      if (_isValidGroupName(modo)) {
        grouped.putIfAbsent(modo!, () => []).add(defensivo);
      }
    }
    
    return grouped.entries.map((entry) {
      return DefensivoAgrupadoItemModel(
        idReg: entry.key.hashCode.toString(),
        line1: entry.key,
        line2: 'Modo de ação do defensivo',
        count: entry.value.length.toString(),
        categoria: 'modo_acao',
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }
  
  /// Converte para itens de defensivo individuais
  List<DefensivoAgrupadoItemModel> _convertToDefensivoItems(List<FitossanitarioHive> defensivos) {
    return defensivos.map((defensivo) {
      return DefensivoAgrupadoItemModel(
        idReg: defensivo.idReg,
        line1: defensivo.nomeComum,
        line2: defensivo.nomeTecnico,
        ingredienteAtivo: defensivo.ingredienteAtivo,
        categoria: 'defensivo',
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }
  
  /// Retorna descrição da classe agronômica
  String _getClasseDescription(String classe) {
    switch (classe.toLowerCase()) {
      case 'herbicida':
        return 'Controle de plantas daninhas';
      case 'inseticida':
        return 'Controle de insetos';
      case 'fungicida':
        return 'Controle de fungos';
      case 'acaricida':
        return 'Controle de ácaros';
      default:
        return 'Defensivo agrícola';
    }
  }

  /// Atualiza texto de busca com debounce
  void updateSearchText(String searchText) {
    _searchDebounceTimer?.cancel();
    
    _updateState(_state.copyWith(
      searchText: searchText,
      isSearching: searchText.isNotEmpty,
    ));

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) {
    _applyCurrentFilter();
    _updateState(_state.copyWith(isSearching: false));
  }

  void _applyCurrentFilter() {
    // Performance optimization: Early exit if no data to filter
    if (_state.defensivosList.isEmpty) {
      _updateState(_state.copyWith(defensivosListFiltered: <DefensivoAgrupadoItemModel>[]));
      return;
    }
    
    final searchText = _state.searchText.toLowerCase();
    List<DefensivoAgrupadoItemModel> filtered = _state.defensivosList;
    
    // Performance optimization: Only filter if search text exists
    if (searchText.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.line1.toLowerCase().contains(searchText) ||
            item.line2.toLowerCase().contains(searchText) ||
            (item.ingredienteAtivo?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    }
    
    // Performance optimization: Only sort if list is not empty
    if (filtered.isNotEmpty) {
      filtered.sort((a, b) {
        final comparison = a.line1.compareTo(b.line1);
        return _state.isAscending ? comparison : -comparison;
      });
    }
    
    _updateState(_state.copyWith(defensivosListFiltered: filtered));
  }

  /// Limpa busca
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    _updateState(_state.copyWith(
      searchText: '',
      isSearching: false,
    ));
    _applyCurrentFilter();
  }

  /// Toggle view mode
  void toggleViewMode(DefensivosAgrupadosViewMode mode) {
    _updateState(_state.copyWith(selectedViewMode: mode));
  }

  /// Toggle ordenação
  void toggleSort() {
    _updateState(_state.copyWith(isAscending: !_state.isAscending));
    _applyCurrentFilter();
  }

  /// Handle item tap - navigation logic
  void handleItemTap(DefensivoAgrupadoItemModel item) {
    if (item.isDefensivo) {
      // Defensivo individual - navigation handled by UI layer
    } else {
      // Group navigation - hierarchical navigation
      _navigateToGroup(item);
    }
  }

  void _navigateToGroup(DefensivoAgrupadoItemModel item) {
    final currentCategories = List<DefensivoAgrupadoItemModel>.from(_state.defensivosList);
    
    _updateState(_state.copyWith(
      navigationLevel: 1,
      selectedGroupId: item.idReg,
      categoriesList: currentCategories,
      title: '${_category.label} - ${item.displayTitle}',
    ));
    
    // Load group items
    _loadGroupItems(item);
  }

  /// Carrega itens reais de um grupo específico baseado no tipo de agrupamento
  Future<void> _loadGroupItems(DefensivoAgrupadoItemModel groupItem) async {
    _updateState(_state.copyWith(isLoading: true));
    
    try {
      // Carrega todos os defensivos do repositório
      final allDefensivos = _repository.getActiveDefensivos();
      
      // Filtra defensivos pertencentes ao grupo selecionado
      final groupItems = _getDefensivosForGroup(groupItem, allDefensivos);
      
      _updateState(_state.copyWith(
        defensivosList: groupItems,
        defensivosListFiltered: groupItems,
        isLoading: false,
      ));
      
    } catch (e) {
      debugPrint('Erro ao carregar itens do grupo: $e');
      _updateState(_state.copyWith(
        defensivosList: [],
        defensivosListFiltered: [],
        isLoading: false,
      ));
    }
  }
  
  /// Filtra defensivos que pertencem ao grupo selecionado
  List<DefensivoAgrupadoItemModel> _getDefensivosForGroup(
    DefensivoAgrupadoItemModel groupItem, 
    List<FitossanitarioHive> allDefensivos,
  ) {
    final List<FitossanitarioHive> filteredDefensivos;
    
    // Filtra baseado no tipo de agrupamento
    switch (_category) {
      case DefensivosAgrupadosCategory.fabricantes:
        filteredDefensivos = allDefensivos.where(
          (d) => d.fabricante == groupItem.line1,
        ).toList();
        break;
        
      case DefensivosAgrupadosCategory.classeAgronomica:
        filteredDefensivos = allDefensivos.where(
          (d) => d.classeAgronomica == groupItem.line1,
        ).toList();
        break;
        
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        filteredDefensivos = allDefensivos.where(
          (d) => d.ingredienteAtivo == groupItem.line1,
        ).toList();
        break;
        
      case DefensivosAgrupadosCategory.modoAcao:
        filteredDefensivos = allDefensivos.where(
          (d) => d.modoAcao == groupItem.line1,
        ).toList();
        break;
        
      default:
        filteredDefensivos = allDefensivos;
    }
    
    // Converte para DefensivoAgrupadoItemModel com dados reais
    return filteredDefensivos.map((defensivo) {
      return DefensivoAgrupadoItemModel(
        idReg: defensivo.idReg,
        line1: defensivo.nomeComum.isNotEmpty ? defensivo.nomeComum : defensivo.nomeTecnico,
        line2: defensivo.ingredienteAtivo ?? 'Ingrediente não informado',
        ingredienteAtivo: defensivo.ingredienteAtivo,
        categoria: 'defensivo',
        fabricante: defensivo.fabricante,
        classeAgronomica: defensivo.classeAgronomica,
        modoAcao: defensivo.modoAcao,
      );
    }).toList()..sort((a, b) => a.line1.compareTo(b.line1));
  }

  /// Navigation back logic
  void navigateBack() {
    if (_state.navigationLevel == 1) {
      _backToCategories();
    }
  }

  void _backToCategories() {
    _updateState(_state.copyWith(
      navigationLevel: 0,
      selectedGroupId: '',
      title: _category.title,
      defensivosList: _state.categoriesList,
      defensivosListFiltered: _state.categoriesList,
      currentPage: 0,
      finalPage: false,
      searchText: '',
      isSearching: false,
    ));
  }

  /// Helper getters for UI
  String getDefaultTitle() => _category.title;
  
  String getSubtitle() {
    final totalItems = _state.defensivosListFiltered.length;
    
    if (_state.isLoading && totalItems == 0) {
      return 'Carregando registros...';
    }
    
    return '$totalItems registros';
  }

  String getSearchHint() => _category.searchHint;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}