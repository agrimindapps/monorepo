// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/tarefa_model.dart';
import '../controller/planta_detalhes_controller.dart';
import 'completed_task_item_widget.dart';
import 'task_item_widget.dart';

enum TaskViewMode { pending, completed }

/// Widget gerenciador para tarefas com alternância entre pendentes e concluídas
class TarefasManagerWidget extends StatefulWidget {
  final PlantaDetalhesController controller;

  const TarefasManagerWidget({
    super.key,
    required this.controller,
  });

  @override
  State<TarefasManagerWidget> createState() => _TarefasManagerWidgetState();
}

class _TarefasManagerWidgetState extends State<TarefasManagerWidget> {
  TaskViewMode _currentMode = TaskViewMode.pending;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'primaria': PlantasColors.primaryColor,
        'fundoCard': PlantasColors.surfaceColor,
        'texto': PlantasColors.textColor,
        'textoSecundario': PlantasColors.textSecondaryColor,
        'textoClaro': PlantasColors.surfaceColor,
        'sucesso': Colors.green,
        'sucessoClaro': Colors.green.withValues(alpha: 0.1),
        'aviso': Colors.orange,
        'avisoClaro': Colors.orange.withValues(alpha: 0.1),
        'shadow': PlantasColors.shadowColor,
      };

      final estilos = {
        'cardTitle': TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: cores['texto'],
        ),
        'taskCounter': const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        'emptyStateTitle': TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: cores['texto'],
        ),
        'emptyStateSubtitle': TextStyle(
          fontSize: 14.0,
          color: cores['textoSecundario'],
        ),
      };

      final decoracao = BoxDecoration(
        color: cores['fundoCard'],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: cores['shadow']!,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      );

      final currentTasks = _currentMode == TaskViewMode.pending
          ? widget.controller.proximasTarefas
          : widget.controller.tarefasRecentes;

      return Container(
        width: double.infinity,
        decoration: decoracao,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(estilos, cores),
            const SizedBox(height: 12.0),
            _buildTasksList(cores, currentTasks),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Row(
      children: [
        Icon(
          Icons.task_alt,
          color: cores['primaria'],
          size: 24,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            _currentMode == TaskViewMode.pending
                ? 'Tarefas Pendentes'
                : 'Atividades Executadas',
            style: estilos['cardTitle'],
          ),
        ),
        _buildTaskCounter(estilos, cores),
        const SizedBox(width: 8.0),
        _buildDropdownMenu(cores),
      ],
    );
  }

  Widget _buildTaskCounter(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    final currentTasks = _currentMode == TaskViewMode.pending
        ? widget.controller.proximasTarefas
        : widget.controller.tarefasRecentes;

    final isEmpty = currentTasks.isEmpty;
    final isCompleted = _currentMode == TaskViewMode.completed;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: isEmpty
            ? cores['sucessoClaro']
            : (isCompleted ? cores['sucessoClaro'] : cores['avisoClaro']),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isEmpty
              ? cores['sucesso']!
              : (isCompleted ? cores['sucesso']! : cores['aviso']!),
          width: 1,
        ),
      ),
      child: Text(
        _getCounterText(currentTasks),
        style: estilos['taskCounter']?.copyWith(
          color: isEmpty
              ? cores['sucesso']
              : (isCompleted ? cores['sucesso'] : cores['aviso']),
        ),
      ),
    );
  }

  String _getCounterText(List<TarefaModel> tasks) {
    if (tasks.isEmpty) {
      return _currentMode == TaskViewMode.pending ? 'Em dia' : 'Vazio';
    }
    return '${tasks.length}';
  }

  Widget _buildDropdownMenu(Map<String, Color> cores) {
    return PopupMenuButton<TaskViewMode>(
      icon: Icon(
        Icons.more_vert,
        color: cores['textoSecundario'],
        size: 20,
      ),
      color: cores['fundoCard'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<TaskViewMode>(
          value: TaskViewMode.pending,
          child: Row(
            children: [
              Icon(
                Icons.pending_actions,
                color: cores['aviso'],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Tarefas Pendentes',
                style: TextStyle(
                  color: _currentMode == TaskViewMode.pending
                      ? cores['primaria']
                      : cores['texto'],
                  fontWeight: _currentMode == TaskViewMode.pending
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (_currentMode == TaskViewMode.pending) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: cores['primaria'],
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem<TaskViewMode>(
          value: TaskViewMode.completed,
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: cores['sucesso'],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Atividades Executadas',
                style: TextStyle(
                  color: _currentMode == TaskViewMode.completed
                      ? cores['primaria']
                      : cores['texto'],
                  fontWeight: _currentMode == TaskViewMode.completed
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (_currentMode == TaskViewMode.completed) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  color: cores['primaria'],
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ],
      onSelected: (TaskViewMode mode) {
        setState(() {
          _currentMode = mode;
        });
      },
    );
  }

  Widget _buildTasksList(
    Map<String, Color> cores,
    List<TarefaModel> tasks,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState(cores);
    }

    return Column(
      children: [
        ...tasks.map((tarefa) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _currentMode == TaskViewMode.completed
                  ? CompletedTaskItemWidget(
                      controller: widget.controller,
                      tarefa: tarefa,
                    )
                  : TaskItemWidget(
                      controller: widget.controller,
                      tarefa: tarefa,
                    ),
            )),
        if (_currentMode == TaskViewMode.pending) ...[
          const SizedBox(height: 8.0),
          _buildAddTaskButton(cores),
        ],
      ],
    );
  }

  Widget _buildEmptyState(Map<String, Color> cores) {
    final textColor = PlantasColors.textColor;
    final secondaryTextColor = PlantasColors.textSecondaryColor;

    final estilos = {
      'emptyStateTitle': TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      'emptyStateSubtitle': TextStyle(
        fontSize: 14.0,
        color: secondaryTextColor,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(
            _currentMode == TaskViewMode.pending
                ? Icons.check_circle_outline
                : Icons.history,
            size: 48,
            color: cores['sucesso'],
          ),
          const SizedBox(height: 12.0),
          Text(
            _currentMode == TaskViewMode.pending
                ? 'Todas as tarefas estão em dia!'
                : 'Nenhuma atividade executada ainda',
            style: estilos['emptyStateTitle'],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            _currentMode == TaskViewMode.pending
                ? 'Sua planta não possui tarefas pendentes no momento.'
                : 'As atividades executadas aparecerão aqui quando você concluir tarefas.',
            style: estilos['emptyStateSubtitle'],
            textAlign: TextAlign.center,
          ),
          if (_currentMode == TaskViewMode.pending) ...[
            const SizedBox(height: 16.0),
            _buildAddTaskButton(cores),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(Map<String, Color> cores) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {}, // Add task navigation - Future implementation
        style: ElevatedButton.styleFrom(
          backgroundColor: cores['primaria'],
          foregroundColor: cores['textoClaro'],
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Adicionar Nova Tarefa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
