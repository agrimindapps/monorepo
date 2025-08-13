// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/generic_search_field_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../favoritos/widgets/no_search_results_widget.dart';
import '../controller/lista_defensivos_controller.dart';
import '../models/defensivo_model.dart';
import '../models/view_mode.dart';
import '../utils/defensivos_constants.dart';
import 'components/empty_state_message.dart';
import 'components/loading_indicator.dart';
import 'widgets/defensivos_grid_view.dart';
import 'widgets/defensivos_list_view.dart';

class ListaDefensivosPage extends GetView<ListaDefensivosController> {
  const ListaDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Agenda o carregamento de dados após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setContext(context);
      controller.loadInitialData();
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DefensivosConstants.pageMaxWidth),
            child: Column(
              children: [
                Obx(() => _buildModernHeader()),
                Expanded(
                  child: Obx(() => _buildBody()),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigator(
        overrideIndex: 0, // Defensivos
      ),
    );
  }

  Widget _buildModernHeader() {
    return ModernHeaderWidget(
      title: controller.state.title,
      subtitle: _getHeaderSubtitle(),
      leftIcon: Icons.shield_outlined,
      rightIcon: controller.state.isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: controller.state.isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Get.back(),
      onRightIconPressed: controller.toggleSort,
    );
  }

  String _getHeaderSubtitle() {
    final total = controller.state.defensivosList.length;
    
    if (controller.state.isLoading && total == 0) {
      return 'Carregando defensivos...';
    }
    
    return '$total defensivos';
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchField(),
        _buildScrollableContent(),
      ],
    );
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
          hintText: 'Localizar',
          padding: const EdgeInsets.all(8),
          borderRadius: 12.0,
          borderColor: Colors.transparent,
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

  Widget _buildScrollableContent() {
    if (controller.state.isLoading &&
        controller.state.defensivosListFiltered.isEmpty) {
      return const Expanded(child: LoadingIndicator());
    }

    if (controller.state.defensivosListFiltered.isEmpty) {
      // Check if there's an active search
      if (controller.state.searchText.isNotEmpty) {
        return Expanded(
          child: NoSearchResultsWidget(
            searchText: controller.state.searchText,
            accentColor: Get.theme.primaryColor,
          ),
        );
      }
      return const Expanded(child: EmptyStateMessage());
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            DefensivosConstants.pageContentPadding,
            0,
            DefensivosConstants.pageContentPadding,
            DefensivosConstants.pageBottomPadding),
        child: Container(
          decoration: BoxDecoration(
            color:
                controller.state.isDark ? const Color(0xFF1E1E22) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            // Removida qualquer sombra/elevação
            boxShadow: const [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(DefensivosConstants.cardPadding),
            child: _buildDefensivosList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefensivosList() {
    if (controller.state.selectedViewMode == ViewMode.list) {
      return DefensivosListView(
        defensivos: controller.state.defensivosListFiltered,
        scrollController: controller.scrollController,
        isLoading: controller.state.isLoading,
        isDark: controller.state.isDark,
        onItemTap: (DefensivoModel defensivo) =>
            controller.handleItemTap(defensivo),
      );
    } else {
      return DefensivosGridView(
        defensivos: controller.state.defensivosListFiltered,
        scrollController: controller.scrollController,
        isLoading: controller.state.isLoading,
        isDark: controller.state.isDark,
        onItemTap: (DefensivoModel defensivo) =>
            controller.handleItemTap(defensivo),
      );
    }
  }
}
