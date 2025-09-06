import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/design/design_tokens.dart';
import '../../core/di/injection_container.dart';
import '../../core/models/pragas_hive.dart';
import '../../core/repositories/pragas_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'detalhe_praga_page.dart';
import 'models/lista_pragas_cultura_state.dart';
import 'models/praga_cultura_item_model.dart';
import 'models/praga_view_mode.dart';
import 'widgets/praga_cultura_empty_state_widget.dart';
import 'widgets/praga_cultura_item_widget.dart';
import 'widgets/praga_cultura_loading_skeleton_widget.dart';
import 'widgets/praga_cultura_search_field_widget.dart';
import 'widgets/praga_cultura_tab_bar_widget.dart';

/// Static function for compute() - processes pragas data in background isolate
/// Performance optimization: Prevents UI thread blocking during heavy data operations
List<PragaCulturaItemModel> _convertAndSortPragasData(List<PragasHive> pragasHive) {
  // Converte para PragaCulturaItemModel
  final realData = pragasHive.map((praga) {
    return PragaCulturaItemModel(
      idReg: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeSecundario: null, // PragasHive não tem este campo
      nomeCientifico: praga.nomeCientifico,
      nomeImagem: null, // PragasHive não tem este campo
      tipoPraga: praga.tipoPraga,
      categoria: praga.classe ?? praga.ordem ?? praga.familia, // Usa classe, ordem ou família
      grupo: praga.familia ?? praga.genero, // Usa família ou gênero
    );
  }).toList();
  
  // Ordena alfabeticamente por nome comum
  realData.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
  
  return realData;
}

class ListaPragasPorCulturaPage extends StatefulWidget {
  final String? culturaId;
  final String? culturaNome;

  const ListaPragasPorCulturaPage({
    super.key,
    this.culturaId,
    this.culturaNome,
  });

  @override
  State<ListaPragasPorCulturaPage> createState() => _ListaPragasPorCulturaPageState();
}

