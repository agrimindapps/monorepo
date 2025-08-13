// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../injections.dart';
import '../../../repository/database_repository.dart';
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/generic_search_field_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../config/ui_constants.dart';
import '../controller/lista_defensivos_agrupados_controller.dart';
import '../models/defensivo_item_model.dart';
import '../models/view_mode.dart';
import '../utils/defensivos_category.dart';
import 'components/empty_result_message.dart';
import 'components/loading_indicator.dart';
import 'widgets/defensivos_grid_view.dart';
import 'widgets/defensivos_list_view.dart';

class ListaDefensivosAgrupadosPage
    extends GetView<ListaDefensivosAgrupadosController> {
  final String tipoAgrupamento;
  final String textoFiltro;

  const ListaDefensivosAgrupadosPage({
    super.key,
    required this.tipoAgrupamento,
    required this.textoFiltro,
  });

  @override
  Widget build(BuildContext context) {
    // Configurar contexto e carregar dados ao construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoadData(context);
    });

    _configureStatusBar();

    return PopScope(
      canPop: controller.state.navigationLevel == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && controller.canNavigateBack()) {
          controller.navigateBack();
        }
      },
      child: Scaffold(
        key: GlobalKey<ScaffoldState>(),
        body: _buildBody(),
        bottomNavigationBar: const BottomNavigator(
          overrideIndex: 0, // Defensivos
        ),
      ),
    );
  }

  void _initializeAndLoadData(BuildContext context) {
    try {
      Get.find<DatabaseRepository>();
    } catch (e) {
      ReceituagroBindings().dependencies();
    }

    controller.setContext(context);
    controller.carregaDados(tipoAgrupamento, textoFiltro);
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


  Widget _buildBody() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: UiConstants.maxContainerWidth),
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
    return Obx(() => ModernHeaderWidget(
      title: controller.state.title.isNotEmpty 
          ? controller.state.title 
          : _getDefaultTitle(),
      subtitle: _getSubtitle(),
      leftIcon: _getHeaderIcon(),
      rightIcon: controller.state.isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: controller.state.isDark,
      showBackButton: true,
      showActions: true, // Mostra área de ações
      onBackPressed: () {
        if (controller.canNavigateBack()) {
          controller.navigateBack();
        } else {
          Get.back();
        }
      },
      onRightIconPressed: () {
        // Ação do ícone direito (estatísticas, etc.)
        controller.toggleSort();
      },
    ));
  }

  String _getDefaultTitle() {
    switch (tipoAgrupamento) {
      case 'fabricantes':
        return 'Fabricantes';
      case 'classeAgronomica':
        return 'Classes Agronômicas';
      case 'ingredienteAtivo':
        return 'Ingredientes Ativos';
      case 'modoAcao':
        return 'Modos de Ação';
      default:
        return 'Defensivos';
    }
  }

  String _getSubtitle() {
    final totalItems = controller.state.defensivosList.length;
    
    if (totalItems == 0) {
      return 'Carregando registros...';
    }
    
    if (controller.state.navigationLevel > 0) {
      return '$totalItems Registros';
    }
    
    return '$totalItems Registros';
  }

  IconData _getHeaderIcon() {
    switch (tipoAgrupamento) {
      case 'fabricantes':
        return Icons.business_outlined;
      case 'classeAgronomica':
        return Icons.category_outlined;
      case 'ingredienteAtivo':
        return Icons.science_outlined;
      case 'modoAcao':
        return Icons.settings_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  Widget _buildSearchField() {
    return Obx(() => GenericSearchFieldWidget(
      controller: controller.textController,
      isDark: controller.state.isDark,
      isSearching: controller.state.isSearching,
      selectedViewMode:
          _mapViewModeToSearchViewMode(controller.state.selectedViewMode),
      onToggleViewMode: (SearchViewMode mode) =>
          controller.toggleViewMode(_mapSearchViewModeToViewMode(mode)),
      onClear: controller.clearSearch,
      hintText: 'Buscar...',
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      borderRadius: 16.0,
      viewToggleBuilder: (selectedMode, isDark, onModeChanged) =>
          _buildViewToggleButtons(selectedMode, isDark, onModeChanged),
    ));
  }

  Widget _buildViewToggleButtons(SearchViewMode selectedMode, bool isDark, Function(SearchViewMode) onModeChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton(SearchViewMode.grid, Icons.grid_view_rounded, selectedMode, isDark, onModeChanged),
        _buildToggleButton(SearchViewMode.list, Icons.view_list_rounded, selectedMode, isDark, onModeChanged),
      ],
    );
  }

  Widget _buildToggleButton(SearchViewMode mode, IconData icon, SearchViewMode selectedMode, bool isDark, Function(SearchViewMode) onModeChanged) {
    final bool isSelected = selectedMode == mode;
    final bool isFirstButton = mode == SearchViewMode.grid;
    
    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(mode == SearchViewMode.grid ? 20 : 0),
        right: Radius.circular(mode != SearchViewMode.grid ? 20 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.green.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirstButton ? 20 : 0),
            right: Radius.circular(!isFirstButton ? 20 : 0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }

  SearchViewMode _mapViewModeToSearchViewMode(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.grid:
        return SearchViewMode.grid;
      case ViewMode.list:
        return SearchViewMode.list;
    }
  }

  ViewMode _mapSearchViewModeToViewMode(SearchViewMode searchViewMode) {
    switch (searchViewMode) {
      case SearchViewMode.grid:
        return ViewMode.grid;
      case SearchViewMode.list:
        return ViewMode.list;
    }
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            DefensivosPageConstants.horizontalBodyPadding,
            DefensivosPageConstants.verticalBodyPadding,
            DefensivosPageConstants.horizontalBodyPadding,
            DefensivosPageConstants.bottomBodyPadding),
        child: Obx(() => _buildDefensivosList()),
      ),
    );
  }

  Widget _buildDefensivosList() {
    final context = Get.context!;
    if (controller.state.isLoading &&
        controller.state.defensivosListFiltered.isEmpty) {
      return const LoadingIndicator();
    }

    if (controller.state.defensivosListFiltered.isEmpty) {
      return const EmptyResultMessage();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8.0),
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    final categoria = DefensivosCategory.fromString(controller.state.categoria);

    if (controller.state.selectedViewMode == ViewMode.list) {
      return DefensivosListView(
        defensivos: controller.state.defensivosListFiltered,
        isDark: controller.state.isDark,
        categoria: categoria,
        scrollController: controller.scrollController,
        isLoading: controller.state.isLoading,
        onItemTap: (DefensivoItemModel item) => controller.handleItemTap(item),
      );
    } else {
      return DefensivosGridView(
        defensivos: controller.state.defensivosListFiltered,
        isDark: controller.state.isDark,
        categoria: categoria,
        scrollController: controller.scrollController,
        isLoading: controller.state.isLoading,
        onItemTap: (DefensivoItemModel item) => controller.handleItemTap(item),
      );
    }
  }
}

