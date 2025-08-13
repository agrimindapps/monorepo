// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/tarefa_model.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para exibir um item de tarefa
/// Responsável pela apresentação e interação com uma tarefa individual
class TaskItemWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final TarefaModel tarefa;

  const TaskItemWidget({
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
      'aviso': Colors.orange,
      'erro': Colors.red,
      'erroClaro': Colors.red.withValues(alpha: 0.1),
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
    };

    final isOverdue = tarefa.dataExecucao.isBefore(DateTime.now());
    final taskColor = _getTaskColor(tarefa.tipoCuidado);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isOverdue ? cores['erroClaro'] : cores['fundoCard'],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isOverdue ? cores['erro']! : cores['borda']!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTaskIcon(taskColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildTaskInfo(estilos, cores, isOverdue),
          ),
          _buildTaskActions(cores),
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
    bool isOverdue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTaskTitle(tarefa.tipoCuidado),
          style: estilos['taskTitle']?.copyWith(
            color: isOverdue ? cores['erro'] : cores['texto'],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          _formatTaskDate(tarefa.dataExecucao, isOverdue),
          style: estilos['taskDate']?.copyWith(
            color: isOverdue ? cores['erro'] : cores['textoSecundario'],
          ),
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

  Widget _buildTaskActions(
    Map<String, Color> cores,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => controller.marcarTarefaConcluida(tarefa),
          icon: Icon(
            Icons.check_circle_outline,
            color: cores['sucesso'],
          ),
          iconSize: 20.0,
          constraints: const BoxConstraints(
            minWidth: 40.0,
            minHeight: 40.0,
          ),
          tooltip: 'Marcar como concluída',
        ),
        IconButton(
          onPressed: () => _reagendarTarefa(),
          icon: Icon(
            Icons.schedule,
            color: cores['aviso'],
          ),
          iconSize: 20.0,
          constraints: const BoxConstraints(
            minWidth: 40.0,
            minHeight: 40.0,
          ),
          tooltip: 'Reagendar tarefa',
        ),
      ],
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
        return 'Regar';
      case 'adubo':
        return 'Adubar';
      case 'banho_sol':
        return 'Banho de sol';
      case 'pragas':
        return 'Verificar pragas';
      case 'poda':
        return 'Podar';
      case 'replante':
        return 'Replantar';
      default:
        return 'Cuidado';
    }
  }

  String _formatTaskDate(DateTime date, bool isOverdue) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (isOverdue) {
      final overdueDays = now.difference(date).inDays;
      if (overdueDays == 0) {
        return 'Venceu hoje';
      } else if (overdueDays == 1) {
        return 'Venceu ontem';
      } else {
        return 'Venceu há $overdueDays dias';
      }
    } else {
      if (difference == 0) {
        return 'Hoje';
      } else if (difference == 1) {
        return 'Amanhã';
      } else if (difference <= 7) {
        return 'Em $difference dias';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }
  }

  Future<void> _reagendarTarefa() async {
    final DateTime? novaData = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Reagendar Tarefa',
      confirmText: 'Reagendar',
      cancelText: 'Cancelar',
    );

    if (novaData != null) {
      await controller.reagendarTarefa(tarefa, novaData);
    }
  }
}
