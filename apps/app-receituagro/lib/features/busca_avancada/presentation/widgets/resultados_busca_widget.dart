import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/diagnostico_integration_service.dart';
import '../../../DetalheDiagnostico/widgets/diagnostico_relacional_card_widget.dart';
import '../providers/busca_avancada_provider.dart';

/// Widget especializado para exibir resultados da busca avançada
class ResultadosBuscaWidget extends StatelessWidget {
  final BuscaAvancadaProvider provider;

  const ResultadosBuscaWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return SliverToBoxAdapter(child: _buildLoadingState(context));
    }
    
    if (provider.hasError) {
      return SliverToBoxAdapter(child: _buildErrorState(context));
    }
    
    if (!provider.hasSearched) {
      return SliverToBoxAdapter(child: _buildEstadoInicial(context));
    }
    
    if (provider.resultados.isEmpty) {
      return SliverToBoxAdapter(child: _buildEstadoSemResultados(context));
    }
    
    return _buildListaResultados();
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Realizando busca avançada...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processando filtros e integrando dados relacionais',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Erro na busca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Verifique os filtros e tente novamente',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.realizarBusca(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoInicial(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.searchengin,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Busca Avançada de Diagnósticos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Configure os filtros acima e realize uma busca para encontrar diagnósticos específicos.\n\nVocê pode combinar filtros por cultura, praga e defensivo simultaneamente.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildExemplosCarousel(theme),
        ],
      ),
    );
  }

  Widget _buildExemplosCarousel(ThemeData theme) {
    final exemplos = [
      {
        'titulo': 'Por Cultura',
        'descricao': 'Encontre todas as pragas que atacam uma cultura específica',
        'icon': FontAwesomeIcons.seedling,
        'color': Colors.green,
      },
      {
        'titulo': 'Por Praga',
        'descricao': 'Veja todos os defensivos disponíveis para uma praga',
        'icon': FontAwesomeIcons.bug,
        'color': Colors.red,
      },
      {
        'titulo': 'Por Defensivo',
        'descricao': 'Descubra todos os usos de um defensivo específico',
        'icon': FontAwesomeIcons.vial,
        'color': Colors.blue,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exemplos.length,
        itemBuilder: (context, index) {
          final exemplo = exemplos[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: (exemplo['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (exemplo['color'] as Color).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      exemplo['icon'] as IconData,
                      size: 20,
                      color: exemplo['color'] as Color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exemplo['titulo'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    exemplo['descricao'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoSemResultados(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou remover algumas restrições para encontrar mais resultados.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.limparFiltros(),
            icon: const Icon(Icons.clear),
            label: const Text('Limpar Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaResultados() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final diagnostico = provider.resultados[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DiagnosticoRelacionalCardWidget(
              diagnosticoDetalhado: diagnostico,
              onTap: () => _navegarParaDetalhes(context, diagnostico),
            ),
          );
        },
        childCount: provider.resultados.length,
      ),
    );
  }

  void _navegarParaDetalhes(BuildContext context, DiagnosticoDetalhado diagnostico) {
    // Navigator.pushNamed(
    //   context,
    //   '/diagnostico-detalhado',
    //   arguments: diagnostico.diagnostico.idReg,
    // );
    debugPrint('Navegar para detalhes: ${diagnostico.diagnostico.idReg}');
  }
}