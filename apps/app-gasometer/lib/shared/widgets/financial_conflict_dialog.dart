/// Financial Conflict Resolution Dialog
/// UI for manual resolution of financial data conflicts
library;

import 'package:core/core.dart' ;
import 'package:flutter/material.dart';

import '../../features/expenses/data/models/expense_model.dart';
import '../../features/financial/domain/services/financial_conflict_resolver.dart';
import '../../features/fuel/data/models/fuel_supply_model.dart';

/// Dialog for resolving financial data conflicts
class FinancialConflictDialog extends StatefulWidget {
  const FinancialConflictDialog({
    super.key,
    required this.localEntity,
    required this.remoteEntity,
    required this.onResolved,
  });
  final BaseSyncEntity localEntity;
  final BaseSyncEntity remoteEntity;
  final void Function(
    FinancialConflictStrategy strategy,
    BaseSyncEntity? customResolution,
  )
  onResolved;

  @override
  State<FinancialConflictDialog> createState() =>
      _FinancialConflictDialogState();
}

class _FinancialConflictDialogState extends State<FinancialConflictDialog> {
  FinancialConflictStrategy _selectedStrategy =
      FinancialConflictStrategy.manualReview;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Conflito de Dados Financeiros'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foram encontradas versões diferentes dos mesmos dados financeiros. '
              'Escolha como resolver este conflito:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildEntityComparison(context, currencyFormatter),

            const SizedBox(height: 16),
            _buildStrategySelection(context),

            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _showDetails,
                  onChanged: (value) {
                    setState(() {
                      _showDetails = value ?? false;
                    });
                  },
                ),
                const Text('Mostrar detalhes técnicos'),
              ],
            ),

            if (_showDetails) _buildTechnicalDetails(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedStrategy != FinancialConflictStrategy.manualReview
              ? () => _resolveConflict(context)
              : null,
          child: const Text('Resolver'),
        ),
      ],
    );
  }

  Widget _buildEntityComparison(
    BuildContext context,
    NumberFormat currencyFormatter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparação de Versões:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildEntityCard(
                context,
                'Versão Local',
                widget.localEntity,
                Colors.blue,
                currencyFormatter,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEntityCard(
                context,
                'Versão Remota',
                widget.remoteEntity,
                Colors.green,
                currencyFormatter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntityCard(
    BuildContext context,
    String title,
    BaseSyncEntity entity,
    Color color,
    NumberFormat currencyFormatter,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (entity is FuelSupplyModel)
              ..._buildFuelDetails(entity, currencyFormatter),
            if (entity is ExpenseModel)
              ..._buildExpenseDetails(entity, currencyFormatter),

            const SizedBox(height: 8),
            Text(
              'Atualizado: ${_formatDateTime(entity.updatedAt ?? entity.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFuelDetails(
    FuelSupplyModel fuel,
    NumberFormat currencyFormatter,
  ) {
    return [
      Text('Valor: ${currencyFormatter.format(fuel.totalPrice)}'),
      Text('Litros: ${fuel.liters.toStringAsFixed(2)}L'),
      Text('Preço/L: ${currencyFormatter.format(fuel.pricePerLiter)}'),
      if (fuel.gasStationName?.isNotEmpty == true)
        Text('Posto: ${fuel.gasStationName}'),
    ];
  }

  List<Widget> _buildExpenseDetails(
    ExpenseModel expense,
    NumberFormat currencyFormatter,
  ) {
    return [
      Text('Valor: ${currencyFormatter.format(expense.valor)}'),
      Text('Tipo: ${expense.tipo}'),
      Text('Descrição: ${expense.descricao}'),
      if (expense.location?.isNotEmpty == true)
        Text('Local: ${expense.location}'),
    ];
  }

  Widget _buildStrategySelection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estratégia de Resolução:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...FinancialConflictStrategy.values.map((strategy) {
          final config = _getStrategyConfig(strategy);
          return RadioListTile<FinancialConflictStrategy>(
            value: strategy,
            groupValue: _selectedStrategy,
            onChanged: (value) {
              setState(() {
                _selectedStrategy = value!;
              });
            },
            title: Text(config.title),
            subtitle: Text(config.description),
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildTechnicalDetails(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: const Text('Detalhes Técnicos'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID da Entidade', widget.localEntity.id),
              _buildDetailRow(
                'Versão Local',
                widget.localEntity.version.toString(),
              ),
              _buildDetailRow(
                'Versão Remota',
                widget.remoteEntity.version.toString(),
              ),
              _buildDetailRow(
                'Usuário',
                widget.localEntity.userId ?? 'Não definido',
              ),
              _buildDetailRow(
                'Módulo',
                widget.localEntity.moduleName ?? 'Não definido',
              ),
              const SizedBox(height: 8),
              Text(
                'Conflito detectado devido a versões diferentes dos mesmos dados. '
                'Isso pode acontecer quando os dados são modificados em dispositivos diferentes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _resolveConflict(BuildContext context) {
    widget.onResolved(_selectedStrategy, null);
    Navigator.pop(context);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Não definido';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  _StrategyConfig _getStrategyConfig(FinancialConflictStrategy strategy) {
    switch (strategy) {
      case FinancialConflictStrategy.manualReview:
        return const _StrategyConfig(
          title: 'Revisão Manual',
          description: 'Manter dados locais e marcar para revisão posterior',
        );
      case FinancialConflictStrategy.mostRecent:
        return const _StrategyConfig(
          title: 'Mais Recente',
          description: 'Usar a versão que foi modificada mais recentemente',
        );
      case FinancialConflictStrategy.localPreferred:
        return const _StrategyConfig(
          title: 'Preferir Local',
          description: 'Manter a versão local (neste dispositivo)',
        );
      case FinancialConflictStrategy.remotePreferred:
        return const _StrategyConfig(
          title: 'Preferir Remota',
          description: 'Usar a versão remota (de outro dispositivo)',
        );
      case FinancialConflictStrategy.highestValue:
        return const _StrategyConfig(
          title: 'Maior Valor',
          description: 'Usar a versão com maior valor monetário',
        );
      case FinancialConflictStrategy.preserveReceipts:
        return const _StrategyConfig(
          title: 'Preservar Recibos',
          description: 'Preferir a versão que possui comprovantes/recibos',
        );
      case FinancialConflictStrategy.smartMerge:
        return const _StrategyConfig(
          title: 'Mesclagem Inteligente',
          description:
              'Combinar automaticamente os melhores campos de cada versão',
        );
    }
  }
}

class _StrategyConfig {
  const _StrategyConfig({required this.title, required this.description});
  final String title;
  final String description;
}
