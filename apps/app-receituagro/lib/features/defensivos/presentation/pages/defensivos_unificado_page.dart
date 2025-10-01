import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../core/widgets/modern_header_widget.dart';
import '../../data/services/defensivos_grouping_service.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import '../../data/defensivo_view_mode.dart';
import '../providers/defensivos_drill_down_provider.dart';
import '../providers/defensivos_unificado_provider.dart';
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
class DefensivosUnificadoPage extends StatefulWidget {
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
  State<DefensivosUnificadoPage> createState() => _DefensivosUnificadoPageState();
}

class _DefensivosUnificadoPageState extends State<DefensivosUnificadoPage> {
  final TextEditingController _searchController = TextEditingController();
  DefensivoViewMode _viewMode = DefensivoViewMode.list;
  String _searchText = '';
  bool _isAscending = true;
  
  // Providers para drill-down
  late DefensivosDrillDownProvider _drillDownProvider;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeDrillDownProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDefensivos();
    });
  }
  
  void _initializeDrillDownProvider() {
    _drillDownProvider = DefensivosDrillDownProvider(
      groupingService: DefensivosGroupingService(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _drillDownProvider.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
    
    // Atualizar drill-down provider se estiver usando drill-down
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      _drillDownProvider.updateSearchFilter(_searchText);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = '';
    });
    
    // Limpar filtro no drill-down provider
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      _drillDownProvider.clearSearchFilter();
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
    
    // Atualizar ordenação no drill-down provider
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      _drillDownProvider.toggleSort();
    }
  }

  void _carregarDefensivos() {
    final providerInstance = provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false);
    
    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      // Carrega defensivos agrupados e inicializa drill-down
      providerInstance.carregarDefensivosAgrupados(
        tipoAgrupamento: widget.tipoAgrupamento!,
        filtroTexto: widget.textoFiltro,
      ).then((_) {
        // Inicializar drill-down provider com dados carregados
        _drillDownProvider.initializeWithDefensivos(
          defensivos: providerInstance.defensivos,
          tipoAgrupamento: widget.tipoAgrupamento!,
        );
      });
    } else if (widget.modoCompleto) {
      // Carrega defensivos completos (lista simples)
      providerInstance.carregarDefensivosCompletos();
    } else {
      // Fallback para lista simples
      providerInstance.carregarDefensivosCompletos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: provider.Consumer<DefensivosUnificadoProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      _buildModernHeader(provider, isDark),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.hasError
                                ? _buildErrorState(provider)
                                : widget.isAgrupados && widget.tipoAgrupamento != null
                                    ? _buildDrillDownContent(provider)
                                    : _buildContent(provider),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: provider.Consumer<DefensivosUnificadoProvider>(
        builder: (context, provider, child) {
          if (provider.modoComparacao && provider.defensivosSelecionados.length >= 2) {
            return FloatingActionButton.extended(
              onPressed: () => _mostrarComparacao(provider.defensivosSelecionados),
              icon: const Icon(Icons.compare_arrows),
              label: Text('Comparar (${provider.defensivosSelecionados.length})'),
              backgroundColor: theme.colorScheme.primary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildModernHeader(DefensivosUnificadoProvider provider, bool isDark) {
    String titulo;
    String subtitulo;

    if (widget.isAgrupados && widget.tipoAgrupamento != null) {
      // Header para drill-down
      titulo = _drillDownProvider.pageTitle;
      subtitulo = _drillDownProvider.pageSubtitle;
      
      // Se está no nível de itens, mostrar contador dos itens filtrados
      if (_drillDownProvider.isAtItemLevel) {
        subtitulo = '${_drillDownProvider.currentGroupItems.length} defensivo(s) encontrado(s)';
      } else {
        // No nível de grupos, mostrar quantidade de grupos
        subtitulo = '${_drillDownProvider.groups.length} grupo(s) encontrado(s)';
      }
    } else {
      // Header tradicional
      titulo = 'Lista de Defensivos';
      subtitulo = '${provider.defensivosFiltrados.length} defensivo(s) encontrado(s)';
    }

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: Icons.medical_services,
      rightIcon: _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: widget.isAgrupados && _drillDownProvider.canGoBack 
          ? _onDrillDownBack 
          : null,
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildContent(DefensivosUnificadoProvider provider) {
    // Aplicar ordenação local aos defensivos
    final defensivosOrdenados = List<DefensivoEntity>.from(provider.defensivosFiltrados);
    defensivosOrdenados.sort((a, b) {
      final comparison = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });

    return Column(
      children: [
        _buildSearchField(provider),
        Expanded(
          child: DefensivosListWidget(
            defensivos: defensivosOrdenados,
            modoComparacao: provider.modoComparacao,
            defensivosSelecionados: provider.defensivosSelecionados,
            onTap: _navegarParaDetalhes,
            onSelecaoChanged: provider.modoComparacao ? provider.toggleSelecaoDefensivo : null,
            onClearFilters: provider.limparFiltros,
            hasActiveSearch: _searchText.isNotEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(DefensivosUnificadoProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DefensivoSearchFieldWidget(
      controller: _searchController,
      tipoAgrupamento: widget.tipoAgrupamento,
      isDark: isDark,
      viewMode: _viewMode,
      onViewModeChanged: _toggleViewMode,
      onClear: _clearSearch,
      onChanged: (value) {}, // O listener já está no controller
      isSearching: provider.isLoading,
    );
  }

  Widget _buildErrorState(DefensivosUnificadoProvider provider) {
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
              provider.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói conteúdo para drill-down navigation
  Widget _buildDrillDownContent(DefensivosUnificadoProvider provider) {
    return ListenableBuilder(
      listenable: _drillDownProvider,
      builder: (context, _) {
        if (_drillDownProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_drillDownProvider.hasError) {
          return _buildDrillDownErrorState();
        }

        return Column(
          children: [
            _buildSearchField(provider),
            Expanded(
              child: _drillDownProvider.isAtGroupLevel
                  ? _buildGroupsList()
                  : _buildItemsList(),
            ),
          ],
        );
      },
    );
  }

  /// Constrói lista de grupos
  Widget _buildGroupsList() {
    return DefensivosGroupListWidget(
      grupos: _drillDownProvider.groups,
      onGroupTap: _onGroupTap,
      onClearFilters: _clearSearch,
      searchText: _searchText,
    );
  }

  /// Constrói lista de itens do grupo
  Widget _buildItemsList() {
    return DefensivosListWidget(
      defensivos: _drillDownProvider.currentGroupItems,
      modoComparacao: provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false).modoComparacao,
      defensivosSelecionados: provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false).defensivosSelecionados,
      onTap: _navegarParaDetalhes,
      onSelecaoChanged: provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false).modoComparacao 
          ? provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false).toggleSelecaoDefensivo 
          : null,
      onClearFilters: _clearSearch,
      hasActiveSearch: _searchText.isNotEmpty,
    );
  }

  /// Estado de erro para drill-down
  Widget _buildDrillDownErrorState() {
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
              _drillDownProvider.errorMessage ?? 'Erro desconhecido',
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

  // Handlers para drill-down navigation
  
  void _onGroupTap(DefensivoGroupEntity group) {
    _drillDownProvider.drillDownToGroup(group);
  }

  void _onDrillDownBack() {
    _drillDownProvider.goBackToGroups();
  }


  void _reloadDrillDownData() {
    _drillDownProvider.clearError();
    _carregarDefensivos();
  }

  void _navegarParaDetalhes(DefensivoEntity defensivo) {
    debugPrint('=== NAVEGANDO PARA DETALHES ===');
    debugPrint('Defensivo: ${defensivo.displayName}');
    debugPrint('Fabricante: ${defensivo.fabricante}');

    // Navegação direta sem usar o service para debug
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
            provider.Provider.of<DefensivosUnificadoProvider>(context, listen: false).limparSelecao();
          },
        ),
      ),
    );
  }
}