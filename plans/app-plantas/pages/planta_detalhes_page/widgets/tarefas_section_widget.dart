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

/// Widget especializado para a seção de tarefas
/// Responsável pela listagem e gerenciamento das tarefas da planta
class TarefasSectionWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final List<TarefaModel> tarefas;
  final bool showCompleted;
  final String? sectionTitle;

  const TarefasSectionWidget({
    super.key,
    required this.controller,
    required this.tarefas,
    this.showCompleted = false,
    this.sectionTitle,
  });

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

      return Container(
        width: double.infinity,
        decoration: decoracao,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(estilos, cores),
            const SizedBox(height: 12.0),
            _buildTarefasList(cores),
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
            sectionTitle ??
                (showCompleted ? 'Tarefas Concluídas' : 'Tarefas Pendentes'),
            style: estilos['cardTitle'],
          ),
        ),
        _buildTaskCounter(estilos, cores),
      ],
    );
  }

  Widget _buildTaskCounter(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: tarefas.isEmpty ? cores['sucessoClaro'] : cores['avisoClaro'],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: tarefas.isEmpty ? cores['sucesso']! : cores['aviso']!,
          width: 1,
        ),
      ),
      child: Text(
        tarefas.isEmpty ? 'Em dia' : '${tarefas.length}',
        style: estilos['taskCounter']?.copyWith(
          color: tarefas.isEmpty ? cores['sucesso'] : cores['aviso'],
        ),
      ),
    );
  }

  Widget _buildTarefasList(
    Map<String, Color> cores,
  ) {
    if (tarefas.isEmpty) {
      return _buildEmptyState(cores);
    }

    return Column(
      children: [
        ...tarefas.map((tarefa) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: showCompleted
                  ? CompletedTaskItemWidget(
                      controller: controller,
                      tarefa: tarefa,
                    )
                  : TaskItemWidget(
                      controller: controller,
                      tarefa: tarefa,
                    ),
            )),
        if (!showCompleted) ...[
          const SizedBox(height: 8.0),
          _buildAddTaskButton(cores),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
    Map<String, Color> cores,
  ) {
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
            Icons.check_circle_outline,
            size: 48,
            color: cores['sucesso'],
          ),
          const SizedBox(height: 12.0),
          Text(
            showCompleted
                ? 'Nenhuma atividade executada ainda'
                : 'Todas as tarefas estão em dia!',
            style: estilos['emptyStateTitle'],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            showCompleted
                ? 'As atividades executadas aparecerão aqui quando você concluir tarefas.'
                : 'Sua planta não possui tarefas pendentes no momento.',
            style: estilos['emptyStateSubtitle'],
            textAlign: TextAlign.center,
          ),
          if (!showCompleted) ...[
            const SizedBox(height: 16.0),
            _buildAddTaskButton(cores),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTaskButton(
    Map<String, Color> cores,
  ) {
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
