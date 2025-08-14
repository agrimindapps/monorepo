import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import 'models/defensivo_agrupado_item_model.dart';
import 'models/defensivos_agrupados_category.dart';
import 'models/defensivos_agrupados_state.dart';
import 'models/defensivos_agrupados_view_mode.dart';
import 'widgets/defensivo_agrupado_search_field_widget.dart';
import 'widgets/defensivo_agrupado_item_widget.dart';
import 'widgets/defensivos_agrupados_loading_skeleton_widget.dart';
import 'widgets/defensivos_agrupados_empty_state_widget.dart';

class ListaDefensivosAgrupadosPage extends StatefulWidget {
  final String tipoAgrupamento;
  final String? textoFiltro;

  const ListaDefensivosAgrupadosPage({
    super.key,
    required this.tipoAgrupamento,
    this.textoFiltro,
  });

  @override
  State<ListaDefensivosAgrupadosPage> createState() => _ListaDefensivosAgrupadosPageState();
}

class _ListaDefensivosAgrupadosPageState extends State<ListaDefensivosAgrupadosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  
  DefensivosAgrupadosState _state = const DefensivosAgrupadosState();
  late DefensivosAgrupadosCategory _category;

  @override
  void initState() {
    super.initState();
    _category = DefensivosAgrupadosCategory.fromString(widget.tipoAgrupamento);
    _searchController.addListener(_onSearchChanged);
    _initializeState();
    _loadInitialData();
    _configureStatusBar();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _configureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _initializeState() {
    _state = _state.copyWith(
      categoria: widget.tipoAgrupamento,
      title: _category.title,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  void _loadInitialData() async {
    _updateState(_state.copyWith(isLoading: true));
    
    // Simula carregamento de dados
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final mockData = _generateMockData();
    
    _updateState(_state.copyWith(
      defensivosList: mockData,
      defensivosListFiltered: mockData,
      isLoading: false,
    ));
  }

  List<DefensivoAgrupadoItemModel> _generateMockData() {
    switch (_category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return [
          const DefensivoAgrupadoItemModel(
            idReg: '1',
            line1: 'Bayer S.A.',
            line2: 'Empresa multinacional alemã',
            count: '245',
            categoria: 'fabricante',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '2',
            line1: 'Syngenta',
            line2: 'Líder mundial em agricultura',
            count: '187',
            categoria: 'fabricante',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '3',
            line1: 'BASF S.A.',
            line2: 'Química para agricultura',
            count: '156',
            categoria: 'fabricante',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '4',
            line1: 'Corteva',
            line2: 'Inovação em proteção de cultivos',
            count: '134',
            categoria: 'fabricante',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '5',
            line1: 'FMC Corporation',
            line2: 'Soluções agrícolas avançadas',
            count: '98',
            categoria: 'fabricante',
          ),
        ];
      
      case DefensivosAgrupadosCategory.classeAgronomica:
        return [
          const DefensivoAgrupadoItemModel(
            idReg: '6',
            line1: 'Herbicida',
            line2: 'Controle de plantas daninhas',
            count: '342',
            categoria: 'classe',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '7',
            line1: 'Inseticida',
            line2: 'Controle de insetos',
            count: '267',
            categoria: 'classe',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '8',
            line1: 'Fungicida',
            line2: 'Controle de fungos',
            count: '198',
            categoria: 'classe',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '9',
            line1: 'Acaricida',
            line2: 'Controle de ácaros',
            count: '89',
            categoria: 'classe',
          ),
        ];
      
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return [
          const DefensivoAgrupadoItemModel(
            idReg: '10',
            line1: 'Glifosato',
            line2: 'Herbicida sistêmico não seletivo',
            count: '45',
            ingredienteAtivo: 'Glifosato',
            categoria: 'ingrediente',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '11',
            line1: '2,4-D',
            line2: 'Herbicida hormonal seletivo',
            count: '38',
            ingredienteAtivo: '2,4-D',
            categoria: 'ingrediente',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '12',
            line1: 'Imidacloprido',
            line2: 'Inseticida sistêmico',
            count: '34',
            ingredienteAtivo: 'Imidacloprido',
            categoria: 'ingrediente',
          ),
        ];
      
      case DefensivosAgrupadosCategory.modoAcao:
        return [
          const DefensivoAgrupadoItemModel(
            idReg: '13',
            line1: 'Inibição da síntese de aminoácidos',
            line2: 'Grupo 9 - HRAC',
            count: '67',
            categoria: 'modo_acao',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '14',
            line1: 'Auxina sintética',
            line2: 'Grupo 4 - HRAC',
            count: '45',
            categoria: 'modo_acao',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '15',
            line1: 'Antagonista do receptor nicotínico',
            line2: 'Grupo 4A - IRAC',
            count: '38',
            categoria: 'modo_acao',
          ),
        ];
      
      default:
        return [
          const DefensivoAgrupadoItemModel(
            idReg: '16',
            line1: 'Roundup Original DI',
            line2: 'Herbicida sistêmico',
            ingredienteAtivo: 'Glifosato',
            categoria: 'defensivo',
          ),
          const DefensivoAgrupadoItemModel(
            idReg: '17',
            line1: 'Provence 800 WG',
            line2: 'Fungicida protetor',
            ingredienteAtivo: 'Mancozebe',
            categoria: 'defensivo',
          ),
        ];
    }
  }

  void _updateState(DefensivosAgrupadosState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    
    final searchText = _searchController.text;
    
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
    final searchText = _state.searchText.toLowerCase();
    
    List<DefensivoAgrupadoItemModel> filtered = _state.defensivosList;
    
    if (searchText.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.line1.toLowerCase().contains(searchText) ||
            item.line2.toLowerCase().contains(searchText) ||
            (item.ingredienteAtivo?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    }
    
    // Sort by name
    filtered.sort((a, b) {
      final comparison = a.line1.compareTo(b.line1);
      return _state.isAscending ? comparison : -comparison;
    });
    
    _updateState(_state.copyWith(defensivosListFiltered: filtered));
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    _updateState(_state.copyWith(
      searchText: '',
      isSearching: false,
    ));
    _applyCurrentFilter();
  }

  void _toggleViewMode(DefensivosAgrupadosViewMode mode) {
    _updateState(_state.copyWith(selectedViewMode: mode));
  }

  void _toggleSort() {
    _updateState(_state.copyWith(isAscending: !_state.isAscending));
    _applyCurrentFilter();
  }

  void _handleItemTap(DefensivoAgrupadoItemModel item) {
    if (item.isDefensivo) {
      // Navigate to defensivo details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando para detalhes: ${item.displayTitle}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to group items (hierarchical navigation)
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
    
    // Simulate loading group items
    _loadGroupItems(item);
  }

  void _loadGroupItems(DefensivoAgrupadoItemModel groupItem) async {
    _updateState(_state.copyWith(isLoading: true));
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate mock items for this group
    final groupItems = List.generate(8, (index) {
      return DefensivoAgrupadoItemModel(
        idReg: '${groupItem.idReg}_item_$index',
        line1: 'Item ${index + 1} - ${groupItem.displayTitle}',
        line2: 'Produto específico do grupo',
        ingredienteAtivo: 'Ingrediente ${index + 1}',
        categoria: 'defensivo',
      );
    });
    
    _updateState(_state.copyWith(
      defensivosList: groupItems,
      defensivosListFiltered: groupItems,
      isLoading: false,
    ));
  }

  bool _canNavigateBack() {
    return _state.canNavigateBack;
  }

  void _navigateBack() {
    if (_state.navigationLevel == 1) {
      _backToCategories();
    }
  }

  void _backToCategories() {
    _clearSearchFieldSilently();
    
    _updateState(_state.copyWith(
      navigationLevel: 0,
      selectedGroupId: '',
      title: _category.title,
      defensivosList: _state.categoriesList,
      defensivosListFiltered: _state.categoriesList,
      currentPage: 0,
      finalPage: false,
    ));
  }

  void _clearSearchFieldSilently() {
    _searchController.removeListener(_onSearchChanged);
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    _searchController.addListener(_onSearchChanged);
    
    _updateState(_state.copyWith(
      searchText: '',
      isSearching: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state.navigationLevel == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _canNavigateBack()) {
          _navigateBack();
        }
      },
      child: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              _buildModernHeader(),
              _buildSearchField(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return ModernHeaderWidget(
      title: _state.title.isNotEmpty ? _state.title : _getDefaultTitle(),
      subtitle: _getSubtitle(),
      leftIcon: _getHeaderIcon(),
      rightIcon: _state.isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: _state.isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () {
        if (_canNavigateBack()) {
          _navigateBack();
        } else {
          Navigator.of(context).pop();
        }
      },
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildSearchField() {
    return DefensivoAgrupadoSearchFieldWidget(
      controller: _searchController,
      isDark: _state.isDark,
      isSearching: _state.isSearching,
      selectedViewMode: _state.selectedViewMode,
      onToggleViewMode: _toggleViewMode,
      onClear: _clearSearch,
      hintText: _category.searchHint,
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
        child: _buildDefensivosList(),
      ),
    );
  }

  Widget _buildDefensivosList() {
    if (_state.isLoading && _state.defensivosListFiltered.isEmpty) {
      return DefensivosAgrupadosLoadingSkeletonWidget(
        viewMode: _state.selectedViewMode,
        isDark: _state.isDark,
        itemCount: 12,
      );
    }

    if (_state.defensivosListFiltered.isEmpty) {
      return DefensivosAgrupadosEmptyStateWidget(
        category: _category,
        isDark: _state.isDark,
        isSearching: _state.searchText.isNotEmpty,
        searchText: _state.searchText,
        navigationLevel: _state.navigationLevel,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _state.isDark ? const Color(0xFF1E1E22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _state.isDark 
              ? Colors.grey.shade800 
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    if (_state.selectedViewMode.isList) {
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: _state.defensivosListFiltered.length,
        itemBuilder: (context, index) {
          final item = _state.defensivosListFiltered[index];
          return DefensivoAgrupadoItemWidget(
            item: item,
            viewMode: _state.selectedViewMode,
            category: _category,
            isDark: _state.isDark,
            onTap: () => _handleItemTap(item),
          );
        },
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          
          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _state.defensivosListFiltered.length,
            itemBuilder: (context, index) {
              final item = _state.defensivosListFiltered[index];
              return DefensivoAgrupadoItemWidget(
                item: item,
                viewMode: _state.selectedViewMode,
                category: _category,
                isDark: _state.isDark,
                onTap: () => _handleItemTap(item),
              );
            },
          );
        },
      );
    }
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth <= 480) return 2;
    if (screenWidth <= 768) return 3;
    if (screenWidth <= 1024) return 4;
    return 5;
  }

  String _getDefaultTitle() {
    return _category.title;
  }

  String _getSubtitle() {
    final totalItems = _state.defensivosListFiltered.length;
    
    if (_state.isLoading && totalItems == 0) {
      return 'Carregando registros...';
    }
    
    return '$totalItems registros';
  }

  IconData _getHeaderIcon() {
    return _category.icon;
  }
}