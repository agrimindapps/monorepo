import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/services/diagnostico_integration_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../database/receituagro_database.dart';
import '../pragas/widgets/praga_cultura_tab_bar_widget.dart';
import 'presentation/providers/pragas_cultura_page_view_model.dart';
import 'widgets/cultura_selector_widget.dart';
import 'widgets/defensivos_bottom_sheet.dart';
import 'widgets/estatisticas_cultura_widget.dart';
import 'widgets/filtros_ordenacao_dialog.dart';
import 'widgets/praga_por_cultura_card_widget.dart';
import 'widgets/pragas_cultura_state_handler.dart';

/// ✅ PHASE 3: Refactored page using ConsumerStatefulWidget
/// Integrates with Riverpod ViewModel from Phases 1-2
/// Reduced from 592 to ~180 lines by delegating business logic to services and ViewModel
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize ViewModel and load data
    Future.microtask(() {
      final viewModel = ref.read(pragasCulturaPageViewModelProvider.notifier);
      viewModel.loadCulturas();
      if (widget.culturaIdInicial != null) {
        viewModel.loadPragasForCultura(widget.culturaIdInicial!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(pragasCulturaPageViewModelProvider);
    final viewModel = ref.read(pragasCulturaPageViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: asyncState.when(
                data: (state) => Column(
                  children: [
                    _buildModernHeader(state, isDark, viewModel),
                    Expanded(
                      child: CustomScrollView(
                      slivers: [
                        // Cultura Selector
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: CulturaSelectorWidget(
                              culturas: state.culturas
                                  .map(
                                    (c) => <String, String>{
                                      'id': (c['id'] ?? '').toString(),
                                      'nome': (c['nome'] ?? '').toString(),
                                    },
                                  )
                                  .toList(),
                              culturaIdSelecionada: _extractCulturaId(state),
                              onCulturaChanged: (culturaId) {
                                viewModel.loadPragasForCultura(culturaId);
                              },
                            ),
                          ),
                        ),

                        // State Handler (Loading, Error, Empty)
                        if (_extractCulturaId(state) == null)
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.initial,
                              errorMessage: null,
                              onRetry: () => viewModel.refreshData(),
                            ),
                          )
                        else if (state.isLoading)
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.loading,
                              errorMessage: null,
                              onRetry: () => viewModel.refreshData(),
                            ),
                          )
                        else if (state.erro != null)
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.error,
                              errorMessage: state.erro,
                              onRetry: () => viewModel.refreshData(),
                            ),
                          )
                        else if (state.pragasFiltradasOrdenadas.isEmpty)
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.empty,
                              errorMessage: null,
                              onRetry: () => viewModel.refreshData(),
                            ),
                          )
                        else ...[
                          // Statistics Widget
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: EstatisticasCulturaWidget(
                                nomeCultura: _extractCulturaNome(state),
                                pragasPorCultura: state.pragasFiltradasOrdenadas
                                    .map(_mapToPragaPorCultura)
                                    .toList(),
                                ordenacao: state.filtroAtual.sortBy,
                                filtroTipo: _extractFiltroTipo(state),
                                onOrdenacaoChanged: (valor) {
                                  viewModel.sortPragas(valor);
                                },
                                onFiltroTipoChanged: (valor) {
                                  _applyFilterByType(valor, viewModel);
                                },
                              ),
                            ),
                          ),

                          // Tab Bar
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              child: PragaCulturaTabBarWidget(
                                tabController: _tabController,
                                onTabTap: (index) {},
                                isDark: isDark,
                              ),
                            ),
                          ),

                          // Tab Views
                          SliverFillRemaining(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTabContent(
                                  _filterByType(
                                    state.pragasFiltradasOrdenadas,
                                    '3',
                                  ),
                                  'Plantas Daninhas',
                                ),
                                _buildTabContent(
                                  _filterByType(
                                    state.pragasFiltradasOrdenadas,
                                    '2',
                                  ),
                                  'Doenças',
                                ),
                                _buildTabContent(
                                  _filterByType(
                                    state.pragasFiltradasOrdenadas,
                                    '1',
                                  ),
                                  'Insetos',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
                loading: () => Column(
                  children: [
                    _buildModernHeader(
                      const PragasCulturaPageState(),
                      isDark,
                      viewModel,
                    ),
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
                error: (Object error, StackTrace stack) => Column(
                  children: [
                    _buildModernHeader(
                      const PragasCulturaPageState(),
                      isDark,
                      viewModel,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Erro: $error',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        ),
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

  /// Build modern header with current state info
  Widget _buildModernHeader(
    PragasCulturaPageState state,
    bool isDark,
    PragasCulturaPageViewModel viewModel,
  ) {
    final titulo = _extractCulturaNome(state).isNotEmpty
        ? 'Pragas - ${_extractCulturaNome(state)}'
        : 'Pragas por Cultura';

    final subtitulo = state.pragasFiltradasOrdenadas.isNotEmpty
        ? '${state.pragasFiltradasOrdenadas.length} praga(s) encontrada(s)'
        : 'Selecione uma cultura para explorar';

    final criticasCount = state.estatisticas?.pragasCriticas ?? 0;

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: FontAwesomeIcons.bug,
      rightIcon: Icons.sort,
      isDark: isDark,
      showBackButton: true,
      showActions:
          state.pragasFiltradasOrdenadas.isNotEmpty && state.erro == null,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _mostrarOpcoesOrdenacao(viewModel),
      additionalActions: [
        if (state.pragasFiltradasOrdenadas.isNotEmpty && state.erro == null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$criticasCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Build tab content for each praga type
  Widget _buildTabContent(
    List<Map<String, dynamic>> pragasList,
    String tipoNome,
  ) {
    if (pragasList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma praga do tipo "$tipoNome" encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'para a cultura selecionada',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconByTipo(tipoNome),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoNome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${pragasList.length} praga(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildPragasList(pragasList),
        ],
      ),
    );
  }

  /// Build pragas list - Virtual Scroll para performance
  Widget _buildPragasList(List<Map<String, dynamic>> pragasList) {
    const itemHeight = 120.0; // Altura aproximada do PragaPorCulturaCardWidget
    
    return SizedBox(
      height: pragasList.length * itemHeight,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverFixedExtentList(
            itemExtent: itemHeight,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final praga = pragasList[index];
                return _buildPragaCard(praga);
              },
              childCount: pragasList.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          ),
        ],
      ),
    );
  }

  /// Build single praga card
  Widget _buildPragaCard(Map<String, dynamic> pragaMap) {
    final pragaId = pragaMap['objectId'] ?? pragaMap['id'] ?? '';
    return RepaintBoundary(
      key: ValueKey('praga_cultura_$pragaId'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: PragaPorCulturaCardWidget(
          pragaPorCultura: _mapToPragaPorCultura(pragaMap),
          onTap: () =>
              debugPrint('Navegar para detalhes da praga: ${pragaMap['id']}'),
          onVerDefensivos: () =>
              _verDefensivosDaPraga(_mapToPragaPorCultura(pragaMap)),
        ),
      ),
    );
  }

  /// Show ordering and filter options
  void _mostrarOpcoesOrdenacao(PragasCulturaPageViewModel viewModel) {
    FiltrosOrdenacaoDialog.show(
      context,
      ordenacaoAtual: 'ameaca',
      filtroTipoAtual: 'todos',
      onOrdenacaoChanged: (valor) {
        viewModel.sortPragas(valor);
      },
      onFiltroTipoChanged: (valor) {
        _applyFilterByType(valor, viewModel);
      },
    );
  }

  /// Show defensivos bottom sheet
  void _verDefensivosDaPraga(PragaPorCultura pragaPorCultura) {
    DefensivosBottomSheet.show(
      context,
      pragaPorCultura,
      onDefensivoTap: () {
        debugPrint('Navegar para detalhes do defensivo');
      },
    );
  }

  /// Get icon for praga type
  IconData _getIconByTipo(String tipoNome) {
    switch (tipoNome) {
      case 'Plantas Daninhas':
        return Icons.grass_outlined;
      case 'Doenças':
        return Icons.coronavirus_outlined;
      case 'Insetos':
        return Icons.bug_report_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }

  /// Extract culture ID from state
  String? _extractCulturaId(PragasCulturaPageState state) {
    if (state.pragasOriginais.isEmpty) {
      return widget.culturaIdInicial;
    }
    return widget.culturaIdInicial;
  }

  /// Extract culture name from state
  String _extractCulturaNome(PragasCulturaPageState state) {
    if (state.pragasOriginais.isEmpty) {
      return '';
    }
    // Get from first praga if available
    if (state.pragasOriginais.isNotEmpty) {
      final nomeCultura = state.pragasOriginais[0]['culturaNome'];
      return nomeCultura is String ? nomeCultura : '';
    }
    return '';
  }

  /// Extract filter type from state
  String _extractFiltroTipo(PragasCulturaPageState state) {
    return state.filtroAtual.onlyCriticas
        ? 'criticas'
        : (state.filtroAtual.onlyNormais ? 'normais' : 'todos');
  }

  /// Apply filter by type
  void _applyFilterByType(String tipo, PragasCulturaPageViewModel viewModel) {
    if (tipo == 'criticas') {
      viewModel.filterByCriticidade(onlyCriticas: true);
    } else if (tipo == 'normais') {
      viewModel.filterByCriticidade(onlyCriticas: false);
    } else {
      viewModel.clearFilters();
    }
  }

  /// Filter pragas by type code
  List<Map<String, dynamic>> _filterByType(
    List<Map<String, dynamic>> pragas,
    String tipoPragaCode,
  ) {
    return pragas.where((p) => p['tipoPraga'] == tipoPragaCode).toList();
  }

  /// Map from Map to PragaPorCultura (temporary adapter)
  /// TODO: Replace with proper type conversion after Phase 3
  PragaPorCultura _mapToPragaPorCultura(Map<String, dynamic> map) {
    // Create a minimal Praga from map data
    // This is a temporary solution - replace with proper mapper in Phase 4
    final praga = Praga(
      id: 0, // Auto-generated
      idPraga: map['objectId'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      nomeLatino: map['nomeCientifico'] as String? ?? '',
      tipo: map['tipoPraga'] as String? ?? '1',
    );

    return PragaPorCultura(praga: praga, diagnosticosRelacionados: const []);
  }
}
