import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import 'models/defensivo_model.dart';
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
    await Future.delayed(const Duration(seconds: 1));
    
    final mockData = [
      const DefensivoModel(
        idReg: '1', 
        line1: 'BLOWOUT, CLEANOVER', 
        line2: 'Dibrometo de diquate',
        nomeComum: 'BLOWOUT, CLEANOVER',
        ingredienteAtivo: 'Dibrometo de diquate',
        classeAgronomica: 'Herbicida',
        fabricante: 'Syngenta',
        modoAcao: 'Inibidor do fotossistema I'
      ),
      const DefensivoModel(
        idReg: '2',
        line1: 'Biagro Solo',
        line2: 'Trichoderma harzianum (Rifai), cepa...',
        nomeComum: 'Biagro Solo',
        ingredienteAtivo: 'Trichoderma harzianum (Rifai), cepa',
        classeAgronomica: 'Fungicida microbiológico',
        fabricante: 'Biagro',
        modoAcao: 'Controle biológico'
      ),
      const DefensivoModel(
        idReg: '3',
        line1: 'Owner',
        line2: 'Baculovirus Helicoverpa armigera (...',
        nomeComum: 'Owner',
        ingredienteAtivo: 'Baculovirus Helicoverpa armigera',
        classeAgronomica: 'Inseticida microbiológico',
        fabricante: 'AgBiTech',
        modoAcao: 'Agente viral'
      ),
      const DefensivoModel(
        idReg: '4',
        line1: 'CRISO-VIT',
        line2: 'Chrysoperla externa',
        nomeComum: 'CRISO-VIT',
        ingredienteAtivo: 'Chrysoperla externa',
        classeAgronomica: 'Agente Biológico de Controle',
        fabricante: 'Bug Agentes Biológicos',
        modoAcao: 'Controle biológico'
      ),
      const DefensivoModel(
        idReg: '5',
        line1: 'LEPROTECT S.F',
        line2: 'Spodoptera frugiperda multiple nu...',
        nomeComum: 'LEPROTECT S.F',
        ingredienteAtivo: 'Spodoptera frugiperda multiple nucleopolyhedrovirus',
        classeAgronomica: 'Inseticida microbiológico',
        fabricante: 'Lallemand',
        modoAcao: 'Agente viral'
      ),
      const DefensivoModel(
        idReg: '6',
        line1: 'ROW Vispo',
        line2: 'Bacillus subtilis cepa IAB/BS03',
        nomeComum: 'ROW Vispo',
        ingredienteAtivo: 'Bacillus subtilis cepa IAB/BS03',
        classeAgronomica: 'Fungicida microbiológico',
        fabricante: 'IHARA',
        modoAcao: 'Controle biológico'
      ),
      const DefensivoModel(
        idReg: '7',
        line1: 'Octane',
        line2: 'Isaria fumosorosea',
        nomeComum: 'Octane',
        ingredienteAtivo: 'Isaria fumosorosea',
        classeAgronomica: 'Nematicida Microbiológico',
        fabricante: 'Koppert',
        modoAcao: 'Fungo entomopatogênico'
      ),
      const DefensivoModel(
        idReg: '8',
        line1: 'Lalstop I32 SC',
        line2: 'Bacillus amyloliquefaciens Cepa IB...',
        nomeComum: 'Lalstop I32 SC',
        ingredienteAtivo: 'Bacillus amyloliquefaciens Cepa IB32',
        classeAgronomica: 'Fungicida microbiológico',
        fabricante: 'Lallemand',
        modoAcao: 'Controle biológico'
      ),
      const DefensivoModel(
        idReg: '9',
        line1: 'Glifosato Master',
        line2: 'N-(fosfonometil)glicina',
        nomeComum: 'Glifosato Master',
        ingredienteAtivo: 'N-(fosfonometil)glicina',
        classeAgronomica: 'Herbicida',
        fabricante: 'Nufarm',
        modoAcao: 'Inibidor da EPSPS'
      ),
      const DefensivoModel(
        idReg: '10',
        line1: 'Atrazina 500 SC',
        line2: '6-cloro-N-etil-N\'-(1-metiletil)-1,3,5-triazina',
        nomeComum: 'Atrazina 500 SC',
        ingredienteAtivo: '6-cloro-N-etil-N\'-(1-metiletil)-1,3,5-triazina',
        classeAgronomica: 'Herbicida',
        fabricante: 'Syngenta',
        modoAcao: 'Inibidor do fotossistema II'
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

    if (filtered < total) {
      return '$filtered de $total defensivos';
    }

    return '$total defensivos cadastrados';
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Defensivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getHeaderSubtitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha,
                  color: Colors.white,
                ),
                onPressed: _toggleSort,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: DefensivoSearchField(
              controller: _searchController,
              isDark: isDark,
              isSearching: _isSearching,
              selectedViewMode: _selectedViewMode,
              onToggleViewMode: _toggleViewMode,
              onClear: _clearSearch,
              onSubmitted: () => _performSearch(_searchController.text),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildContent(isDark),
          ),
        ],
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

      return Container(
        padding: const EdgeInsets.all(8),
        height: 600, // Fixed height for grid in SliverToBoxAdapter
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
      return Column(
        children: [
          ..._filteredDefensivos.map((defensivo) => DefensivoItemWidget(
            defensivo: defensivo,
            isDark: isDark,
            onTap: () => _onDefensivoTap(defensivo),
            isGridView: false,
          )),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      );
    }
  }
}