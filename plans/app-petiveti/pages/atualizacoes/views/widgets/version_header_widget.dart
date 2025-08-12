// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/atualizacoes_controller.dart';
import '../../utils/atualizacoes_constants.dart';
import '../../utils/atualizacoes_helpers.dart';

class VersionHeaderWidget extends StatelessWidget {
  final AtualizacoesController controller;

  const VersionHeaderWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: AtualizacoesHelpers.getCardPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 16),
          _buildStatistics(),
          if (controller.isFiltered) ...[
            const SizedBox(height: 12),
            _buildFilterInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Icon(
          AtualizacoesConstants.versionIcon,
          size: 24,
          color: AtualizacoesConstants.featureColor,
        ),
        const SizedBox(width: 8),
        const Text(
          'Histórico de Atualizações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        _buildActionsMenu(),
      ],
    );
  }

  Widget _buildActionsMenu() {
    return Builder(
      builder: (context) => PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Opções',
        itemBuilder: (context) => [
        PopupMenuItem(
          value: 'filter',
          child: Row(
            children: [
              Icon(
                controller.isFiltered ? Icons.filter_alt : Icons.filter_alt_outlined,
                size: 18,
                color: controller.isFiltered ? AtualizacoesConstants.featureColor : null,
              ),
              const SizedBox(width: 8),
              const Text('Filtros'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                controller.sortAscending ? Icons.sort : Icons.sort,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(controller.sortAscending ? 'Mais antigas primeiro' : 'Mais recentes primeiro'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 18),
              SizedBox(width: 8),
              Text('Recarregar'),
            ],
          ),
        ),
        if (controller.isFiltered)
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.clear_all, size: 18),
                SizedBox(width: 8),
                Text('Limpar filtros'),
              ],
            ),
          ),
      ],
        onSelected: (value) => _handleMenuAction(context, value),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'filter':
        controller.showFilterDialog(context);
        break;
      case 'sort':
        controller.toggleSortOrder();
        break;
      case 'refresh':
        controller.refresh();
        break;
      case 'clear':
        controller.clearAllFilters();
        break;
    }
  }

  Widget _buildStatistics() {
    final stats = controller.statistics;
    final latest = controller.latestVersion;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        AtualizacoesHelpers.buildStatChip(
          label: 'versões',
          value: '${stats['totalVersions']}',
          icon: AtualizacoesConstants.versionIcon,
          color: Colors.blue,
        ),
        if (stats['importantes']! > 0)
          AtualizacoesHelpers.buildStatChip(
            label: 'importantes',
            value: '${stats['importantes']}',
            icon: AtualizacoesConstants.importantIcon,
            color: AtualizacoesConstants.importantColor,
          ),
        AtualizacoesHelpers.buildStatChip(
          label: 'notas',
          value: '${stats['totalNotas']}',
          icon: Icons.note_outlined,
          color: Colors.green,
        ),
        if (latest != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AtualizacoesConstants.featureColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AtualizacoesConstants.featureColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AtualizacoesConstants.featureIcon,
                  size: 16,
                  color: AtualizacoesConstants.featureColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Atual: ${latest.versaoFormatada}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AtualizacoesConstants.featureColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.getResultsSummary(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
          if (controller.isFiltered)
            TextButton(
              onPressed: controller.clearAllFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Limpar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
