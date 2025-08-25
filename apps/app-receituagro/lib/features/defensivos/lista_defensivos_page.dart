import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/fitossanitario_hive_extension.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import 'models/view_mode.dart';
import 'widgets/defensivo_item_widget.dart';
import 'widgets/defensivo_search_field.dart';
import 'widgets/defensivos_empty_state_widget.dart';
import 'widgets/defensivos_loading_skeleton_widget.dart';

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
  List<FitossanitarioHive> _displayedDefensivos = []; // Para lazy loading
  ViewMode _selectedViewMode = ViewMode.list;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isAscending = true;
  bool _isLoadingMore = false; // Para controlar carregamento paginado
  Timer? _debounceTimer;
  String? _errorMessage;
  
  // Configurações de paginação
  static const int _itemsPerPage = 50;
  int _currentPage = 0;

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
          // Ordena alfabeticamente por nome
          _allDefensivos.sort((a, b) => a.displayName.compareTo(b.displayName));
          _filteredDefensivos = List.from(_allDefensivos);
          _currentPage = 0;
          _loadPage(); // Carrega primeira página
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
        _currentPage = 0;
        _loadPage();
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
        // Ordena resultados filtrados alfabeticamente
        filtered.sort((a, b) => a.displayName.compareTo(b.displayName));
        _filteredDefensivos = filtered;
        _isSearching = false;
        _currentPage = 0;
        _loadPage(); // Recarrega primeira página com resultados filtrados
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
      MaterialPageRoute<void>(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivo.displayName,
          fabricante: defensivo.displayFabricante,
        ),
      ),
    );
  }

  void _onScroll() {
    // Lazy loading: carrega mais itens quando próximo do fim
    if (_scrollController.hasClients) {
      final threshold = _scrollController.position.maxScrollExtent * 0.8;
      if (_scrollController.position.pixels >= threshold && 
          !_isLoadingMore && 
          _displayedDefensivos.length < _filteredDefensivos.length) {
        _loadMoreItems();
      }
    }
  }
  
  void _loadPage() {
    const startIndex = 0;
    final endIndex = (_itemsPerPage).clamp(0, _filteredDefensivos.length);
    _displayedDefensivos = _filteredDefensivos.sublist(startIndex, endIndex);
    _currentPage = 0;
  }
  
  void _loadMoreItems() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simula delay para UX suave
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    final nextPage = _currentPage + 1;
    final startIndex = nextPage * _itemsPerPage;
    final endIndex = ((nextPage + 1) * _itemsPerPage).clamp(0, _filteredDefensivos.length);
    
    if (startIndex < _filteredDefensivos.length) {
      final newItems = _filteredDefensivos.sublist(startIndex, endIndex);
      setState(() {
        _displayedDefensivos.addAll(newItems);
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
    } else if (_displayedDefensivos.isEmpty) {
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
          itemCount: _displayedDefensivos.length,
          itemBuilder: (context, index) {
            final defensivo = _displayedDefensivos[index];
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
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _displayedDefensivos.length + (_isLoadingMore ? 2 : 1), // +1 para espaço, +1 para loading
        itemBuilder: (context, index) {
          // Loading indicator no meio da lista
          if (_isLoadingMore && index == _displayedDefensivos.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Último item: espaço para bottom navigation
          if (index == _displayedDefensivos.length + (_isLoadingMore ? 1 : 0)) {
            return const SizedBox(height: 80);
          }
          
          // Items da lista virtualizados
          final defensivo = _displayedDefensivos[index];
          return DefensivoItemWidget(
            defensivo: defensivo,
            isDark: isDark,
            onTap: () => _onDefensivoTap(defensivo),
            isGridView: false,
          );
        },
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