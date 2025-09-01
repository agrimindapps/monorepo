import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../widgets/estatisticas_busca_widget.dart';
import '../providers/busca_avancada_provider.dart';
import '../widgets/filtros_avancados_widget.dart';
import '../widgets/resultados_busca_widget.dart';

/// Clean page da busca avançada com arquitetura Provider otimizada
class BuscaAvancadaDiagnosticosCleanPage extends StatefulWidget {
  const BuscaAvancadaDiagnosticosCleanPage({super.key});

  @override
  State<BuscaAvancadaDiagnosticosCleanPage> createState() => _BuscaAvancadaDiagnosticosCleanPageState();
}

class _BuscaAvancadaDiagnosticosCleanPageState extends State<BuscaAvancadaDiagnosticosCleanPage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuscaAvancadaProvider>().carregarDadosDropdowns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: Consumer<BuscaAvancadaProvider>(
                    builder: (context, provider, child) {
                      return CustomScrollView(
                        slivers: [
                          // Seção de filtros
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              child: FiltrosAvancadosWidget(
                                provider: provider,
                                onBuscarPressed: _realizarBusca,
                                onLimparPressed: _limparFiltros,
                              ),
                            ),
                          ),

                          // Seção de estatísticas (se há resultados)
                          if (provider.hasSearched && provider.temResultados)
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                child: EstatisticasBuscaWidget(
                                  resultados: provider.resultados,
                                  filtros: provider.filtrosDetalhados,
                                ),
                              ),
                            ),

                          // Seção de conteúdo principal
                          ResultadosBuscaWidget(provider: provider),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Consumer<BuscaAvancadaProvider>(
      builder: (context, provider, child) {
        final subtitulo = provider.temFiltrosAtivos
            ? 'Filtros: ${provider.filtrosAtivosTexto}'
            : 'Configure os filtros e realize sua busca';

        return ModernHeaderWidget(
          title: 'Busca Avançada',
          subtitle: subtitulo,
          leftIcon: Icons.search,
          rightIcon: provider.hasSearched ? Icons.clear_all : Icons.filter_list,
          isDark: isDark,
          showBackButton: true,
          showActions: true,
          onBackPressed: () => Navigator.of(context).pop(),
          onRightIconPressed: provider.hasSearched ? _limparFiltros : null,
          additionalActions: [
            if (provider.temResultados)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.resultados.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _realizarBusca() async {
    final provider = context.read<BuscaAvancadaProvider>();
    final erro = await provider.realizarBusca();
    
    if (erro != null && mounted) {
      _mostrarAlerta(erro);
    }
  }

  void _limparFiltros() {
    context.read<BuscaAvancadaProvider>().limparFiltros();
  }

  void _mostrarAlerta(String mensagem) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}