import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import 'models/defensivo_model.dart';
import 'models/view_mode.dart';
import 'widgets/defensivo_search_field.dart';
import 'widgets/defensivo_item_widget.dart';
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
  final List<DefensivoModel> _allDefensivos = [];
  List<DefensivoModel> _filteredDefensivos = [];
  ViewMode _selectedViewMode = ViewMode.list;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isAscending = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadMockData();
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

  void _loadMockData() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final mockData = [
      const DefensivoModel(
        idReg: '1', 
        line1: '2,4-D Amina', 
        line2: 'Ácido 2,4-diclorofenoxiacético',
        nomeComum: '2,4-D Amina',
        ingredienteAtivo: 'Ácido 2,4-diclorofenoxiacético',
        classeAgronomica: 'Herbicida',
        fabricante: 'Nufarm',
        modoAcao: 'Auxina sintética'
      ),
      const DefensivoModel(
        idReg: '2',
        line1: 'Abamectina',
        line2: 'Abamectina',
        nomeComum: 'Abamectina',
        ingredienteAtivo: 'Abamectina',
        classeAgronomica: 'Inseticida/Acaricida',
        fabricante: 'Syngenta',
        modoAcao: 'Modulador do canal de cloreto'
      ),
      const DefensivoModel(
        idReg: '3',
        line1: 'Acefato',
        line2: 'Acefato',
        nomeComum: 'Acefato',
        ingredienteAtivo: 'Acefato',
        classeAgronomica: 'Inseticida',
        fabricante: 'FMC',
        modoAcao: 'Inibidor da acetilcolinesterase'
      ),
      const DefensivoModel(
        idReg: '4',
        line1: 'Azoxistrobina',
        line2: 'Azoxistrobina',
        nomeComum: 'Azoxistrobina',
        ingredienteAtivo: 'Azoxistrobina',
        classeAgronomica: 'Fungicida',
        fabricante: 'Syngenta',
        modoAcao: 'Inibidor da respiração'
      ),
      const DefensivoModel(
        idReg: '5',
        line1: 'Glifosato',
        line2: 'N-(fosfonometil)glicina',
        nomeComum: 'Glifosato',
        ingredienteAtivo: 'N-(fosfonometil)glicina',
        classeAgronomica: 'Herbicida',
        fabricante: 'Bayer',
        modoAcao: 'Inibidor da EPSPS'
      ),
      const DefensivoModel(
        idReg: '6',
        line1: 'Atrazina',
        line2: '6-cloro-N-etil-N\'-(1-metiletil)-1,3,5-triazina',
        nomeComum: 'Atrazina',
        ingredienteAtivo: '6-cloro-N-etil-N\'-(1-metiletil)-1,3,5-triazina',
        classeAgronomica: 'Herbicida',
        fabricante: 'Syngenta',
        modoAcao: 'Inibidor do fotossistema II'
      ),
      const DefensivoModel(
        idReg: '7',
        line1: 'Clorotalonil',
        line2: 'Tetracloroisoftalonitrila',
        nomeComum: 'Clorotalonil',
        ingredienteAtivo: 'Tetracloroisoftalonitrila',
        classeAgronomica: 'Fungicida',
        fabricante: 'ISK',
        modoAcao: 'Multi-sítio'
      ),
      const DefensivoModel(
        idReg: '8',
        line1: 'Imidacloprido',
        line2: '1-(6-cloro-3-piridinil-metil)-N-nitroimidazolidin-2-ilidenamine',
        nomeComum: 'Imidacloprido',
        ingredienteAtivo: '1-(6-cloro-3-piridinil-metil)-N-nitroimidazolidin-2-ilidenamine',
        classeAgronomica: 'Inseticida',
        fabricante: 'Bayer',
        modoAcao: 'Agonista do receptor nicotínico'
      ),
      const DefensivoModel(
        idReg: '9',
        line1: 'Tebuconazol',
        line2: '1-(4-clorofenil)-4,4-dimetil-3-(1H-1,2,4-triazol-1-ilmetil)-pentan-3-ol',
        nomeComum: 'Tebuconazol',
        ingredienteAtivo: '1-(4-clorofenil)-4,4-dimetil-3-(1H-1,2,4-triazol-1-ilmetil)-pentan-3-ol',
        classeAgronomica: 'Fungicida',
        fabricante: 'Bayer',
        modoAcao: 'Inibidor da desmetilação'
      ),
      const DefensivoModel(
        idReg: '10',
        line1: 'Paraquat',
        line2: '1,1\'-dimetil-4,4\'-bipiridínio',
        nomeComum: 'Paraquat',
        ingredienteAtivo: '1,1\'-dimetil-4,4\'-bipiridínio',
        classeAgronomica: 'Herbicida',
        fabricante: 'Syngenta',
        modoAcao: 'Inibidor do fotossistema I'
      ),
    ];

    if (mounted) {
      setState(() {
        _allDefensivos.addAll(mockData);
        _filteredDefensivos = List.from(_allDefensivos);
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

  void _onDefensivoTap(DefensivoModel defensivo) {
    debugPrint('Navegar para detalhes do defensivo: ${defensivo.displayName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes de ${defensivo.displayName}'),
        duration: const Duration(seconds: 2),
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

    if (filtered < total) {
      return '$filtered de $total defensivos';
    }

    return '$total defensivos cadastrados';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              ModernHeaderWidget(
                title: 'Defensivos',
                subtitle: _getHeaderSubtitle(),
                leftIcon: Icons.shield_outlined,
                rightIcon: _isAscending
                    ? Icons.arrow_upward_outlined
                    : Icons.arrow_downward_outlined,
                isDark: isDark,
                showBackButton: true,
                showActions: true,
                onBackPressed: () => Navigator.of(context).pop(),
                onRightIconPressed: _toggleSort,
              ),
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
      return DefensivosLoadingSkeletonWidget(
        isDark: isDark,
        viewMode: _selectedViewMode,
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
            : 'Os defensivos serão carregados em breve',
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

      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
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
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredDefensivos.length,
        itemBuilder: (context, index) {
          final defensivo = _filteredDefensivos[index];
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
}