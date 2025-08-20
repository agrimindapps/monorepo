// Flutter imports:
import 'package:flutter/material.dart' hide SearchBar;

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../../../../widgets/page_header_widget.dart';
import '../responsive/responsive_breakpoints.dart';
import '../responsive/responsive_layouts.dart';
import '../services/filter_service.dart';
import '../widgets/error_state.dart';
import '../widgets/filter_widgets.dart' as filter_widgets;
import '../widgets/performance_optimized_list.dart';

class PluviometrosView extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Pluviometro> pluviometros;
  final VoidCallback onRefresh;
  final Function(String action, Pluviometro pluviometro) onMenuAction;
  final Function(Pluviometro pluviometro) onTap;
  final VoidCallback onAddNew;

  const PluviometrosView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.pluviometros,
    required this.onRefresh,
    required this.onMenuAction,
    required this.onTap,
    required this.onAddNew,
  });

  @override
  State<PluviometrosView> createState() => _PluviometrosViewState();
}

class _PluviometrosViewState extends State<PluviometrosView> {
  late FilterService _filterService;
  ListDensity _listDensity = ListDensity.comfortable;
  int _currentPage = 1;
  int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _filterService = FilterService();
  }

  @override
  void dispose() {
    _filterService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: 'Pluviômetros',
                subtitle: 'Gestão de Pluviômetros',
                icon: Icons.water_drop_outlined,
                showBackButton: true,
              ),
            ),
            Expanded(
              child: widget.isLoading && widget.pluviometros.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : widget.errorMessage != null && widget.pluviometros.isEmpty
                      ? ErrorStateWidget(
                          errorMessage: widget.errorMessage,
                          onRetry: widget.onRefresh,
                        )
                      : ChangeNotifierProvider<FilterService>.value(
                          value: _filterService,
                          child: Consumer<FilterService>(
                            builder: (context, filterService, child) {
                              final filteredPluviometros = filterService
                                  .applyFiltersAndSort(widget.pluviometros);
                              final totalPages =
                                  (filteredPluviometros.length / _itemsPerPage)
                                      .ceil();
                              final startIndex =
                                  (_currentPage - 1) * _itemsPerPage;
                              final endIndex = (startIndex + _itemsPerPage)
                                  .clamp(0, filteredPluviometros.length);
                              final paginatedPluviometros = filteredPluviometros
                                  .sublist(startIndex, endIndex);

                              return ResponsivePluviometrosLayout(
                                header: _buildHeader(
                                    context,
                                    filteredPluviometros.length,
                                    paginatedPluviometros.length),
                                filters: _buildFilters(filterService),
                                content: _buildContent(paginatedPluviometros),
                                bottomBar: totalPages > 1
                                    ? _buildPagination(
                                        totalPages, filteredPluviometros.length)
                                    : null,
                                floatingActionButton: FloatingActionButton(
                                  onPressed: widget.onAddNew,
                                  child: const Icon(Icons.add),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, int totalFiltered, int currentPageItems) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return Column(
          children: [
            // Título e estatísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ResponsiveText(
                  'Pluviômetros',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  mobileFontSize: 18,
                  tabletFontSize: 20,
                  desktopFontSize: 24,
                ),
                if (!info.isMobile)
                  ResponsiveText(
                    'Exibindo $currentPageItems de $totalFiltered itens',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),

            // Estatísticas em mobile
            if (info.isMobile) ...[
              const SizedBox(height: 8),
              ResponsiveText(
                'Exibindo $currentPageItems de $totalFiltered itens',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilters(FilterService filterService) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de busca
            filter_widgets.SearchBar(
              initialQuery: filterService.filterSet.searchQuery,
              onQueryChanged: filterService.updateSearchQuery,
            ),

            const SizedBox(height: 16),

            // Filtros ativos
            filter_widgets.ActiveFiltersChips(
              filterSet: filterService.filterSet,
              onRemoveFilter: filterService.removeFilter,
              onClearAll: filterService.clearAllFilters,
            ),

            // Controles de densidade (apenas em desktop/tablet)
            if (!info.isMobile) ...[
              const SizedBox(height: 16),
              ListDensityControl(
                density: _listDensity,
                onDensityChanged: (density) {
                  setState(() {
                    _listDensity = density;
                  });
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildContent(List<Pluviometro> paginatedPluviometros) {
    return PerformanceOptimizedList(
      pluviometros: paginatedPluviometros,
      onMenuAction: widget.onMenuAction,
      onRefresh: widget.onRefresh,
      isLoading: widget.isLoading,
      errorMessage: widget.errorMessage,
      itemHeight: _listDensity.itemHeight,
      padding: _listDensity.padding,
    );
  }

  Widget _buildPagination(int totalPages, int totalItems) {
    return PaginationWidget(
      currentPage: _currentPage,
      totalPages: totalPages,
      itemsPerPage: _itemsPerPage,
      totalItems: totalItems,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      onItemsPerPageChanged: (items) {
        setState(() {
          _itemsPerPage = items;
          _currentPage = 1;
        });
      },
    );
  }
}
