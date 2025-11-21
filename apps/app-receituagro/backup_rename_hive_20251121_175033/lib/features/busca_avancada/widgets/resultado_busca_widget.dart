import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/services/diagnostico_integration_service.dart';

/// Widget especializado para exibir resultados de busca
/// Organiza os resultados de forma visualmente atrativa
class ResultadoBuscaWidget extends StatelessWidget {
  final List<DiagnosticoDetalhado> resultados;
  final void Function(DiagnosticoDetalhado) onDiagnosticoTap;
  final String? filtroAtual;

  const ResultadoBuscaWidget({
    super.key,
    required this.resultados,
    required this.onDiagnosticoTap,
    this.filtroAtual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (resultados.isEmpty) {
      return _buildEstadoVazio(theme);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderResultados(theme),
        const SizedBox(height: 16),
        _buildListaResultados(),
      ],
    );
  }

  Widget _buildHeaderResultados(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.list_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados da Busca',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${resultados.length} diagnóstico(s) encontrado(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _buildIndicadorCriticos(theme),
        ],
      ),
    );
  }

  Widget _buildIndicadorCriticos(ThemeData theme) {
    final criticos = resultados.where((r) => r.isCritico).length;
    
    if (criticos == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$criticos crítico(s)',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaResultados() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resultados.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final diagnostico = resultados[index];
        return _buildItemResultado(diagnostico);
      },
    );
  }

  Widget _buildItemResultado(DiagnosticoDetalhado diagnostico) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: diagnostico.isCritico 
                ? BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => onDiagnosticoTap(diagnostico),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemHeader(theme, diagnostico),
                  const SizedBox(height: 12),
                  _buildItemDetalhes(theme, diagnostico),
                  const SizedBox(height: 12),
                  _buildItemFooter(theme, diagnostico),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemHeader(ThemeData theme, DiagnosticoDetalhado diagnostico) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: diagnostico.isCritico 
                  ? [Colors.red.shade400, Colors.red.shade600]
                  : [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            diagnostico.isCritico ? Icons.warning : Icons.medical_services,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagnostico.descricaoResumida,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    diagnostico.hasInfoCompleta ? Icons.check_circle : Icons.warning,
                    size: 12,
                    color: diagnostico.hasInfoCompleta ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    diagnostico.hasInfoCompleta ? 'Completo' : 'Parcial',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildItemDetalhes(ThemeData theme, DiagnosticoDetalhado diagnostico) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDetalheItem(
              theme,
              'Cultura',
              diagnostico.nomeCultura,
              FontAwesomeIcons.seedling,
              Colors.green,
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildDetalheItem(
              theme,
              'Praga',
              diagnostico.nomePraga,
              FontAwesomeIcons.bug,
              Colors.red,
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildDetalheItem(
              theme,
              'Defensivo',
              diagnostico.nomeComercialDefensivo,
              FontAwesomeIcons.vial,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheItem(
    ThemeData theme,
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildItemFooter(ThemeData theme, DiagnosticoDetalhado diagnostico) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.medication,
                size: 12,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                diagnostico.dosagem,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        if (diagnostico.temAplicacaoTerrestre)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.brown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              FontAwesomeIcons.tractor,
              size: 10,
              color: Colors.brown,
            ),
          ),
        
        if (diagnostico.temAplicacaoAerea)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              FontAwesomeIcons.helicopter,
              size: 10,
              color: Colors.blue,
            ),
          ),
      ],
    );
  }

  Widget _buildEstadoVazio(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: Colors.grey,
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
            'Tente ajustar os filtros ou remover algumas restrições.',
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
}
