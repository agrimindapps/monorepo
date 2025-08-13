// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../database/planta_model.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/utils/task_utils.dart';

/// Versão atualizada do TaskItemWidget usando utilitários consolidados
/// Esta versão demonstra como usar os novos utils compartilhados
class TaskItemWidget extends StatelessWidget {
  final Map<String, dynamic> tarefa;
  final PlantaModel planta;
  final VoidCallback onTap;
  final Function(String)? onStatusChange;

  const TaskItemWidget({
    super.key,
    required this.tarefa,
    required this.planta,
    required this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    // Usar os utilitários consolidados para formatação de data
    final dataFormatada = AppDateUtils.formatTaskDate(
      DateTime.parse(tarefa['dueDate'] ?? DateTime.now().toIso8601String()),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          TaskUtils.getTaskIcon(tarefa['tipo'] ?? 'agua'),
          color: TaskUtils.getTaskColor(tarefa['tipo'] ?? 'agua'),
        ),
        title: Text(tarefa['titulo'] ?? 'Tarefa'),
        subtitle: Text('$dataFormatada • ${planta.nome}'),
        trailing: Icon(
          tarefa['concluida'] == true
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: tarefa['concluida'] == true ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
