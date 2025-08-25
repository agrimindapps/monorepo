import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/cultura_hive.dart';
import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas/lista_pragas_por_cultura_page.dart';
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
  final CulturaHiveRepository _repository = sl<CulturaHiveRepository>();
  final List<CulturaHive> _allCulturas = [];
  List<CulturaHive> _filteredCulturas = [];
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRealData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Carrega culturas do repositório Hive
      final culturas = _repository.getAll();
      
      if (mounted) {
        setState(() {
          _allCulturas.clear();
          _allCulturas.addAll(culturas);
          // Ordena alfabeticamente por nome da cultura
          _allCulturas.sort((a, b) => a.cultura.compareTo(b.cultura));
          _filteredCulturas = List.from(_allCulturas);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar culturas: $e';
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
        _filteredCulturas = List.from(_allCulturas);
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
    
    final filtered = _allCulturas.where((cultura) {
      return cultura.cultura.toLowerCase().contains(searchLower);
    }).toList();

    if (mounted) {
      setState(() {
        // Ordena resultados filtrados alfabeticamente
        filtered.sort((a, b) => a.cultura.compareTo(b.cultura));
        _filteredCulturas = filtered;
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredCulturas = List.from(_allCulturas);
      _isSearching = false;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredCulturas.sort((a, b) {
        return _isAscending
            ? a.cultura.compareTo(b.cultura)
            : b.cultura.compareTo(a.cultura);
      });
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
    final total = _allCulturas.length;
    final filtered = _filteredCulturas.length;

    if (_isLoading && total == 0) {
      return 'Carregando culturas...';
    }
    
    if (_errorMessage != null) {
      return 'Erro no carregamento';
    }

    if (filtered < total) {
      return '$filtered de $total culturas';
    }

    return '$total culturas disponíveis';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
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
                isSearching: _isSearching,
                onClear: _clearSearch,
                onSubmitted: () => _performSearch(_searchController.text),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredCulturas.length,
        itemBuilder: (context, index) {
          final cultura = _filteredCulturas[index];
          return CulturaItemWidget(
            cultura: cultura,
            isDark: isDark,
            onTap: () => _onCulturaTap(cultura),
          );
        },
      );
    }
  }
}