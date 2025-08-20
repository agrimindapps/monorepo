// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/13_despesa_model.dart';
import '../../utils/despesas_utils.dart';

class DespesaCard extends StatelessWidget {
  final DespesaVet despesa;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String Function(int)? formatarData;
  final String Function(double)? formatarValor;

  const DespesaCard({
    super.key,
    required this.despesa,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.formatarData,
    this.formatarValor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipoColor = Color(int.parse(DespesasUtils.getTipoColor(despesa.tipo).substring(1), radix: 16) + 0xFF000000);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: tipoColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tipoColor),
              const SizedBox(height: 12),
              _buildContent(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color tipoColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tipoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tipoColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DespesasUtils.getTipoIcon(despesa.tipo),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                despesa.tipo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: tipoColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          DespesasUtils.formatarValorComMoeda(despesa.valor),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          despesa.descricao,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          formatarData?.call(despesa.dataDespesa) ?? 
          DespesasUtils.formatarData(despesa.dataDespesa),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          DespesasUtils.formatarDataRelativa(despesa.dataDespesa),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        if (onEdit != null || onDelete != null) ...[
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Editar',
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Excluir',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
