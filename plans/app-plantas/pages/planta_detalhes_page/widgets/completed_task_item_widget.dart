// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/tarefa_model.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para exibir uma tarefa concluída
/// Responsável pela apresentação de uma tarefa já executada
class CompletedTaskItemWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final TarefaModel tarefa;

  const CompletedTaskItemWidget({
    super.key,
    required this.controller,
    required this.tarefa,
  });

  @override
  Widget build(BuildContext context) {
    final cores = {
      'fundoCard': PlantasColors.surfaceColor,
      'texto': PlantasColors.textColor,
      'textoSecundario': PlantasColors.textSecondaryColor,
      'borda': PlantasColors.borderColor,
      'sucesso': Colors.green,
      'sucessoClaro': Colors.green.withValues(alpha: 0.1),
    };

    final estilos = {
      'taskTitle': TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: cores['texto'],
      ),
      'taskDate': TextStyle(
        fontSize: 12.0,
        color: cores['textoSecundario'],
      ),
      'taskNote': TextStyle(
        fontSize: 12.0,
        color: cores['textoSecundario'],
      ),
      'completedDate': TextStyle(
        fontSize: 11.0,
        color: cores['sucesso'],
        fontWeight: FontWeight.w500,
      ),
    };

    final taskColor = _getTaskColor(tarefa.tipoCuidado);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: cores['sucessoClaro'],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: cores['sucesso']!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTaskIcon(taskColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildTaskInfo(estilos, cores),
          ),
          _buildCompletedIndicator(cores),
        ],
      ),
    );
  }

  Widget _buildTaskIcon(Color taskColor) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: taskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        _getTaskIcon(tarefa.tipoCuidado),
        color: taskColor,
        size: 20.0,
      ),
    );
  }

  Widget _buildTaskInfo(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTaskTitle(tarefa.tipoCuidado),
          style: estilos['taskTitle'],
        ),
        const SizedBox(height: 4.0),
        Text(
          'Executada em ${_formatCompletedDate(tarefa.dataConclusao ?? tarefa.dataExecucao)}',
          style: estilos['completedDate'],
        ),
        if (tarefa.observacoes?.isNotEmpty == true) ...[
          const SizedBox(height: 4.0),
          Text(
            tarefa.observacoes!,
            style: estilos['taskNote'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedIndicator(Map<String, Color> cores) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: cores['sucesso']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Icon(
        Icons.check_circle,
        color: cores['sucesso'],
        size: 20.0,
      ),
    );
  }

  Color _getTaskColor(String tipoCuidado) {
    // Cores por tipo de cuidado
    switch (tipoCuidado.toLowerCase()) {
      case 'agua':
        return const Color(0xFF2196F3);
      case 'adubo':
        return const Color(0xFF4CAF50);
      case 'banho_sol':
        return const Color(0xFFFF9800);
      case 'pragas':
        return const Color(0xFFF44336);
      case 'poda':
        return const Color(0xFF9C27B0);
      case 'replante':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getTaskIcon(String tipoCuidado) {
    switch (tipoCuidado.toLowerCase()) {
      case 'agua':
        return Icons.water_drop_outlined;
      case 'adubo':
        return Icons.eco_outlined;
      case 'banho_sol':
        return Icons.wb_sunny_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'poda':
        return Icons.content_cut_outlined;
      case 'replante':
        return Icons.grass_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  String _getTaskTitle(String tipoCuidado) {
    switch (tipoCuidado.toLowerCase()) {
      case 'agua':
        return 'Rega';
      case 'adubo':
        return 'Adubação';
      case 'banho_sol':
        return 'Banho de sol';
      case 'pragas':
        return 'Controle de pragas';
      case 'poda':
        return 'Poda';
      case 'replante':
        return 'Replante';
      default:
        return 'Cuidado';
    }
  }

  String _formatCompletedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'hoje';
    } else if (difference == 1) {
      return 'ontem';
    } else if (difference <= 7) {
      return 'há $difference dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
