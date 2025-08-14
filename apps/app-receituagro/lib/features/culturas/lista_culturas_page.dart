import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas/lista_pragas_por_cultura_page.dart';
import 'models/cultura_model.dart';
import 'widgets/cultura_search_field.dart';
import 'widgets/cultura_item_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/loading_skeleton_widget.dart';

class ListaCulturasPage extends StatefulWidget {
  const ListaCulturasPage({super.key});

  @override
  State<ListaCulturasPage> createState() => _ListaCulturasPageState();
}

class _ListaCulturasPageState extends State<ListaCulturasPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<CulturaModel> _allCulturas = [];
  List<CulturaModel> _filteredCulturas = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isAscending = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadMockData() async {
    // Simula carregamento de dados
    await Future.delayed(const Duration(seconds: 2));
    
    final mockData = [
      const CulturaModel(idReg: '1', cultura: 'Soja', grupo: 'Oleaginosas'),
      const CulturaModel(idReg: '2', cultura: 'Milho', grupo: 'Cereais'),
      const CulturaModel(idReg: '3', cultura: 'Feijão', grupo: 'Leguminosas'),
      const CulturaModel(idReg: '4', cultura: 'Algodão', grupo: 'Fibras'),
      const CulturaModel(idReg: '5', cultura: 'Trigo', grupo: 'Cereais'),
      const CulturaModel(idReg: '6', cultura: 'Arroz', grupo: 'Cereais'),
      const CulturaModel(idReg: '7', cultura: 'Tomate', grupo: 'Hortaliças'),
      const CulturaModel(idReg: '8', cultura: 'Alface', grupo: 'Hortaliças'),
      const CulturaModel(idReg: '9', cultura: 'Café', grupo: 'Permanentes'),
      const CulturaModel(idReg: '10', cultura: 'Cana-de-açúcar', grupo: 'Industriais'),
      const CulturaModel(idReg: '11', cultura: 'Banana', grupo: 'Frutas'),
      const CulturaModel(idReg: '12', cultura: 'Laranja', grupo: 'Frutas'),
      const CulturaModel(idReg: '13', cultura: 'Maçã', grupo: 'Frutas'),
      const CulturaModel(idReg: '14', cultura: 'Batata', grupo: 'Hortaliças'),
      const CulturaModel(idReg: '15', cultura: 'Cenoura', grupo: 'Hortaliças'),
    ];

    if (mounted) {
      setState(() {
        _allCulturas.addAll(mockData);
        _filteredCulturas = List.from(_allCulturas);
        _isLoading = false;
      });
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
      return cultura.cultura.toLowerCase().contains(searchLower) ||
          cultura.grupo.toLowerCase().contains(searchLower);
    }).toList();

    if (mounted) {
      setState(() {
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

  void _onCulturaTap(CulturaModel cultura) {
    Navigator.push(
      context,
      MaterialPageRoute(
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

    if (filtered < total) {
      return '$filtered de $total culturas';
    }

    return '$total culturas cadastradas';
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
    } else if (_filteredCulturas.isEmpty) {
      return EmptyStateWidget(
        isDark: isDark,
        message: _searchController.text.isNotEmpty
            ? 'Nenhuma cultura encontrada'
            : 'Nenhuma cultura disponível',
        subtitle: _searchController.text.isNotEmpty
            ? 'Tente ajustar os termos da busca'
            : 'As culturas serão carregadas em breve',
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