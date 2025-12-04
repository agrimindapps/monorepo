import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/widgets/modern_header_widget.dart';
import '../pragas/data/praga_view_mode.dart';
import '../pragas/domain/entities/praga_entity.dart';
import '../pragas/presentation/pages/detalhe_praga_page.dart';
import '../pragas/widgets/praga_card_widget.dart';
import '../pragas/widgets/praga_cultura_tab_bar_widget.dart';
import 'presentation/providers/pragas_cultura_page_view_model.dart';
import 'widgets/pragas_cultura_state_handler.dart';

/// Página de Pragas por Cultura - Refatorada
/// Usa os mesmos componentes da ListaPragasPage para consistência visual
class PragasPorCulturaDetalhadasPage extends ConsumerStatefulWidget {
  final String? culturaIdInicial;

  const PragasPorCulturaDetalhadasPage({super.key, this.culturaIdInicial});

  @override
  ConsumerState<PragasPorCulturaDetalhadasPage> createState() =>
      _PragasPorCulturaDetalhadasPageState();
}

class _PragasPorCulturaDetalhadasPageState
    extends ConsumerState<PragasPorCulturaDetalhadasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State por tab - busca e modo de visualização independentes
  final Map<int, TextEditingController> _searchControllers = {};
  final Map<int, String> _searchTexts = {};
  final Map<int, PragaViewMode> _viewModes = {};
  final Map<int, Timer?> _debounceTimers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Inicializa controllers para cada tab
    for (var i = 0; i < 3; i++) {
      _searchControllers[i] = TextEditingController();
      _searchTexts[i] = '';
      _viewModes[i] = PragaViewMode.grid;
    }

    // Initialize ViewModel and load data
    Future.microtask(() {
      final viewModel = ref.read(pragasCulturaPageViewModelProvider.notifier);
      if (widget.culturaIdInicial != null) {
        viewModel.loadPragasForCultura(widget.culturaIdInicial!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _searchControllers.values) {
      controller.dispose();
    }
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _onSearchChanged(int tabIndex, String text) {
    _debounceTimers[tabIndex]?.cancel();
    setState(() {
      _searchTexts[tabIndex] = text;
    });
    _debounceTimers[tabIndex] = Timer(const Duration(milliseconds: 300), () {
      setState(() {}); // Trigger rebuild with filtered results
    });
  }

  void _clearSearch(int tabIndex) {
    _searchControllers[tabIndex]?.clear();
    setState(() {
      _searchTexts[tabIndex] = '';
    });
  }

  void _toggleViewMode(int tabIndex, PragaViewMode mode) {
    setState(() {
      _viewModes[tabIndex] = mode;
    });
  }

  void _handlePragaTap(PragaEntity praga) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.nomeComum,
          pragaId: praga.idReg,
          pragaScientificName: praga.nomeCientifico.isNotEmpty
              ? praga.nomeCientifico
              : 'Nome científico não disponível',
        ),
      ),
    );
  }

  /// Converte Map para PragaEntity
  PragaEntity _mapToPragaEntity(Map<String, dynamic> map) {
    return PragaEntity(
      idReg: map['objectId'] as String? ?? map['id']?.toString() ?? '',
      nomeComum: map['nome'] as String? ?? '',
      nomeCientifico: map['nomeCientifico'] as String? ?? '',
      tipoPraga: map['tipoPraga'] as String? ?? '1',
    );
  }

  /// Filtra pragas por texto de busca
  List<PragaEntity> _filterPragasBySearch(
    List<Map<String, dynamic>> pragas,
    String searchText,
  ) {
    final entities = pragas.map(_mapToPragaEntity).toList();
    if (searchText.isEmpty) return entities;

    final searchLower = searchText.toLowerCase();
    return entities.where((praga) {
      return praga.nomeComum.toLowerCase().contains(searchLower) ||
          praga.nomeCientifico.toLowerCase().contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(pragasCulturaPageViewModelProvider);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: asyncState.when(
                data: (state) => Column(
                  children: [
                    _buildModernHeader(state, isDark),
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: PragaCulturaTabBarWidget(
                        tabController: _tabController,
                        onTabTap: (index) {},
                        isDark: isDark,
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: _buildTabBarView(state, isDark),
                    ),
                  ],
                ),
                loading: () => Column(
                  children: [
                    _buildModernHeader(
                      const PragasCulturaPageState(),
                      isDark,
                    ),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                error: (error, _) => Column(
                  children: [
                    _buildModernHeader(
                      const PragasCulturaPageState(),
                      isDark,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Erro: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(PragasCulturaPageState state, bool isDark) {
    final culturaNome = _extractCulturaNome(state);
    final titulo = culturaNome.isNotEmpty
        ? 'Pragas - $culturaNome'
        : 'Pragas por Cultura';

    final subtitulo = state.pragasFiltradasOrdenadas.isNotEmpty
        ? '${state.pragasFiltradasOrdenadas.length} praga(s) encontrada(s)'
        : 'Carregando pragas...';

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: FontAwesomeIcons.bug,
      isDark: isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTabBarView(PragasCulturaPageState state, bool isDark) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.erro != null) {
      return PragasCulturaStateHandler(
        state: PragasCulturaState.error,
        errorMessage: state.erro,
        onRetry: () =>
            ref.read(pragasCulturaPageViewModelProvider.notifier).refreshData(),
      );
    }

    if (state.pragasFiltradasOrdenadas.isEmpty) {
      return PragasCulturaStateHandler(
        state: PragasCulturaState.empty,
        errorMessage: null,
        onRetry: () =>
            ref.read(pragasCulturaPageViewModelProvider.notifier).refreshData(),
      );
    }

    // Tipos: 3 = Plantas Daninhas, 2 = Doenças, 1 = Insetos
    final pragasPlantas = _filterByType(state.pragasFiltradasOrdenadas, '3');
    final pragasDoencas = _filterByType(state.pragasFiltradasOrdenadas, '2');
    final pragasInsetos = _filterByType(state.pragasFiltradasOrdenadas, '1');

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTabContentWithSearch(0, pragasPlantas, 'Plantas Daninhas', isDark),
        _buildTabContentWithSearch(1, pragasDoencas, 'Doenças', isDark),
        _buildTabContentWithSearch(2, pragasInsetos, 'Insetos', isDark),
      ],
    );
  }

  Widget _buildTabContentWithSearch(
    int tabIndex,
    List<Map<String, dynamic>> pragas,
    String tipoNome,
    bool isDark,
  ) {
    final searchText = _searchTexts[tabIndex] ?? '';
    final viewMode = _viewModes[tabIndex] ?? PragaViewMode.grid;
    final filteredPragas = _filterPragasBySearch(pragas, searchText);

    return Column(
      children: [
        // Search field
        _buildSearchField(tabIndex, tipoNome, isDark, viewMode),
        // Content
        Expanded(
          child: filteredPragas.isEmpty
              ? _buildEmptyState(tipoNome, searchText.isNotEmpty, isDark)
              : _buildPragasContent(filteredPragas, viewMode, isDark),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    int tabIndex,
    String tipoNome,
    bool isDark,
    PragaViewMode viewMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.green.shade100.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                size: 20,
              ),
              Expanded(
                child: TextField(
                  controller: _searchControllers[tabIndex],
                  onChanged: (value) => _onSearchChanged(tabIndex, value),
                  decoration: InputDecoration(
                    hintText: 'Buscar ${tipoNome.toLowerCase()}...',
                    hintStyle: TextStyle(
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    suffixIcon: (_searchTexts[tabIndex] ?? '').isNotEmpty
                        ? IconButton(
                            onPressed: () => _clearSearch(tabIndex),
                            icon: Icon(
                              Icons.clear_rounded,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: TextStyle(
                    color:
                        isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildViewToggleButtons(tabIndex, isDark, viewMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButtons(
    int tabIndex,
    bool isDark,
    PragaViewMode currentMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade100.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            tabIndex,
            PragaViewMode.grid,
            Icons.grid_view_rounded,
            currentMode,
            isDark,
            isFirst: true,
          ),
          _buildToggleButton(
            tabIndex,
            PragaViewMode.list,
            Icons.view_list_rounded,
            currentMode,
            isDark,
            isFirst: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    int tabIndex,
    PragaViewMode mode,
    IconData icon,
    PragaViewMode currentMode,
    bool isDark, {
    required bool isFirst,
  }) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () => _toggleViewMode(tabIndex, mode),
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(isFirst ? 20 : 0),
        right: Radius.circular(!isFirst ? 20 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.green.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirst ? 20 : 0),
            right: Radius.circular(!isFirst ? 20 : 0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String tipoNome, bool isSearching, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.pest_control_outlined,
            size: 64,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Nenhum resultado encontrado'
                : 'Nenhuma praga encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Tente usar outros termos de busca'
                : 'Não há registros disponíveis nesta categoria',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPragasContent(
    List<PragaEntity> pragas,
    PragaViewMode viewMode,
    bool isDark,
  ) {
    return viewMode.isGrid
        ? _buildGrid(pragas, isDark)
        : _buildList(pragas, isDark);
  }

  Widget _buildGrid(List<PragaEntity> pragas, bool isDark) {
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
          itemCount: pragas.length,
          itemBuilder: (context, index) {
            final praga = pragas[index];
            return RepaintBoundary(
              child: PragaCardWidget(
                key: ValueKey('praga_cultura_${praga.idReg}_grid'),
                praga: praga,
                mode: PragaCardMode.grid,
                isDarkMode: isDark,
                onTap: () => _handlePragaTap(praga),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(List<PragaEntity> pragas, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: pragas.length,
      itemBuilder: (context, index) {
        final praga = pragas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RepaintBoundary(
            child: PragaCardWidget(
              key: ValueKey('praga_cultura_${praga.idReg}_list'),
              praga: praga,
              mode: PragaCardMode.list,
              isDarkMode: isDark,
              onTap: () => _handlePragaTap(praga),
            ),
          ),
        );
      },
    );
  }

  String _extractCulturaNome(PragasCulturaPageState state) {
    if (state.pragasOriginais.isEmpty) return '';
    final nomeCultura = state.pragasOriginais[0]['culturaNome'];
    return nomeCultura is String ? nomeCultura : '';
  }

  List<Map<String, dynamic>> _filterByType(
    List<Map<String, dynamic>> pragas,
    String tipoPragaCode,
  ) {
    return pragas.where((p) => p['tipoPraga'] == tipoPragaCode).toList();
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }
}
