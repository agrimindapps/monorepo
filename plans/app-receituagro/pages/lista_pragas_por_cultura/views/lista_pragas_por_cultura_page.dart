// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../favoritos/widgets/no_search_results_widget.dart';
import '../controller/lista_pragas_por_cultura_controller.dart';
import '../utils/praga_cultura_constants.dart';
import 'components/search_field_widget.dart';
import 'components/tab_bar_widget.dart';
import 'widgets/loading_skeleton_widget.dart';
import 'widgets/praga_grid_view.dart';
import 'widgets/praga_list_view.dart';

class ListaPragasPorCulturaPage extends StatefulWidget {
  const ListaPragasPorCulturaPage({super.key});

  @override
  ListaPragasPorCulturaPageState createState() =>
      ListaPragasPorCulturaPageState();
}

class ListaPragasPorCulturaPageState extends State<ListaPragasPorCulturaPage> {
  late ListaPragasPorCulturaController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
    // Note: _loadInitialData will be called after route arguments are processed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleRouteArguments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeController() {
    _controller = Get.find<ListaPragasPorCulturaController>();
  }

  void _loadInitialData() {
    _controller.loadInitialData();
  }

  void _handleRouteArguments() {
    try {
      // Use route guard to safely get validated arguments
      final navigationArgs = _controller.getOptionalPragasPorCulturaArgs();

      if (navigationArgs != null) {
        // Update controller with validated arguments
        _controller.culturaSelecionada.value = navigationArgs.culturaNome;
        _controller.culturaSelecionadaId.value = navigationArgs.culturaId;

        // Update state
        _controller.updateCulturaInfo(
          navigationArgs.culturaId,
          navigationArgs.culturaNome,
        );

        // If pragas data was pre-loaded, use it
        if (navigationArgs.pragasList != null) {
          // Note: pragasLista is now handled via immutable state, not RxList
          // The data will be loaded via loadInitialData() call below
        }

        // Load data after arguments are processed
        _loadInitialData();
      } else {
        // Fallback for legacy navigation without arguments
        _handleLegacyArguments();
      }
    } catch (e) {
      // Handle navigation argument errors gracefully
      _handleLegacyArguments();
    }
  }

  void _handleLegacyArguments() {
    final args = Get.arguments;

    if (args != null && args is Map) {
      if (args.containsKey('culturaNome')) {
        _controller.culturaSelecionada.value = args['culturaNome'] ?? '';
      }
      if (args.containsKey('culturaId')) {
        _controller.culturaSelecionadaId.value = args['culturaId'] ?? '';
      }

      // Load data after legacy arguments are processed
      if (_controller.culturaSelecionadaId.value.isNotEmpty) {
        _loadInitialData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListaPragasPorCulturaController>(
      id: 'lista_pragas_cultura',
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: PragaCulturaConstants.maxContentWidth),
              child: Column(
                children: [
                  _buildModernHeader(controller),
                  Expanded(
                    child: _buildBody(controller),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigator(
          overrideIndex: 1, // Pragas
        ),
      ),
    );
  }

  Widget _buildModernHeader(ListaPragasPorCulturaController controller) {
    return ModernHeaderWidget(
      title: controller.state.culturaNome.isNotEmpty
          ? controller.state.culturaNome
          : 'Pragas por Cultura',
      subtitle: _getHeaderSubtitle(controller),
      leftIcon: Icons.agriculture_outlined,
      isDark: controller.state.isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () => Get.back(),
    );
  }

  String _getHeaderSubtitle(ListaPragasPorCulturaController controller) {
    final total = controller.state.totalRegistros;

    if (controller.state.isLoading && total == 0) {
      return 'Carregando pragas...';
    }

    if (total > 0) {
      return '$total pragas identificadas';
    }

    return 'Pragas desta cultura';
  }

  Widget _buildBody(ListaPragasPorCulturaController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TabBar fixa
          _buildTabBar(controller),
          // Barra de pesquisa fixa
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildSearchField(controller),
          ),
          // Conteúdo com scroll
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildScrollableContent(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ListaPragasPorCulturaController controller) {
    return TabBarWidget(
      tabController: controller.tabController,
      onTabTap: (index) => controller.setTabIndex(index),
      isDark: controller.state.isDark,
    );
  }

  Widget _buildSearchField(ListaPragasPorCulturaController controller) {
    return SearchFieldWidget(
      controller: controller.searchController,
      isDark: controller.state.isDark,
      onClear: controller.clearSearch,
      selectedViewMode: controller.state.viewMode,
      onToggleViewMode: controller.toggleViewMode,
      onChanged: (text) {
        // Trigger immediate search update for better responsiveness
        controller.onSearchChanged();
      },
      hintText: 'Buscar pragas...',
    );
  }

  Widget _buildScrollableContent(ListaPragasPorCulturaController controller) {
    return SingleChildScrollView(
      child: _buildTabView(controller),
    );
  }

  Widget _buildTabView(ListaPragasPorCulturaController controller) {
    return Card(
      elevation: PragaCulturaConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PragaCulturaConstants.borderRadius),
      ),
      color: controller.state.isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: const EdgeInsets.only(top: 4, left: 0, right: 0),
      child: _buildTabViewContent(controller),
    );
  }

  Widget _buildTabViewContent(ListaPragasPorCulturaController controller) {
    if (controller.state.isLoading) {
      return LoadingSkeleton(
        isGridMode: controller.state.viewMode.isGrid,
        itemCount: PragaCulturaConstants.skeletonItemCount,
        isDark: controller.state.isDark,
      );
    }

    final pragasParaTipo = controller.getPragasPorTipoAtual();

    // Show no search results widget when search is active and no results found
    if (pragasParaTipo.isEmpty && controller.state.searchText.isNotEmpty) {
      return NoSearchResultsWidget(
        searchText: controller.state.searchText,
        accentColor: Theme.of(context).primaryColor,
      );
    }

    return controller.state.viewMode.isGrid
        ? PragaGridView(
            key: ValueKey(
                'grid_${controller.state.tabIndex}_${pragasParaTipo.length}'),
            pragas: pragasParaTipo,
            isDark: controller.state.isDark,
            onItemTap: (praga) => controller.navegarParaDetalhes(praga.idReg),
          )
        : PragaListView(
            key: ValueKey(
                'list_${controller.state.tabIndex}_${pragasParaTipo.length}'),
            pragas: pragasParaTipo,
            isDark: controller.state.isDark,
            onItemTap: (praga) => controller.navegarParaDetalhes(praga.idReg),
          );
  }
}
