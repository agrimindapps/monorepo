import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../data/defensivo_view_mode.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import '../providers/defensivos_drill_down_notifier.dart';
import '../providers/defensivos_unificado_notifier.dart';
import '../widgets/comparacao_defensivos_widget.dart';
import '../widgets/defensivo_search_field_widget.dart';
import '../widgets/defensivos_group_list_widget.dart';
import '../widgets/defensivos_list_widget.dart';

/// Página unificada de defensivos
/// Consolida funcionalidades de defensivos individuais e agrupados
/// Implementa arquitetura SOLID e Clean Architecture
///
/// Argumentos de navegação:
/// - tipoAgrupamento: String? - Tipo de agrupamento (fabricantes, modoAcao, etc.)
/// - textoFiltro: String? - Filtro de texto opcional
/// - modoCompleto: bool - Controle de modo de exibição (não usado para filtros)
/// - isAgrupados: bool - Se true, carrega dados agrupados por categoria
class DefensivosUnificadoPage extends ConsumerStatefulWidget {
  final String? tipoAgrupamento;
  final String? textoFiltro;
  final bool modoCompleto;
  final bool isAgrupados;

  const DefensivosUnificadoPage({
    super.key,
    this.tipoAgrupamento,
    this.textoFiltro,
    this.modoCompleto = false,
    this.isAgrupados = false,
  });

  @override
  ConsumerState<DefensivosUnificadoPage> createState() => _DefensivosUnificadoPageState();
}

