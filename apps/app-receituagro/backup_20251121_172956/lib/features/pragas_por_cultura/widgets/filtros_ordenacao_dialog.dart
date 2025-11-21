import 'package:flutter/material.dart';

/// Dialog especializado para filtros e ordenação de pragas
/// Componente reutilizável com interface moderna
class FiltrosOrdenacaoDialog extends StatelessWidget {
  final String ordenacaoAtual;
  final String filtroTipoAtual;
  final void Function(String) onOrdenacaoChanged;
  final void Function(String) onFiltroTipoChanged;

  const FiltrosOrdenacaoDialog({
    super.key,
    required this.ordenacaoAtual,
    required this.filtroTipoAtual,
    required this.onOrdenacaoChanged,
    required this.onFiltroTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade200, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Filtros e Ordenação'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSecaoOrdenacao(context),
              const SizedBox(height: 24),
              _buildSecaoFiltros(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoOrdenacao(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.sort, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Ordenar por:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOpcaoOrdenacao(
          context,
          'Nível de Ameaça',
          'ameaca',
          Icons.warning,
          Colors.red,
        ),
        _buildOpcaoOrdenacao(
          context,
          'Nome da Praga',
          'nome',
          Icons.sort_by_alpha,
          Colors.blue,
        ),
        _buildOpcaoOrdenacao(
          context,
          'Quantidade de Diagnósticos',
          'diagnosticos',
          Icons.analytics,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildSecaoFiltros(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.filter_alt, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Filtrar por:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOpcaoFiltro(
          context,
          'Todas as Pragas',
          'todos',
          Icons.list,
          Colors.grey,
        ),
        _buildOpcaoFiltro(
          context,
          'Apenas Críticas',
          'criticas',
          Icons.dangerous,
          Colors.red,
        ),
        _buildOpcaoFiltro(
          context,
          'Apenas Normais',
          'normais',
          Icons.check_circle_outline,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildOpcaoOrdenacao(
    BuildContext context,
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isSelected = ordenacaoAtual == valor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: RadioListTile<String>(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        value: valor,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildOpcaoFiltro(
    BuildContext context,
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isSelected = filtroTipoAtual == valor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: RadioListTile<String>(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        value: valor,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String ordenacaoAtual,
    required String filtroTipoAtual,
    required void Function(String) onOrdenacaoChanged,
    required void Function(String) onFiltroTipoChanged,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => FiltrosOrdenacaoDialog(
        ordenacaoAtual: ordenacaoAtual,
        filtroTipoAtual: filtroTipoAtual,
        onOrdenacaoChanged: onOrdenacaoChanged,
        onFiltroTipoChanged: onFiltroTipoChanged,
      ),
    );
  }
}