class _ListaPragasPorCulturaPageState extends State<ListaPragasPorCulturaPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final PragasHiveRepository _repository = sl<PragasHiveRepository>();
  Timer? _searchDebounceTimer;
  
  ListaPragasCulturaState _state = const ListaPragasCulturaState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeState();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _initializeState() {
    _state = _state.copyWith(
      culturaId: widget.culturaId ?? '',
      culturaNome: widget.culturaNome ?? 'Cultura Desconhecida',
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  void _loadInitialData() async {
    try {
      _updateState(_state.copyWith(isLoading: true));
      
      // Carrega e processa dados em background thread para evitar bloqueio da UI
      final realData = await _processDataInBackground();
      
      if (mounted) {
        _updateState(_state.copyWith(
          pragasList: realData,
          pragasFiltered: realData,
          isLoading: false,
        ));
        
        _applyCurrentFilter();
      }
      
    } catch (e) {
      if (mounted) {
        _updateState(_state.copyWith(
          isLoading: false,
        ));
      }
    }
  }

  /// Processa dados de pragas em background usando compute() para evitar bloqueio da UI thread
  /// Performance optimization: Move heavy operations to isolate to prevent UI freezing
  Future<List<PragaCulturaItemModel>> _processDataInBackground() async {
    // Carrega dados do repositório na main thread (necessário para Hive)
    final pragasHive = _repository.getAll();
    
    // Move processamento pesado para background thread
    return compute(_convertAndSortPragasData, pragasHive);
  }
  
  /// Converte PragasHive para PragaCulturaItemModel
  PragaCulturaItemModel _convertToPragaCulturaItem(PragasHive praga) {
    return PragaCulturaItemModel(
      idReg: praga.idReg,
      nomeComum: praga.nomeComum,
      nomeSecundario: null, // PragasHive não tem este campo
      nomeCientifico: praga.nomeCientifico,
      nomeImagem: null, // PragasHive não tem este campo
      tipoPraga: praga.tipoPraga,
      categoria: praga.classe ?? praga.ordem ?? praga.familia, // Usa classe, ordem ou família
      grupo: praga.familia ?? praga.genero, // Usa família ou gênero
    );
  }


  void _updateState(ListaPragasCulturaState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    _updateState(_state.copyWith(tabIndex: _tabController.index));
    _applyCurrentFilter();
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
    // Performance optimization: Early exit if data is not loaded yet
    if (_state.pragasList.isEmpty) return;
    
    final searchText = _state.searchText.toLowerCase();
    final currentTipoPraga = _state.currentTipoPraga;
    
    List<PragaCulturaItemModel> filtered = _state.pragasList;
    
    // Performance optimization: Filter by tab first (most restrictive filter)
    filtered = filtered.where((praga) => praga.tipoPraga == currentTipoPraga).toList();
    
    // Performance optimization: Only apply text search if needed
    if (searchText.isNotEmpty) {
      filtered = filtered.where((praga) {
        return praga.nomeComum.toLowerCase().contains(searchText) ||
            (praga.nomeCientifico?.toLowerCase().contains(searchText) ?? false) ||
            (praga.categoria?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    }
    
    // Performance optimization: Sort only if list is not empty
    if (filtered.isNotEmpty) {
      filtered.sort((a, b) {
        final comparison = a.nomeComum.compareTo(b.nomeComum);
        return _state.isAscending ? comparison : -comparison;
      });
    }
    
    _updateState(_state.copyWith(pragasFiltered: filtered));
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

  void _toggleViewMode(PragaViewMode mode) {
    _updateState(_state.copyWith(viewMode: mode));
  }

  void _toggleSort() {
    _updateState(_state.copyWith(isAscending: !_state.isAscending));
    _applyCurrentFilter();
  }

  void _setTabIndex(int index) {
    if (index != _state.tabIndex) {
      _tabController.index = index;
      _updateState(_state.copyWith(tabIndex: index));
      _applyCurrentFilter();
    }
  }

  void _handleItemTap(PragaCulturaItemModel praga) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.displayName,
          pragaScientificName: praga.nomeCientifico ?? 'Nome científico não disponível',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildModernHeader(),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return ModernHeaderWidget(
      title: _state.culturaNome.isNotEmpty
          ? _state.culturaNome
          : 'Pragas por Cultura',
      subtitle: _getHeaderSubtitle(),
      leftIcon: Icons.agriculture_outlined,
      rightIcon: _state.isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: _state.isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          const SizedBox(height: ReceitaAgroSpacing.sm),
          _buildSearchField(),
          const SizedBox(height: ReceitaAgroSpacing.sm),
          Expanded(
            child: _buildScrollableContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return PragaCulturaTabBarWidget(
      tabController: _tabController,
      onTabTap: _setTabIndex,
      isDark: _state.isDark,
    );
  }

  Widget _buildSearchField() {
    return PragaCulturaSearchFieldWidget(
      controller: _searchController,
      isDark: _state.isDark,
      onClear: _clearSearch,
      selectedViewMode: _state.viewMode,
      onToggleViewMode: _toggleViewMode,
      onChanged: (text) {},
      hintText: 'Buscar ${_state.currentTabTitle.toLowerCase()}...',
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildTabView(),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    return Card(
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: _state.isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: EdgeInsets.zero,
      child: _buildTabViewContent(),
    );
  }

  Widget _buildTabViewContent() {
    if (_state.isLoading) {
      return PragaCulturaLoadingSkeletonWidget(
        viewMode: _state.viewMode,
        isDark: _state.isDark,
        itemCount: 12,
      );
    }

    final pragasParaTipo = _state.getPragasPorTipoAtual();

    if (pragasParaTipo.isEmpty) {
      return PragaCulturaEmptyStateWidget(
        tipoPraga: _state.currentTipoPraga,
        culturaNome: _state.culturaNome,
        isDark: _state.isDark,
        hasSearchText: _state.searchText.isNotEmpty,
        searchText: _state.searchText,
      );
    }

    return _state.viewMode.isGrid
        ? _buildGridView(pragasParaTipo)
        : _buildListView(pragasParaTipo);
  }

  Widget _buildGridView(List<PragaCulturaItemModel> pragas) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        // Calcula quantas linhas teremos
        final rowCount = (pragas.length / crossAxisCount).ceil();
        final itemHeight = constraints.maxWidth / crossAxisCount * (1 / 0.85); // childAspectRatio inverse
        final totalHeight = (rowCount * itemHeight) + ((rowCount - 1) * 8) + 16; // spacing + padding
        
        return SizedBox(
          height: totalHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: ReceitaAgroSpacing.sm,
              mainAxisSpacing: ReceitaAgroSpacing.sm,
            ),
            itemCount: pragas.length,
            itemBuilder: (context, index) {
              final praga = pragas[index];
              return PragaCulturaItemWidget(
                praga: praga,
                viewMode: _state.viewMode,
                isDark: _state.isDark,
                onTap: () => _handleItemTap(praga),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(List<PragaCulturaItemModel> pragas) {
    return Column(
      children: [
        const SizedBox(height: ReceitaAgroSpacing.sm),
        ...pragas.map((praga) => Padding(
          padding: const EdgeInsets.only(bottom: ReceitaAgroSpacing.xs),
          child: PragaCulturaItemWidget(
            praga: praga,
            viewMode: _state.viewMode,
            isDark: _state.isDark,
            onTap: () => _handleItemTap(praga),
          ),
        )),
        const SizedBox(height: ReceitaAgroSpacing.sm),
      ],
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }

  String _getHeaderSubtitle() {
    final total = _state.totalRegistros;
    
    if (_state.isLoading && total == 0) {
      return 'Carregando pragas...';
    }
    
    if (total > 0) {
      return '$total pragas identificadas';
    }
    
    return 'Pragas desta cultura';
  }
}