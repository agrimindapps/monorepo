// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/15_medicamento_model.dart';
import 'status_indicator.dart';

class MedicamentoCard extends StatelessWidget {
  final MedicamentoVet medicamento;
  final Function(MedicamentoVet) onEdit;
  final Function(MedicamentoVet) onDelete;
  final String Function(int) formatDate;
  final bool Function(MedicamentoVet) isActive;
  final int Function(MedicamentoVet) diasRestantes;

  const MedicamentoCard({
    super.key,
    required this.medicamento,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    required this.isActive,
    required this.diasRestantes,
  });

  @override
  Widget build(BuildContext context) {
    final active = isActive(medicamento);
    final formattedStartDate = formatDate(medicamento.inicioTratamento);
    final formattedEndDate = formatDate(medicamento.fimTratamento);
    final diasRestantesValue = diasRestantes(medicamento);

    return Card(
      child: ListTile(
        title: Text(
          medicamento.nomeMedicamento,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosagem: ${medicamento.dosagem}'),
            Text('Início: $formattedStartDate'),
            Text('Fim: $formattedEndDate'),
            Text(
              'Frequência: ${medicamento.frequencia}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (active) Text('Dias restantes: $diasRestantesValue'),
            StatusIndicator(isActive: active),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(medicamento),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete(medicamento),
            ),
          ],
        ),
      ),
    );
  }
}
