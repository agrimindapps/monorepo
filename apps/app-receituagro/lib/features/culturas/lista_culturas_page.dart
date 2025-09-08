import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/cultura_hive.dart';
import '../../core/repositories/cultura_core_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas/lista_pragas_por_cultura_page.dart';
import 'models/cultura_view_mode.dart';
import 'widgets/cultura_item_widget.dart';
import 'widgets/cultura_search_field.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/loading_skeleton_widget.dart';

class ListaCulturasPage extends StatefulWidget {
  const ListaCulturasPage({super.key});

  @override
  State<ListaCulturasPage> createState() => _ListaCulturasPageState();
}

class _ListaCulturasPageState extends State<ListaCulturasPage> {
  final TextEditingController _searchController = TextEditingController();
  final CulturaCoreRepository _repository = sl<CulturaCoreRepository>();

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
        builder: (context) => ListaPragasPorCulturaPage(
          culturaId: cultura.idReg,
          culturaNome: cultura.cultura,
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
                  onBackPressed: () => Navigator.of(context).pop(),
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
    if (_isLoading) {
      return LoadingSkeletonWidget(isDark: isDark);
    } else if (_errorMessage != null) {
      return EmptyStateWidget(
        isDark: isDark,
        message: 'Erro ao carregar culturas',
        subtitle: _errorMessage,
      );
    } else if (_filteredCulturas.isEmpty) {
      return EmptyStateWidget(
        isDark: isDark,
        message: _searchController.text.isNotEmpty
            ? 'Nenhuma cultura encontrada'
            : 'Nenhuma cultura disponível',
        subtitle: _searchController.text.isNotEmpty
            ? 'Tente ajustar os termos da busca'
            : 'Verifique se os dados foram carregados',
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
