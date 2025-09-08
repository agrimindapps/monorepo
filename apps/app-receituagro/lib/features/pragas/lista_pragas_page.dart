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
import 'widgets/praga_search_field_widget.dart';
import 'widgets/pragas_empty_state_widget.dart';
import 'widgets/pragas_loading_skeleton_widget.dart';

class ListaPragasPage extends StatefulWidget {
  final String? pragaType;

  const ListaPragasPage({super.key, this.pragaType});

  @override
  State<ListaPragasPage> createState() => _ListaPragasPageState();
}

class _ListaPragasPageState extends State<ListaPragasPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  
  late TabController _tabController;

  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  String _searchText = '';
  late String _currentPragaType;
  late PragasProvider _pragasProvider;

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);
    
    // Inicializa o TabController
    final initialIndex = _getTabIndexFromType(_currentPragaType);
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_onTabChanged);
    
    // Inicializa o provider diretamente
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

  int _getTabIndexFromType(String pragaType) {
    switch (pragaType) {
      case '1': return 0; // Insetos
      case '2': return 1; // Doenças  
      case '3': return 2; // Plantas Daninhas
      default: return 0;
    }
  }

  String _getTypeFromTabIndex(int index) {
    switch (index) {
      case 0: return '1'; // Insetos
      case 1: return '2'; // Doenças
      case 2: return '3'; // Plantas Daninhas
      default: return '1';
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final newType = _getTypeFromTabIndex(_tabController.index);
      setState(() {
        _currentPragaType = newType;
        _searchText = '';
        _searchController.clear();
      });
      _pragasProvider.loadPragasByTipo(newType);
    }
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
      _pragasProvider.loadPragasByTipo(_currentPragaType);
    } else {
      _pragasProvider.searchPragas(searchText.trim());
    }
  }

  // Métodos de filtragem migrados para PragasProvider

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
    });

    _pragasProvider.loadPragasByTipo(_currentPragaType);
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

    // TODO: Implementar ordenação no PragasProvider
    // Por enquanto recarrega os dados
    if (_searchText.isEmpty) {
      _pragasProvider.loadPragasByTipo(_currentPragaType);
    } else {
      _pragasProvider.searchPragas(_searchText);
    }
  }

  void _handleItemTap(PragaEntity praga) {
    // Usar navegação direta do Flutter - mais confiável para páginas secundárias
    Navigator.of(context).push(
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pragasProvider.loadPragasByTipo(_currentPragaType);
    });
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.zero,
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
      ),
    );
  }

  Widget _buildModernHeader(bool isDark, PragasProvider provider) {
    return ModernHeaderWidget(
      title: _getHeaderTitle(),
      subtitle: _getHeaderSubtitle(provider),
      leftIcon: Icons.pest_control_outlined,
      rightIcon: _isAscending
          ? Icons.arrow_upward_outlined
          : Icons.arrow_downward_outlined,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildBody(bool isDark, PragasProvider provider) {
    return Column(
      children: [
        _buildTabBar(),
        const SizedBox(height: 8),
        _buildSearchField(isDark),
        Expanded(child: _buildContent(isDark, provider)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _buildFavoritesStyleTabs(),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 0, // Hide text in inactive tabs
          fontWeight: FontWeight.w400,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        dividerColor: Colors.transparent,
      ),
    );
  }

  List<Widget> _buildFavoritesStyleTabs() {
    final tabData = [
      {'icon': Icons.bug_report_outlined, 'text': 'Insetos'},
      {'icon': Icons.coronavirus_outlined, 'text': 'Doenças'},
      {'icon': Icons.grass_outlined, 'text': 'Plantas Daninhas'},
    ];

    return tabData.map((data) => Tab(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final isActive = _tabController.index == tabData.indexOf(data);

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data['icon'] as IconData,
                size: 16,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Text(
                  data['text'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    )).toList();
  }

  Widget _buildSearchField(bool isDark) {
    return PragaSearchFieldWidget(
      controller: _searchController,
      pragaType: _currentPragaType,
      isDark: isDark,
      viewMode: _viewMode,
      onViewModeChanged: _toggleViewMode,
      onClear: _clearSearch,
      onChanged: (value) {},
    );
  }

  Widget _buildContent(bool isDark, PragasProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: ReceitaAgroSpacing.sm),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPragasList(isDark, provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPragasList(bool isDark, PragasProvider provider) {
    if (provider.isLoading) {
      return PragasLoadingSkeletonWidget(viewMode: _viewMode, isDark: isDark);
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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

    if (provider.pragas.isEmpty && _searchText.isEmpty) {
      return PragasEmptyStateWidget(
        pragaType: _currentPragaType,
        isDark: isDark,
      );
    }

    if (provider.pragas.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum resultado encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tente usar outros termos de busca',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: EdgeInsets.zero,
      child: _viewMode.isGrid
          ? _buildGridView(isDark, provider)
          : _buildListView(isDark, provider),
    );
  }

  Widget _buildGridView(bool isDark, PragasProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        // Calcula quantas linhas teremos
        final rowCount = (provider.pragas.length / crossAxisCount).ceil();
        final itemHeight = constraints.maxWidth / crossAxisCount * (1 / 0.85); // childAspectRatio inverse
        final totalHeight = (rowCount * itemHeight) + ((rowCount - 1) * ReceitaAgroSpacing.sm) + (ReceitaAgroSpacing.sm * 2); // spacing + vertical padding only
        
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
            itemCount: provider.pragas.length,
            itemBuilder: (context, index) {
              final praga = provider.pragas[index];
              return PragaCardWidget(
                praga: praga,
                mode: PragaCardMode.grid,
                isDarkMode: isDark,
                isFavorite: false, // TODO: Implementar verificação de favoritos
                onTap: () => _handleItemTap(praga),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(bool isDark, PragasProvider provider) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: ReceitaAgroSpacing.xs),
      itemCount: provider.pragas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final praga = provider.pragas[index];
        return PragaCardWidget(
          praga: praga,
          mode: PragaCardMode.list,
          isDarkMode: isDark,
          isFavorite: false, // TODO: Implementar verificação de favoritos
          onTap: () => _handleItemTap(praga),
        );
      },
    );
  }

  String _getHeaderTitle() {
    switch (_currentPragaType) {
      case '1':
        return 'Insetos';
      case '2':
        return 'Doenças';
      case '3':
        return 'Plantas Daninhas';
      default:
        return 'Pragas';
    }
  }

  String _getHeaderSubtitle(PragasProvider provider) {
    final total = provider.pragas.length;

    if (provider.isLoading && total == 0) {
      return 'Carregando registros...';
    }

    if (provider.errorMessage != null) {
      return 'Erro no carregamento';
    }

    return '$total registros disponíveis';
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }

}
