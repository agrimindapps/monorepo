import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/design/design_tokens.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'detalhe_praga_page.dart';
import 'domain/entities/praga_entity.dart';
import 'models/praga_view_mode.dart';
import 'presentation/providers/pragas_provider.dart';
import 'widgets/praga_card_widget.dart';
import 'widgets/praga_cultura_empty_state_widget.dart';
import 'widgets/praga_cultura_loading_skeleton_widget.dart';
import 'widgets/praga_cultura_search_field_widget.dart';
import '../../core/widgets/standard_tab_bar_widget.dart';

class ListaPragasPorCulturaPageFixed extends StatefulWidget {
  final String? culturaId;
  final String? culturaNome;

  const ListaPragasPorCulturaPageFixed({
    super.key,
    this.culturaId,
    this.culturaNome,
  });

  @override
  State<ListaPragasPorCulturaPageFixed> createState() => _ListaPragasPorCulturaPageFixedState();
}

class _ListaPragasPorCulturaPageFixedState extends State<ListaPragasPorCulturaPageFixed>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  
  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  String _searchText = '';
  int _tabIndex = 0;
  late PragasProvider _pragasProvider;

  // Tab configuration
  static const List<String> tabTitles = ['Plantas', 'Doenças', 'Insetos'];
  static const List<String> tipoPragaValues = ['3', '2', '1'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    
    // Initialize provider
    _pragasProvider = GetIt.instance<PragasProvider>();
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

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    setState(() {
      _tabIndex = _tabController.index;
    });
    
    _loadPragasForCurrentTab();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    
    final searchText = _searchController.text;
    
    setState(() {
      _searchText = searchText;
    });

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) {
    if (searchText.trim().isEmpty) {
      _loadPragasForCurrentTab();
    } else {
      _pragasProvider.searchPragas(searchText.trim());
    }
  }

  void _loadPragasForCurrentTab() {
    final currentTipo = tipoPragaValues[_tabIndex];
    
    if (widget.culturaId != null && widget.culturaId!.isNotEmpty) {
      // Se houver culturaId, carregue por cultura (quando implementado)
      // Por enquanto, carrega por tipo e filtra depois
      _pragasProvider.loadPragasByTipo(currentTipo);
    } else {
      _pragasProvider.loadPragasByTipo(currentTipo);
    }
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    
    setState(() {
      _searchText = '';
    });
    
    _loadPragasForCurrentTab();
  }

  void _toggleViewMode(PragaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });
    
    // Recarrega dados com nova ordenação
    _loadPragasForCurrentTab();
  }

  void _setTabIndex(int index) {
    if (index != _tabIndex) {
      _tabController.index = index;
      setState(() {
        _tabIndex = index;
      });
      _loadPragasForCurrentTab();
    }
  }

  void _handleItemTap(PragaEntity praga) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.nomeComum,
          pragaScientificName: praga.nomeCientifico.isNotEmpty
              ? praga.nomeCientifico
              : 'Nome científico não disponível',
        ),
      ),
    );
  }

  List<PragaEntity> _getFilteredPragasForCurrentTab() {
    final currentTipo = tipoPragaValues[_tabIndex];
    return _pragasProvider.pragas.where((praga) => praga.tipoPraga == currentTipo).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPragasForCurrentTab();
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pragasProvider,
                    builder: (context, child) {
                      return _buildModernHeader(isDark, _pragasProvider);
                    },
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _pragasProvider,
                      builder: (context, child) {
                        return _buildBody(isDark, _pragasProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark, PragasProvider provider) {
    return ModernHeaderWidget(
      title: widget.culturaNome?.isNotEmpty == true
          ? widget.culturaNome!
          : 'Pragas por Cultura',
      subtitle: _getHeaderSubtitle(provider),
      leftIcon: Icons.agriculture_outlined,
      rightIcon: _isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildBody(bool isDark, PragasProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(isDark),
          const SizedBox(height: ReceitaAgroSpacing.sm),
          _buildSearchField(isDark),
          const SizedBox(height: ReceitaAgroSpacing.sm),
          Expanded(
            child: _buildScrollableContent(isDark, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return StandardTabBarWidget(
      tabController: _tabController,
      tabs: StandardTabData.pragaCultureTabs,
      onTabTap: () => _setTabIndex(_tabController.index),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return PragaCulturaSearchFieldWidget(
      controller: _searchController,
      isDark: isDark,
      onClear: _clearSearch,
      selectedViewMode: _viewMode,
      onToggleViewMode: _toggleViewMode,
      onChanged: (text) {},
      hintText: 'Buscar ${tabTitles[_tabIndex].toLowerCase()}...',
    );
  }

  Widget _buildScrollableContent(bool isDark, PragasProvider provider) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildTabView(isDark, provider),
        ),
      ],
    );
  }

  Widget _buildTabView(bool isDark, PragasProvider provider) {
    return Card(
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: EdgeInsets.zero,
      child: _buildTabViewContent(isDark, provider),
    );
  }

  Widget _buildTabViewContent(bool isDark, PragasProvider provider) {
    if (provider.isLoading) {
      return PragaCulturaLoadingSkeletonWidget(
        viewMode: _viewMode,
        isDark: isDark,
        itemCount: 12,
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.red.shade400 : Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar pragas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentTypeFilter = tipoPragaValues[_tabIndex];
    final pragasForCurrentTab = _getFilteredPragasForCurrentTab();

    if (pragasForCurrentTab.isEmpty) {
      return PragaCulturaEmptyStateWidget(
        tipoPraga: currentTypeFilter,
        culturaNome: widget.culturaNome ?? 'Cultura Desconhecida',
        isDark: isDark,
        hasSearchText: _searchText.isNotEmpty,
        searchText: _searchText,
      );
    }

    return _viewMode.isGrid
        ? _buildGridView(isDark, pragasForCurrentTab)
        : _buildListView(isDark, pragasForCurrentTab);
  }

  Widget _buildGridView(bool isDark, List<PragaEntity> pragas) {
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
            padding: const EdgeInsets.symmetric(vertical: ReceitaAgroSpacing.sm),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: ReceitaAgroSpacing.sm,
              mainAxisSpacing: ReceitaAgroSpacing.sm,
            ),
            itemCount: pragas.length,
            itemBuilder: (context, index) {
              final praga = pragas[index];
              return PragaCardWidget(
                praga: praga,
                mode: PragaCardMode.grid,
                isDarkMode: isDark,
                isFavorite: false,
                onTap: () => _handleItemTap(praga),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(bool isDark, List<PragaEntity> pragas) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: ReceitaAgroSpacing.xs),
      itemCount: pragas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final praga = pragas[index];
        return PragaCardWidget(
          praga: praga,
          mode: PragaCardMode.list,
          isDarkMode: isDark,
          isFavorite: false,
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

  String _getHeaderSubtitle(PragasProvider provider) {
    final currentTypeFilter = tipoPragaValues[_tabIndex];
    final total = _getFilteredPragasForCurrentTab().length;
    
    if (provider.isLoading && total == 0) {
      return 'Carregando pragas...';
    }
    
    if (provider.errorMessage != null) {
      return 'Erro no carregamento';
    }
    
    if (total > 0) {
      return '$total pragas identificadas';
    }
    
    return 'Pragas desta cultura';
  }
}