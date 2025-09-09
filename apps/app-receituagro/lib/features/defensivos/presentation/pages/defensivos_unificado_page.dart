import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../providers/defensivos_unificado_provider.dart';
import '../widgets/comparacao_defensivos_widget.dart';
import '../widgets/defensivos_list_widget.dart';
import '../widgets/filtros_defensivos_widget.dart';

/// Página unificada de defensivos
/// Consolida funcionalidades de defensivos individuais e agrupados
/// Implementa arquitetura SOLID e Clean Architecture
class DefensivosUnificadoPage extends StatefulWidget {
  final String? tipoAgrupamento;
  final String? textoFiltro;
  final bool modoCompleto;

  const DefensivosUnificadoPage({
    super.key,
    this.tipoAgrupamento,
    this.textoFiltro,
    this.modoCompleto = false,
  });

  @override
  State<DefensivosUnificadoPage> createState() => _DefensivosUnificadoPageState();
}

class _DefensivosUnificadoPageState extends State<DefensivosUnificadoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDefensivos();
    });
  }

  void _carregarDefensivos() {
    final provider = context.read<DefensivosUnificadoProvider>();
    
    if (widget.modoCompleto) {
      provider.carregarDefensivosCompletos();
    } else {
      provider.carregarDefensivosAgrupados(
        tipoAgrupamento: widget.tipoAgrupamento ?? 'classe',
        filtroTexto: widget.textoFiltro,
      );
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
              child: Consumer<DefensivosUnificadoProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      _buildModernHeader(provider, isDark),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.hasError
                                ? _buildErrorState(provider)
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
      floatingActionButton: Consumer<DefensivosUnificadoProvider>(
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
    final subtitulo = provider.modoComparacao 
        ? 'Modo comparação - ${provider.defensivosSelecionados.length}/3 selecionados'
        : '${provider.defensivosFiltrados.length} defensivo(s) encontrado(s)';

    return ModernHeaderWidget(
      title: widget.modoCompleto ? 'Defensivos Detalhados' : 'Defensivos Agrupados',
      subtitle: subtitulo,
      leftIcon: Icons.medical_services,
      rightIcon: provider.modoComparacao ? Icons.close : Icons.compare_arrows,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: provider.toggleModoComparacao,
      additionalActions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: provider.reload,
        ),
        if (provider.defensivosFiltrados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${provider.defensivosFiltrados.length}',
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

  Widget _buildContent(DefensivosUnificadoProvider provider) {
    return CustomScrollView(
      slivers: [
        // Filtros (apenas em modo completo)
        if (widget.modoCompleto)
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: FiltrosDefensivosWidget(
                  ordenacao: provider.ordenacao,
                  filtroToxicidade: provider.filtroToxicidade,
                  filtroTipo: provider.filtroTipo,
                  apenasComercializados: provider.apenasComercializados,
                  apenasElegiveis: provider.apenasElegiveis,
                  onOrdenacaoChanged: (valor) => provider.atualizarFiltros(ordenacao: valor),
                  onToxicidadeChanged: (valor) => provider.atualizarFiltros(filtroToxicidade: valor),
                  onTipoChanged: (valor) => provider.atualizarFiltros(filtroTipo: valor),
                  onComercializadosChanged: (valor) => provider.atualizarFiltros(apenasComercializados: valor),
                  onElegiveisChanged: (valor) => provider.atualizarFiltros(apenasElegiveis: valor),
                ),
              ),
            ),
          ),
        
        // Lista de defensivos
        DefensivosListWidget(
          defensivos: provider.defensivosFiltrados,
          modoComparacao: provider.modoComparacao,
          defensivosSelecionados: provider.defensivosSelecionados,
          onTap: _navegarParaDetalhes,
          onSelecaoChanged: provider.modoComparacao ? provider.toggleSelecaoDefensivo : null,
          onClearFilters: provider.limparFiltros,
        ),
      ],
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

  void _navegarParaDetalhes(DefensivoEntity defensivo) {
    // TODO: Implementar navegação para detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes do defensivo: ${defensivo.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarComparacao(List<DefensivoEntity> defensivos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ComparacaoDefensivosWidget(
          defensivos: defensivos,
          onFechar: () {
            Navigator.of(context).pop();
            context.read<DefensivosUnificadoProvider>().limparSelecao();
          },
        ),
      ),
    );
  }
}