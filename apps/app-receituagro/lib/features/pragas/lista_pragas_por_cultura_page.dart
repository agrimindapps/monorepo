import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import 'models/praga_cultura_item_model.dart';
import 'models/lista_pragas_cultura_state.dart';
import 'models/praga_view_mode.dart';
import 'widgets/praga_cultura_search_field_widget.dart';
import 'widgets/praga_cultura_tab_bar_widget.dart';
import 'widgets/praga_cultura_item_widget.dart';
import 'widgets/praga_cultura_loading_skeleton_widget.dart';
import 'widgets/praga_cultura_empty_state_widget.dart';

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
  Timer? _searchDebounceTimer;
  
  ListaPragasCulturaState _state = const ListaPragasCulturaState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _initializeState();
    _loadInitialData();
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
    _updateState(_state.copyWith(isLoading: true));
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockData = _generateMockData();
    
    _updateState(_state.copyWith(
      pragasList: mockData,
      pragasFiltered: mockData,
      isLoading: false,
    ));
    
    _applyCurrentFilter();
  }

  List<PragaCulturaItemModel> _generateMockData() {
    return [
      // Insetos (tipoPraga: '1')
      const PragaCulturaItemModel(
        idReg: '1',
        nomeComum: 'Lagarta do Cartucho',
        nomeCientifico: 'Spodoptera frugiperda',
        tipoPraga: '1',
        categoria: 'Lepidoptera',
        grupo: 'Desfolhadores',
      ),
      const PragaCulturaItemModel(
        idReg: '2',
        nomeComum: 'Percevejo da Soja',
        nomeCientifico: 'Nezara viridula',
        tipoPraga: '1',
        categoria: 'Hemiptera',
        grupo: 'Sugadores',
      ),
      const PragaCulturaItemModel(
        idReg: '3',
        nomeComum: 'Broca do Colmo',
        nomeCientifico: 'Diatraea saccharalis',
        tipoPraga: '1',
        categoria: 'Lepidoptera',
        grupo: 'Brocadores',
      ),
      const PragaCulturaItemModel(
        idReg: '4',
        nomeComum: 'Mosca Branca',
        nomeCientifico: 'Bemisia tabaci',
        tipoPraga: '1',
        categoria: 'Hemiptera',
        grupo: 'Sugadores',
      ),
      // Doenças (tipoPraga: '2')
      const PragaCulturaItemModel(
        idReg: '5',
        nomeComum: 'Ferrugem da Soja',
        nomeCientifico: 'Phakopsora pachyrhizi',
        tipoPraga: '2',
        categoria: 'Fúngica',
        grupo: 'Foliar',
      ),
      const PragaCulturaItemModel(
        idReg: '6',
        nomeComum: 'Mancha Parda',
        nomeCientifico: 'Septoria glycines',
        tipoPraga: '2',
        categoria: 'Fúngica',
        grupo: 'Foliar',
      ),
      const PragaCulturaItemModel(
        idReg: '7',
        nomeComum: 'Antracnose',
        nomeCientifico: 'Colletotrichum truncatum',
        tipoPraga: '2',
        categoria: 'Fúngica',
        grupo: 'Vagem',
      ),
      const PragaCulturaItemModel(
        idReg: '8',
        nomeComum: 'Oídio',
        nomeCientifico: 'Microsphaera diffusa',
        tipoPraga: '2',
        categoria: 'Fúngica',
        grupo: 'Foliar',
      ),
      // Plantas Daninhas (tipoPraga: '3')
      const PragaCulturaItemModel(
        idReg: '9',
        nomeComum: 'Capim Amargoso',
        nomeCientifico: 'Digitaria insularis',
        tipoPraga: '3',
        categoria: 'Gramínea',
        grupo: 'Folha Estreita',
      ),
      const PragaCulturaItemModel(
        idReg: '10',
        nomeComum: 'Buva',
        nomeCientifico: 'Conyza bonariensis',
        tipoPraga: '3',
        categoria: 'Eudicotiledônea',
        grupo: 'Folha Larga',
      ),
      const PragaCulturaItemModel(
        idReg: '11',
        nomeComum: 'Caruru',
        nomeCientifico: 'Amaranthus retroflexus',
        tipoPraga: '3',
        categoria: 'Eudicotiledônea',
        grupo: 'Folha Larga',
      ),
      const PragaCulturaItemModel(
        idReg: '12',
        nomeComum: 'Tiririca',
        nomeCientifico: 'Cyperus rotundus',
        tipoPraga: '3',
        categoria: 'Ciperaceae',
        grupo: 'Folha Estreita',
      ),
    ];
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
    final searchText = _state.searchText.toLowerCase();
    final currentTipoPraga = _state.currentTipoPraga;
    
    List<PragaCulturaItemModel> filtered = _state.pragasList;
    
    // Filter by tab (tipo de praga)
    filtered = filtered.where((praga) => praga.tipoPraga == currentTipoPraga).toList();
    
    // Filter by search text
    if (searchText.isNotEmpty) {
      filtered = filtered.where((praga) {
        return praga.nomeComum.toLowerCase().contains(searchText) ||
            (praga.nomeCientifico?.toLowerCase().contains(searchText) ?? false) ||
            (praga.categoria?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    }
    
    // Sort by name
    filtered.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
    
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

  void _setTabIndex(int index) {
    if (index != _state.tabIndex) {
      _tabController.index = index;
      _updateState(_state.copyWith(tabIndex: index));
      _applyCurrentFilter();
    }
  }

  void _handleItemTap(PragaCulturaItemModel praga) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${praga.displayType} selecionada: ${praga.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
    );
  }

  Widget _buildModernHeader() {
    return ModernHeaderWidget(
      title: _state.culturaNome.isNotEmpty
          ? _state.culturaNome
          : 'Pragas por Cultura',
      subtitle: _getHeaderSubtitle(),
      leftIcon: Icons.agriculture_outlined,
      isDark: _state.isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildSearchField(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildScrollableContent(),
            ),
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
    return SingleChildScrollView(
      child: _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _state.isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: const EdgeInsets.only(top: 4),
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
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
        );
      },
    );
  }

  Widget _buildListView(List<PragaCulturaItemModel> pragas) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
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