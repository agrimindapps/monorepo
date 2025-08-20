// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/14_lembrete_model.dart';

class LembreteCard extends StatelessWidget {
  final LembreteVet lembrete;
  final Function(LembreteVet) onToggleConcluido;
  final Function(LembreteVet) onEdit;
  final Function(LembreteVet) onDelete;
  final String Function(int) formatDateTime;
  final bool Function(LembreteVet) isAtrasado;
  final String Function(LembreteVet) getStatusText;
  final Color Function(LembreteVet) getStatusColor;
  final IconData Function(LembreteVet) getStatusIcon;
  final IconData Function(LembreteVet) getActionIcon;
  final Color Function(LembreteVet) getActionColor;

  const LembreteCard({
    super.key,
    required this.lembrete,
    required this.onToggleConcluido,
    required this.onEdit,
    required this.onDelete,
    required this.formatDateTime,
    required this.isAtrasado,
    required this.getStatusText,
    required this.getStatusColor,
    required this.getStatusIcon,
    required this.getActionIcon,
    required this.getActionColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(lembrete);
    final statusText = getStatusText(lembrete);
    final statusIcon = getStatusIcon(lembrete);
    final actionIcon = getActionIcon(lembrete);
    final actionColor = getActionColor(lembrete);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onEdit(lembrete),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusColor, statusText, statusIcon, actionIcon, actionColor),
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

  Widget _buildHeader(Color statusColor, String statusText, IconData statusIcon, IconData actionIcon, Color actionColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => onToggleConcluido(lembrete),
              icon: Icon(actionIcon, color: actionColor),
              tooltip: lembrete.concluido ? 'Marcar como pendente' : 'Marcar como concluído',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: () => onEdit(lembrete),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar lembrete',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: () => onDelete(lembrete),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir lembrete',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lembrete.titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: lembrete.concluido ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey,
          ),
        ),
        if (lembrete.descricao.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            lembrete.descricao,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              decoration: lembrete.concluido ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          formatDateTime(lembrete.dataHora),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        if (lembrete.tipo.isNotEmpty) ...[
          Icon(Icons.label_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              lembrete.tipo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
