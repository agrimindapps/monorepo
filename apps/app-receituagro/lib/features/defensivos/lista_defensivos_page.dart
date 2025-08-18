import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../../core/extensions/fitossanitario_hive_extension.dart';
import '../../core/di/injection_container.dart';
import 'models/view_mode.dart';
import 'widgets/defensivo_search_field.dart';
import 'widgets/defensivo_item_widget.dart';
import 'widgets/defensivos_empty_state_widget.dart';
import 'widgets/defensivos_loading_skeleton_widget.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';

class ListaDefensivosPage extends StatefulWidget {
  const ListaDefensivosPage({super.key});

  @override
  State<ListaDefensivosPage> createState() => _ListaDefensivosPageState();
}

class _ListaDefensivosPageState extends State<ListaDefensivosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FitossanitarioHiveRepository _repository = sl<FitossanitarioHiveRepository>();
  final List<FitossanitarioHive> _allDefensivos = [];
  List<FitossanitarioHive> _filteredDefensivos = [];
  ViewMode _selectedViewMode = ViewMode.list;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isAscending = true;
  Timer? _debounceTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRealData();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRealData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Carrega defensivos ativos e elegíveis do repositório Hive
      final defensivos = _repository.getActiveDefensivos();
      
      if (mounted) {
        setState(() {
          _allDefensivos.clear();
          _allDefensivos.addAll(defensivos);
          _filteredDefensivos = List.from(_allDefensivos);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar defensivos: $e';
        });
      }
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    
    final searchText = _searchController.text;
    
    if (searchText.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredDefensivos = List.from(_allDefensivos);
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(searchText);
    });
  }

  void _performSearch(String searchText) {
    final searchLower = searchText.toLowerCase();
    
    final filtered = _allDefensivos.where((defensivo) {
      return defensivo.displayName.toLowerCase().contains(searchLower) ||
          defensivo.displayIngredient.toLowerCase().contains(searchLower) ||
          defensivo.displayClass.toLowerCase().contains(searchLower) ||
          defensivo.displayFabricante.toLowerCase().contains(searchLower);
    }).toList();

    if (mounted) {
      setState(() {
        _filteredDefensivos = filtered;
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredDefensivos = List.from(_allDefensivos);
      _isSearching = false;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredDefensivos.sort((a, b) {
        return _isAscending
            ? a.displayName.compareTo(b.displayName)
            : b.displayName.compareTo(a.displayName);
      });
    });
  }

  void _toggleViewMode(ViewMode viewMode) {
    setState(() {
      _selectedViewMode = viewMode;
    });
  }

  void _onDefensivoTap(FitossanitarioHive defensivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivo.displayName,
          fabricante: defensivo.displayFabricante,
        ),
      ),
    );
  }

  void _onScroll() {
    // Implementação de scroll infinito se necessário
  }

  String _getHeaderSubtitle() {
    final total = _allDefensivos.length;
    final filtered = _filteredDefensivos.length;

    if (_isLoading && total == 0) {
      return 'Carregando defensivos...';
    }
    
    if (_errorMessage != null) {
      return 'Erro no carregamento';
    }

    if (filtered < total) {
      return '$filtered de $total defensivos';
    }

    return '$total defensivos disponíveis';
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(context, isDark),
            DefensivoSearchField(
              controller: _searchController,
              isDark: isDark,
              isSearching: _isSearching,
              selectedViewMode: _selectedViewMode,
              onToggleViewMode: _toggleViewMode,
              onClear: _clearSearch,
              onSubmitted: () => _performSearch(_searchController.text),
            ),
            Expanded(
              child: _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return DefensivosLoadingSkeletonWidget(
        isDark: isDark,
        viewMode: _selectedViewMode,
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.red.shade400 : Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar defensivos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
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
    } else if (_filteredDefensivos.isEmpty) {
      return DefensivosEmptyStateWidget(
        isDark: isDark,
        isSearchResult: _searchController.text.isNotEmpty,
        message: _searchController.text.isNotEmpty
            ? 'Nenhum defensivo encontrado'
            : 'Nenhum defensivo disponível',
        subtitle: _searchController.text.isNotEmpty
            ? 'Tente ajustar os termos da busca'
            : 'Verifique se os dados foram carregados',
      );
    } else {
      return _buildDefensivosList(isDark);
    }
  }

  Widget _buildDefensivosList(bool isDark) {
    if (_selectedViewMode == ViewMode.grid) {
      final crossAxisCount = MediaQuery.of(context).size.width > 800
          ? 4
          : MediaQuery.of(context).size.width > 600
              ? 3
              : 2;

      return Container(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _filteredDefensivos.length,
          itemBuilder: (context, index) {
            final defensivo = _filteredDefensivos[index];
            return DefensivoItemWidget(
              defensivo: defensivo,
              isDark: isDark,
              onTap: () => _onDefensivoTap(defensivo),
              isGridView: true,
            );
          },
        ),
      );
    } else {
      return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          child: Column(
          children: [
            ..._filteredDefensivos.map((defensivo) => DefensivoItemWidget(
              defensivo: defensivo,
              isDark: isDark,
              onTap: () => _onDefensivoTap(defensivo),
              isGridView: false,
            )),
            const SizedBox(height: 80), // Espaço para bottom navigation
          ],
        ),
      );
    }
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Defensivos',
      subtitle: _getHeaderSubtitle(),
      leftIcon: Icons.shield_outlined,
      showBackButton: true,
      showActions: true,
      isDark: isDark,
      rightIcon: _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha,
      onRightIconPressed: _toggleSort,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }
}