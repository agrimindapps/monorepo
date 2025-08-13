// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../favoritos/widgets/no_search_results_widget.dart';
import '../controller/lista_pragas_controller.dart';
import '../utils/praga_constants.dart';
import 'components/empty_state_widget.dart';
import 'components/loading_indicator_widget.dart';
import 'components/search_field_widget.dart';
import 'widgets/praga_grid_view.dart';
import 'widgets/praga_list_view.dart';

class ListaPragasPage extends StatefulWidget {
  const ListaPragasPage({super.key});

  @override
  ListaPragasPageState createState() => ListaPragasPageState();
}

class ListaPragasPageState extends State<ListaPragasPage> {
  late final ListaPragasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ListaPragasController>();
    _controller.loadInitialData();
    _configureStatusBar();
  }

  @override
  void dispose() {
    // GetX handles controller disposal automatically
    // Manual dispose was causing double disposal
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

  @override
  Widget build(BuildContext context) {
    _controller.ensureDataLoaded();

    return Obx(() => Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: PragaConstants.maxContentWidth),
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
          bottomNavigationBar: const BottomNavigator(
            overrideIndex: 1, // Pragas
          ),
        ));
  }

  Widget _buildModernHeader() {
    return ModernHeaderWidget(
      title: _getHeaderTitle(),
      subtitle: _getHeaderSubtitle(),
      leftIcon: _getHeaderIcon(),
      rightIcon: _controller.state.isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: _controller.state.isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Get.back(),
      onRightIconPressed: _controller.toggleSort,
    );
  }

  String _getHeaderTitle() {
    switch (_controller.state.pragaType) {
      case 'insetos':
        return 'Insetos';
      case 'doenças':
        return 'Doenças';
      case 'plantas-daninhas':
        return 'Plantas Daninhas';
      default:
        return 'Pragas';
    }
  }

  String _getHeaderSubtitle() {
    final total = _controller.state.totalRegistros;
    
    if (_controller.state.isLoading && total == 0) {
      return 'Carregando registros...';
    }
    
    return '$total registros';
  }

  IconData _getHeaderIcon() {
    switch (_controller.state.pragaType) {
      case 'insetos':
        return Icons.bug_report_outlined;
      case 'doenças':
        return Icons.coronavirus_outlined;
      case 'plantas-daninhas':
        return Icons.grass_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchField(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildSearchField() {
    return SearchFieldWidget(
      controller: _controller.searchController,
      pragaType: _controller.state.pragaType,
      isDark: _controller.state.isDark,
      viewMode: _controller.state.viewMode,
      onViewModeChanged: _controller.toggleViewMode,
      onClear: _controller.clearSearch,
      onChanged: (value) {
        // Trigger immediate search update for better responsiveness
        _controller.onSearchChanged();
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
        child: _buildPragasList(),
      ),
    );
  }

  Widget _buildPragasList() {
    if (_controller.state.isLoading) {
      return LoadingIndicatorWidget(
        pragaType: _controller.state.pragaType,
        isDark: _controller.state.isDark,
      );
    }

    if (_controller.state.isEmpty) {
      return EmptyStateWidget(
        pragaType: _controller.state.pragaType,
        isDark: _controller.state.isDark,
      );
    }

    final pragasFiltered = _controller.state.pragasFiltered;

    // Show no search results widget when search is active and no results found
    if (pragasFiltered.isEmpty && _controller.state.searchText.isNotEmpty) {
      return NoSearchResultsWidget(
        searchText: _controller.state.searchText,
        accentColor: Theme.of(context).primaryColor,
      );
    }

    return Card(
      elevation: PragaConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PragaConstants.borderRadius),
      ),
      color: _controller.state.isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: const EdgeInsets.only(top: 4, left: 0, right: 0),
      child: _controller.state.viewMode.isGrid
          ? PragaGridView(
              key: ValueKey('grid_${_controller.state.pragaType}_${pragasFiltered.length}'),
              pragas: pragasFiltered,
              pragaType: _controller.state.pragaType,
              isDark: _controller.state.isDark,
              onItemTap: _controller.handleItemTap,
            )
          : PragaListView(
              key: ValueKey('list_${_controller.state.pragaType}_${pragasFiltered.length}'),
              pragas: pragasFiltered,
              pragaType: _controller.state.pragaType,
              isDark: _controller.state.isDark,
              onItemTap: _controller.handleItemTap,
            ),
    );
  }
}