class _DefensivosUnificadoPageState extends ConsumerState<DefensivosUnificadoPage> {
  final TextEditingController _searchController = TextEditingController();
  DefensivoViewMode _viewMode = DefensivoViewMode.list;
  String _searchText = '';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDefensivos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      ref.read(defensivosDrillDownNotifierProvider.notifier).updateSearchFilter(_searchText);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = '';
    });
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      ref.read(defensivosDrillDownNotifierProvider.notifier).clearSearchFilter();
    }
  }

  void _toggleViewMode(DefensivoViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      ref.read(defensivosDrillDownNotifierProvider.notifier).toggleSort();
    }
  }

  void _carregarDefensivos() {
    final notifier = ref.read(defensivosUnificadoNotifierProvider.notifier);

    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      notifier.carregarDefensivosAgrupados(
        tipoAgrupamento: widget.tipoAgrupamento!,
        filtroTexto: widget.textoFiltro,
      ).then((_) {
        final state = ref.read(defensivosUnificadoNotifierProvider);
        state.whenData((data) {
          ref.read(defensivosDrillDownNotifierProvider.notifier).initializeWithDefensivos(
            defensivos: data.defensivos,
            tipoAgrupamento: widget.tipoAgrupamento!,
          );
        });
      });
    } else if (widget.modoCompleto) {
      notifier.carregarDefensivosCompletos();
    } else {
      notifier.carregarDefensivosCompletos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unificadoState = ref.watch(defensivosUnificadoNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: unificadoState.when(
                data: (state) {
                  return Column(
                    children: [
                      _buildModernHeader(state, isDark),
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : state.hasError
                                ? _buildErrorState(state)
                                : widget.isAgrupados && widget.tipoAgrupamento != null
                                    ? _buildDrillDownContent(state)
                                    : _buildContent(state),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erro: $error'),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: unificadoState.whenOrNull(
        data: (state) {
          if (state.modoComparacao && state.defensivosSelecionados.length >= 2) {
            return FloatingActionButton.extended(
              onPressed: () => _mostrarComparacao(state.defensivosSelecionados),
              icon: const Icon(Icons.compare_arrows),
              label: Text('Comparar (${state.defensivosSelecionados.length})'),
              backgroundColor: theme.colorScheme.primary,
            );
          }
          return const SizedBox.shrink();
        },
      ) ?? const SizedBox.shrink(),
    );
  }

  Widget _buildModernHeader(DefensivosUnificadoState state, bool isDark) {
    String titulo;
    String subtitulo;

    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      final drillDownState = ref.watch(defensivosDrillDownNotifierProvider);

      drillDownState.whenData((drillDown) {
        titulo = drillDown.pageTitle;
        subtitulo = drillDown.pageSubtitle;
        if (drillDown.isAtItemLevel) {
          subtitulo = '${drillDown.currentGroupItems.length} defensivo(s) encontrado(s)';
        } else {
          subtitulo = '${drillDown.groups.length} grupo(s) encontrado(s)';
        }
      });

      titulo = drillDownState.value?.pageTitle ?? 'Defensivos';
      subtitulo = drillDownState.value?.pageSubtitle ?? '';

      if (drillDownState.value?.isAtItemLevel ?? false) {
        subtitulo = '${drillDownState.value?.currentGroupItems.length ?? 0} defensivo(s) encontrado(s)';
      } else {
        subtitulo = '${drillDownState.value?.groups.length ?? 0} grupo(s) encontrado(s)';
      }
    } else {
      titulo = 'Lista de Defensivos';
      subtitulo = '${state.defensivosFiltrados.length} defensivo(s) encontrado(s)';
    }

    final drillDownState = ref.watch(defensivosDrillDownNotifierProvider);
    final canGoBack = drillDownState.value?.canGoBack ?? false;

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: Icons.medical_services,
      rightIcon: _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: widget.isAgrupados && canGoBack
          ? _onDrillDownBack
          : null,
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildContent(DefensivosUnificadoState state) {
    final defensivosOrdenados = List<DefensivoEntity>.from(state.defensivosFiltrados);
    defensivosOrdenados.sort((a, b) {
      final comparison = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });

    return Column(
      children: [
        _buildSearchField(state),
        Expanded(
          child: DefensivosListWidget(
            defensivos: defensivosOrdenados,
            modoComparacao: state.modoComparacao,
            defensivosSelecionados: state.defensivosSelecionados,
            onTap: _navegarParaDetalhes,
            onSelecaoChanged: state.modoComparacao
                ? (defensivo) => ref.read(defensivosUnificadoNotifierProvider.notifier).toggleSelecaoDefensivo(defensivo)
                : null,
            onClearFilters: () => ref.read(defensivosUnificadoNotifierProvider.notifier).limparFiltros(),
            hasActiveSearch: _searchText.isNotEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(DefensivosUnificadoState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefensivoSearchFieldWidget(
      controller: _searchController,
      tipoAgrupamento: widget.tipoAgrupamento,
      isDark: isDark,
      viewMode: _viewMode,
      onViewModeChanged: _toggleViewMode,
      onClear: _clearSearch,
      onChanged: (value) {}, // O listener já está no controller
      isSearching: state.isLoading,
    );
  }

  Widget _buildErrorState(DefensivosUnificadoState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar defensivos',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(defensivosUnificadoNotifierProvider.notifier).reload(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói conteúdo para drill-down navigation
  Widget _buildDrillDownContent(DefensivosUnificadoState state) {
    final drillDownState = ref.watch(defensivosDrillDownNotifierProvider);

    return drillDownState.when(
      data: (drillDown) {
        if (drillDown.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (drillDown.hasError) {
          return _buildDrillDownErrorState(drillDown);
        }

        return Column(
          children: [
            _buildSearchField(state),
            Expanded(
              child: drillDown.isAtGroupLevel
                  ? _buildGroupsList(drillDown)
                  : _buildItemsList(drillDown, state),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildDrillDownErrorState(null),
    );
  }

  /// Constrói lista de grupos
  Widget _buildGroupsList(DefensivosDrillDownState drillDown) {
    return DefensivosGroupListWidget(
      grupos: drillDown.filteredGroups,
      onGroupTap: _onGroupTap,
      onClearFilters: _clearSearch,
      searchText: _searchText,
    );
  }

  /// Constrói lista de itens do grupo
  Widget _buildItemsList(DefensivosDrillDownState drillDown, DefensivosUnificadoState state) {
    return DefensivosListWidget(
      defensivos: drillDown.currentGroupItems,
      modoComparacao: state.modoComparacao,
      defensivosSelecionados: state.defensivosSelecionados,
      onTap: _navegarParaDetalhes,
      onSelecaoChanged: state.modoComparacao
          ? (defensivo) => ref.read(defensivosUnificadoNotifierProvider.notifier).toggleSelecaoDefensivo(defensivo)
          : null,
      onClearFilters: _clearSearch,
      hasActiveSearch: _searchText.isNotEmpty,
    );
  }

  /// Estado de erro para drill-down
  Widget _buildDrillDownErrorState(DefensivosDrillDownState? drillDown) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar grupos',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              drillDown?.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadDrillDownData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _onGroupTap(DefensivoGroupEntity group) {
    ref.read(defensivosDrillDownNotifierProvider.notifier).drillDownToGroup(group);
  }

  void _onDrillDownBack() {
    ref.read(defensivosDrillDownNotifierProvider.notifier).goBackToGroups();
  }

  void _reloadDrillDownData() {
    ref.read(defensivosDrillDownNotifierProvider.notifier).clearError();
    _carregarDefensivos();
  }

  void _navegarParaDetalhes(DefensivoEntity defensivo) {
    debugPrint('=== NAVEGANDO PARA DETALHES ===');
    debugPrint('Defensivo: ${defensivo.displayName}');
    debugPrint('Fabricante: ${defensivo.fabricante}');
    Navigator.of(context).pushNamed(
      '/detalhe-defensivo',
      arguments: {
        'defensivoName': defensivo.displayName,
        'fabricante': defensivo.fabricante ?? '',
      },
    );
  }

  void _mostrarComparacao(List<DefensivoEntity> defensivos) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ComparacaoDefensivosWidget(
          defensivos: defensivos,
          onFechar: () {
            Navigator.of(context).pop();
            ref.read(defensivosUnificadoNotifierProvider.notifier).limparSelecao();
          },
        ),
      ),
    );
  }
}
