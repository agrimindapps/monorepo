import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/widgets/modern_header_widget.dart';
import 'models/praga_model.dart';
import 'models/praga_view_mode.dart';
import 'widgets/praga_search_field_widget.dart';
import 'widgets/praga_item_widget.dart';
import 'widgets/pragas_empty_state_widget.dart';
import 'widgets/pragas_loading_skeleton_widget.dart';
import 'detalhe_praga_page.dart';

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
  Timer? _searchDebounceTimer;
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  
  List<PragaModel> _pragas = [];
  List<PragaModel> _pragasFiltered = [];
  String _searchText = '';
  late String _currentPragaType;

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _pragas = _generateMockData();
      _pragasFiltered = List.from(_pragas);
      _isLoading = false;
    });
  }

  List<PragaModel> _generateMockData() {
    switch (_currentPragaType) {
      case '1': // Insetos
        return [
          const PragaModel(
            idReg: '1',
            nomeComum: 'Lagarta do Cartucho',
            nomeCientifico: 'Spodoptera frugiperda',
            tipoPraga: '1',
            descricao: 'Praga importante do milho',
            sintomas: 'Danos nas folhas jovens',
            controle: 'Inseticidas e controle biológico',
          ),
          const PragaModel(
            idReg: '2',
            nomeComum: 'Percevejo da Soja',
            nomeCientifico: 'Nezara viridula',
            tipoPraga: '1',
            descricao: 'Percevejo que ataca grãos de soja',
            sintomas: 'Manchas nos grãos',
            controle: 'Monitoramento e inseticidas',
          ),
          const PragaModel(
            idReg: '3',
            nomeComum: 'Broca do Colmo',
            nomeCientifico: 'Diatraea saccharalis',
            tipoPraga: '1',
            descricao: 'Broca que ataca cana-de-açúcar',
            sintomas: 'Galerias no colmo',
            controle: 'Controle biológico com Cotesia',
          ),
          const PragaModel(
            idReg: '4',
            nomeComum: 'Mosca Branca',
            nomeCientifico: 'Bemisia tabaci',
            tipoPraga: '1',
            descricao: 'Praga sugadora de diversas culturas',
            sintomas: 'Amarelecimento das folhas',
            controle: 'Inseticidas sistêmicos',
          ),
          const PragaModel(
            idReg: '5',
            nomeComum: 'Ácaro Rajado',
            nomeCientifico: 'Tetranychus urticae',
            tipoPraga: '1',
            descricao: 'Ácaro que ataca folhas',
            sintomas: 'Pontuações amarelas nas folhas',
            controle: 'Acaricidas específicos',
          ),
        ];
      case '2': // Doenças
        return [
          const PragaModel(
            idReg: '6',
            nomeComum: 'Ferrugem da Soja',
            nomeCientifico: 'Phakopsora pachyrhizi',
            tipoPraga: '2',
            descricao: 'Doença fúngica da soja',
            sintomas: 'Pústulas alaranjadas nas folhas',
            controle: 'Fungicidas preventivos',
          ),
          const PragaModel(
            idReg: '7',
            nomeComum: 'Mancha Parda',
            nomeCientifico: 'Septoria glycines',
            tipoPraga: '2',
            descricao: 'Doença foliar da soja',
            sintomas: 'Manchas marrons nas folhas',
            controle: 'Rotação de culturas',
          ),
          const PragaModel(
            idReg: '8',
            nomeComum: 'Antracnose',
            nomeCientifico: 'Colletotrichum truncatum',
            tipoPraga: '2',
            descricao: 'Doença que afeta vagens',
            sintomas: 'Manchas escuras nas vagens',
            controle: 'Sementes tratadas',
          ),
          const PragaModel(
            idReg: '9',
            nomeComum: 'Oídio',
            nomeCientifico: 'Microsphaera diffusa',
            tipoPraga: '2',
            descricao: 'Doença do pó branco',
            sintomas: 'Pó branco nas folhas',
            controle: 'Fungicidas específicos',
          ),
        ];
      case '3': // Plantas Daninhas
        return [
          const PragaModel(
            idReg: '10',
            nomeComum: 'Capim Amargoso',
            nomeCientifico: 'Digitaria insularis',
            tipoPraga: '3',
            descricao: 'Gramínea invasora perene',
            sintomas: 'Competição por nutrientes',
            controle: 'Herbicidas sistêmicos',
          ),
          const PragaModel(
            idReg: '11',
            nomeComum: 'Buva',
            nomeCientifico: 'Conyza bonariensis',
            tipoPraga: '3',
            descricao: 'Planta daninha resistente',
            sintomas: 'Competição por luz',
            controle: 'Herbicidas pré-emergentes',
          ),
          const PragaModel(
            idReg: '12',
            nomeComum: 'Caruru',
            nomeCientifico: 'Amaranthus retroflexus',
            tipoPraga: '3',
            descricao: 'Planta invasora anual',
            sintomas: 'Competição por água',
            controle: 'Controle mecânico e químico',
          ),
        ];
      default:
        return [];
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

  List<PragaModel> _filterPragas(List<PragaModel> pragas, String searchText) {
    if (searchText.isEmpty) {
      return _sortPragas(List.from(pragas));
    }
    
    final query = searchText.toLowerCase();
    final filtered = pragas.where((praga) {
      return praga.nomeComum.toLowerCase().contains(query) ||
          (praga.nomeSecundario?.toLowerCase().contains(query) ?? false) ||
          (praga.nomeCientifico?.toLowerCase().contains(query) ?? false);
    }).toList();
    
    return _sortPragas(filtered);
  }

  List<PragaModel> _sortPragas(List<PragaModel> pragas) {
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

  void _handleItemTap(PragaModel praga) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.displayName,
          pragaScientificName: praga.nomeCientifico ?? 'Nome científico não disponível',
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
    
    return '$total registros';
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