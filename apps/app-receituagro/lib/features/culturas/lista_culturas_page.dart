import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/data/models/cultura_hive.dart';
import '../../core/data/repositories/cultura_hive_repository.dart';
import '../../core/services/receituagro_navigation_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas_por_cultura/pragas_por_cultura_detalhadas_page.dart';
import 'data/cultura_view_mode.dart';
import 'widgets/cultura_item_widget.dart';
import 'widgets/cultura_search_field.dart';
import 'widgets/loading_skeleton_widget.dart';

class ListaCulturasPage extends StatefulWidget {
  const ListaCulturasPage({super.key});

  @override
  State<ListaCulturasPage> createState() => _ListaCulturasPageState();
}

class _ListaCulturasPageState extends State<ListaCulturasPage> {
  final TextEditingController _searchController = TextEditingController();
  final CulturaHiveRepository _repository = sl<CulturaHiveRepository>();

  List<CulturaHive> _culturas = [];
  List<CulturaHive> _filteredCulturas = [];
  bool _isLoading = false;
  bool _isAscending = true;
  CulturaViewMode _viewMode = CulturaViewMode.list;
  Timer? _debounceTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCulturas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCulturas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final culturas = await _repository.getActiveCulturas();
      setState(() {
        _culturas = culturas;
        _filteredCulturas = culturas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar culturas: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    final searchText = _searchController.text;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(searchText.trim());
    });
  }

  void _performSearch(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredCulturas = _culturas;
      } else {
        _filteredCulturas = _culturas.where((cultura) {
          return cultura.cultura
              .toLowerCase()
              .contains(searchText.toLowerCase());
        }).toList();
      }
      _sortCulturas();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredCulturas = _culturas;
      _sortCulturas();
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _sortCulturas();
    });
  }

  void _sortCulturas() {
    _filteredCulturas.sort((a, b) {
      return _isAscending
          ? a.cultura.compareTo(b.cultura)
          : b.cultura.compareTo(a.cultura);
    });
  }

  void _toggleViewMode(CulturaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _onCulturaTap(CulturaHive cultura) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PragasPorCulturaDetalhadasPage(
          culturaIdInicial: cultura.idReg,
        ),
      ),
    );
  }

  String _getHeaderSubtitle() {
    if (_isLoading) {
      return 'Carregando culturas...';
    }

    if (_errorMessage != null) {
      return 'Erro no carregamento';
    }

    return '${_filteredCulturas.length} culturas disponíveis';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                ModernHeaderWidget(
                  title: 'Culturas',
                  subtitle: _getHeaderSubtitle(),
                  leftIcon: Icons.agriculture_outlined,
                  rightIcon: _isAscending
                      ? Icons.arrow_upward_outlined
                      : Icons.arrow_downward_outlined,
                  isDark: isDark,
                  showBackButton: true,
                  showActions: true,
                  onBackPressed: () => GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
                  onRightIconPressed: _toggleSort,
                ),
                CulturaSearchField(
                  controller: _searchController,
                  isDark: isDark,
                  viewMode: _viewMode,
                  onViewModeChanged: _toggleViewMode,
                  isSearching: _isLoading,
                  onClear: _clearSearch,
                  onSubmitted: () => _performSearch(_searchController.text),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Card(
                      elevation: 2,
                      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildContent(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return LoadingSkeletonWidget(isDark: isDark);
    } else if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red[300] : Colors.red[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar culturas',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    } else if (_filteredCulturas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty 
                ? Icons.search_off 
                : Icons.grass_outlined,
              size: 64,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Nenhuma cultura encontrada'
                  : 'Nenhuma cultura disponível',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Tente ajustar os termos da busca'
                  : 'Verifique se os dados foram carregados',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return _viewMode.isGrid ? _buildGridView(isDark) : _buildListView(isDark);
    }
  }

  Widget _buildListView(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredCulturas.length,
      itemBuilder: (context, index) {
        final cultura = _filteredCulturas[index];
        return CulturaItemWidget(
          cultura: cultura,
          isDark: isDark,
          mode: CulturaItemMode.list,
          onTap: () => _onCulturaTap(cultura),
        );
      },
    );
  }

  Widget _buildGridView(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _filteredCulturas.length,
          itemBuilder: (context, index) {
            final cultura = _filteredCulturas[index];
            return CulturaItemWidget(
              cultura: cultura,
              isDark: isDark,
              mode: CulturaItemMode.grid,
              onTap: () => _onCulturaTap(cultura),
            );
          },
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
}
