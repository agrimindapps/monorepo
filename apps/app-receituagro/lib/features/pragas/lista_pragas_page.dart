import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/pragas_hive_extension.dart';
import '../../core/models/pragas_hive.dart';
import '../../core/repositories/pragas_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'detalhe_praga_page.dart';
import 'models/praga_view_mode.dart';
import 'widgets/praga_item_widget.dart';
import 'widgets/praga_search_field_widget.dart';
import 'widgets/pragas_empty_state_widget.dart';
import 'widgets/pragas_loading_skeleton_widget.dart';

class ListaPragasPage extends StatefulWidget {
  final String? pragaType;

  const ListaPragasPage({
    super.key,
    this.pragaType,
  });

  @override
  State<ListaPragasPage> createState() => _ListaPragasPageState();
}

class _ListaPragasPageState extends State<ListaPragasPage> {
  final TextEditingController _searchController = TextEditingController();
  final PragasHiveRepository _repository = sl<PragasHiveRepository>();
  Timer? _searchDebounceTimer;
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  
  final List<PragasHive> _pragas = [];
  List<PragasHive> _pragasFiltered = [];
  String _searchText = '';
  String? _errorMessage;
  late String _currentPragaType;

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);
    _loadRealData();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRealData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Carrega pragas do repositório Hive filtradas por tipo
      final pragas = _repository.findByTipo(_currentPragaType);
      
      if (mounted) {
        setState(() {
          _pragas.clear();
          _pragas.addAll(pragas);
          _pragasFiltered = _sortPragas(List.from(_pragas));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar pragas: $e';
        });
      }
    }
  }


  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    
    final searchText = _searchController.text;
    
    setState(() {
      _searchText = searchText;
      _isSearching = searchText.isNotEmpty;
    });

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) {
    setState(() {
      _pragasFiltered = _filterPragas(_pragas, searchText);
      _isSearching = false;
    });
  }

  List<PragasHive> _filterPragas(List<PragasHive> pragas, String searchText) {
    if (searchText.isEmpty) {
      return _sortPragas(List.from(pragas));
    }
    
    final query = searchText.toLowerCase();
    final filtered = pragas.where((praga) {
      return praga.nomeComum.toLowerCase().contains(query) ||
          praga.nomeCientifico.toLowerCase().contains(query);
    }).toList();
    
    return _sortPragas(filtered);
  }

  List<PragasHive> _sortPragas(List<PragasHive> pragas) {
    pragas.sort((a, b) {
      final comparison = a.nomeComum.compareTo(b.nomeComum);
      return _isAscending ? comparison : -comparison;
    });
    return pragas;
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchText = '';
      _isSearching = false;
      _pragasFiltered = _sortPragas(List.from(_pragas));
    });
  }

  void _toggleViewMode(PragaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _pragasFiltered = _sortPragas(List.from(_pragasFiltered));
    });
  }

  void _handleItemTap(PragasHive praga) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.displayName,
          pragaScientificName: praga.nomeCientifico.isNotEmpty ? praga.nomeCientifico : 'Nome científico não disponível',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(isDark),
                Expanded(
                  child: _buildBody(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return ModernHeaderWidget(
      title: _getHeaderTitle(),
      subtitle: _getHeaderSubtitle(),
      leftIcon: _getHeaderIcon(),
      rightIcon: _isAscending 
          ? Icons.arrow_upward_outlined 
          : Icons.arrow_downward_outlined,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildBody(bool isDark) {
    return Column(
      children: [
        _buildSearchField(isDark),
        Expanded(
          child: _buildContent(isDark),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return PragaSearchFieldWidget(
      controller: _searchController,
      pragaType: _currentPragaType,
      isDark: isDark,
      viewMode: _viewMode,
      onViewModeChanged: _toggleViewMode,
      onClear: _clearSearch,
      onChanged: (value) {},
    );
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
        child: _buildPragasList(isDark),
      ),
    );
  }

  Widget _buildPragasList(bool isDark) {
    if (_isLoading) {
      return PragasLoadingSkeletonWidget(
        viewMode: _viewMode,
        isDark: isDark,
      );
    }
    
    if (_errorMessage != null) {
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
                'Erro ao carregar pragas',
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
    }

    if (_pragasFiltered.isEmpty && _searchText.isEmpty) {
      return PragasEmptyStateWidget(
        pragaType: _currentPragaType,
        isDark: isDark,
      );
    }

    if (_pragasFiltered.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum resultado encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tente usar outros termos de busca',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: const EdgeInsets.only(top: 4),
      child: _viewMode.isGrid
          ? _buildGridView(isDark)
          : _buildListView(isDark),
    );
  }

  Widget _buildGridView(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _pragasFiltered.length,
          itemBuilder: (context, index) {
            final praga = _pragasFiltered[index];
            return PragaItemWidget(
              praga: praga,
              viewMode: _viewMode,
              isDark: isDark,
              onTap: () => _handleItemTap(praga),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: _pragasFiltered.length,
      itemBuilder: (context, index) {
        final praga = _pragasFiltered[index];
        return PragaItemWidget(
          praga: praga,
          viewMode: _viewMode,
          isDark: isDark,
          onTap: () => _handleItemTap(praga),
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

  String _getHeaderTitle() {
    switch (_currentPragaType) {
      case '1':
        return 'Insetos';
      case '2':
        return 'Doenças';
      case '3':
        return 'Plantas Daninhas';
      default:
        return 'Pragas';
    }
  }

  String _getHeaderSubtitle() {
    final total = _pragasFiltered.length;
    
    if (_isLoading && total == 0) {
      return 'Carregando registros...';
    }
    
    if (_errorMessage != null) {
      return 'Erro no carregamento';
    }
    
    return '$total registros disponíveis';
  }

  IconData _getHeaderIcon() {
    switch (_currentPragaType) {
      case '1':
        return Icons.bug_report_outlined;
      case '2':
        return Icons.coronavirus_outlined;
      case '3':
        return Icons.grass_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }
}