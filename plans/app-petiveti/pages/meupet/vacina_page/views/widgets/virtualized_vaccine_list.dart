// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/16_vacina_model.dart';
import '../../controllers/vacina_page_controller.dart';
import '../../models/paginated_vaccine_model.dart';
import '../styles/vacina_colors.dart';
import '../styles/vacina_constants.dart';

/// A virtualized list widget optimized for displaying large numbers of vaccines.
/// 
/// This widget implements:
/// - Infinite scrolling with automatic loading
/// - Pull-to-refresh functionality
/// - Optimized rendering for performance
/// - Loading states and error handling
/// - Debounced scroll detection
/// 
/// The widget automatically loads more data when the user scrolls near the bottom
/// and provides visual feedback during loading operations.
class VirtualizedVaccineList extends StatefulWidget {
  final PaginatedVaccineModel paginatedData;
  final Widget Function(BuildContext context, VacinaVet vaccine, int index) itemBuilder;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final PaginationConfig config;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;

  const VirtualizedVaccineList({
    super.key,
    required this.paginatedData,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.config = const PaginationConfig(),
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
  });

  @override
  State<VirtualizedVaccineList> createState() => _VirtualizedVaccineListState();
}

class _VirtualizedVaccineListState extends State<VirtualizedVaccineList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events to trigger infinite loading.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final scrollPercentage = _scrollController.position.pixels / 
        _scrollController.position.maxScrollExtent;
    
    // Trigger load more when scrolled past threshold
    if (scrollPercentage >= widget.config.scrollThreshold &&
        !_isLoadingMore &&
        widget.paginatedData.hasNextPage &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  /// Triggers loading of more data with debouncing.
  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Handles pull-to-refresh functionality.
  Future<void> _onRefresh() async {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle error state
    if (widget.paginatedData.errorMessage != null) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    // Handle empty state
    if (!widget.paginatedData.hasItems && !widget.paginatedData.isLoading) {
      return widget.emptyWidget ?? _buildDefaultEmptyWidget();
    }

    // Handle initial loading state
    if (widget.paginatedData.isLoading && !widget.paginatedData.hasItems) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    // Build the main list
    return RefreshIndicator(
      onRefresh: widget.config.enablePullToRefresh ? _onRefresh : () async {},
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _getItemCount(),
        itemBuilder: (context, index) {
          // Handle regular vaccine items
          if (index < widget.paginatedData.items.length) {
            final vaccine = widget.paginatedData.items[index];
            return widget.itemBuilder(context, vaccine, index);
          }
          
          // Handle loading indicator at the bottom
          if (index == widget.paginatedData.items.length) {
            return _buildLoadingIndicator();
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Calculates the total number of items including loading indicator.
  int _getItemCount() {
    int count = widget.paginatedData.items.length;
    
    // Add loading indicator if loading more or has next page
    if ((_isLoadingMore || widget.paginatedData.hasNextPage) && 
        widget.config.enableInfiniteScroll) {
      count += 1;
    }
    
    return count;
  }

  /// Builds the loading indicator for infinite scroll.
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: VacinaConstants.espacamentoPadrao),
          Text(
            'Carregando mais vacinas...',
            style: TextStyle(
              color: VacinaColors.cinza(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the default error widget.
  Widget _buildDefaultErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: VacinaConstants.tamanhoIconeStatus,
              color: VacinaColors.erro(context),
            ),
            const SizedBox(height: VacinaConstants.espacamentoPadrao),
            Text(
              widget.paginatedData.errorMessage ?? 'Erro ao carregar vacinas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: VacinaColors.erroTexto(context),
              ),
            ),
            const SizedBox(height: VacinaConstants.espacamentoPadrao * 2),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the default empty state widget.
  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: VacinaConstants.tamanhoIconeStatus,
              color: VacinaColors.cinza(context),
            ),
            const SizedBox(height: VacinaConstants.espacamentoPadrao),
            Text(
              'Nenhuma vacina encontrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: VacinaColors.cinza(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the default loading widget.
  Widget _buildDefaultLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Extension to add virtualization capabilities to VacinaPageController.
extension VirtualizedVaccineController on VacinaPageController {
  /// Loads the next page of vaccines for infinite scrolling.
  Future<void> loadNextPage() async {
    // Implementation would depend on repository pagination support
    // For now, this is a placeholder that would need backend support
    try {
      // Example implementation:
      // final nextPage = currentPage + 1;
      // final newVaccines = await repository.getVaccinasPaginated(
      //   animalId: selectedAnimalId,
      //   page: nextPage,
      //   pageSize: paginationConfig.defaultPageSize,
      // );
      // appendVaccinesToList(newVaccines);
    } catch (e) {
      debugPrint('Error loading next page: $e');
      rethrow;
    }
  }

  /// Refreshes the vaccine list from the beginning.
  Future<void> refreshVaccines() async {
    // Reset pagination and reload from first page
    await loadVacinas();
  }
}
