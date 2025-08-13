// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

import '../shared/utils/task_utils.dart';

// Project imports:

/// Widget consolidado para exibição de itens de tarefa
/// Unifica funcionalidades dos TaskItemWidgets duplicados das diferentes páginas
class TaskItemWidget extends StatelessWidget {
  // Dados da tarefa - flexível para diferentes modelos
  final String? tipoCuidado;
  final DateTime? dataLimite;
  final String? observacoes;
  final dynamic tarefa; // Para modelos específicos

  // Callbacks de ação
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onReschedule;

  // Configurações de aparência
  final bool showCompleteButton;
  final bool showRescheduleButton;
  final bool showObservacoes;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  // Cores customizáveis (opcional)
  final Map<String, Color>? customColors;
  final Map<String, double>? customDimensions;
  final Map<String, TextStyle>? customTextStyles;

  const TaskItemWidget({
    super.key,
    this.tipoCuidado,
    this.dataLimite,
    this.observacoes,
    this.tarefa,
    this.onTap,
    this.onComplete,
    this.onReschedule,
    this.showCompleteButton = true,
    this.showRescheduleButton = false,
    this.showObservacoes = true,
    this.margin,
    this.padding,
    this.customColors,
    this.customDimensions,
    this.customTextStyles,
  });

  /// Factory para uso compatível com minhas_plantas_page
  factory TaskItemWidget.fromMinhasPlantas({
    required Map<String, dynamic> tarefa,
    required dynamic planta,
    VoidCallback? onTap,
    VoidCallback? onComplete,
  }) {
    return TaskItemWidget(
      tipoCuidado: (tarefa['tipo'] ?? tarefa['tipoCuidado'] ?? '') as String?,
      dataLimite: (tarefa['dataLimite'] ?? tarefa['dataExecucao']) as DateTime?,
      observacoes: tarefa['observacoes'] as String?,
      tarefa: tarefa,
      onTap: onTap,
      onComplete: onComplete,
      showCompleteButton: onComplete != null,
      showRescheduleButton: false,
    );
  }

  /// Factory para uso compatível com planta_detalhes_page
  factory TaskItemWidget.fromPlantaDetalhes({
    required dynamic controller,
    required dynamic tarefaModel,
  }) {
    return TaskItemWidget(
      tipoCuidado: _extractTipoCuidado(tarefaModel),
      dataLimite: _extractDataExecucao(tarefaModel),
      observacoes: _extractObservacoes(tarefaModel),
      tarefa: tarefaModel,
      onTap: () => _handleTap(controller, tarefaModel),
      onComplete: () => _handleComplete(controller, tarefaModel),
      onReschedule: () => _handleReschedule(controller, tarefaModel),
      showCompleteButton: true,
      showRescheduleButton: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskInfo = TaskUtils.getTaskInfo(tipoCuidado, dataLimite);

    // Usar cores padrão ou customizadas
    final cores = customColors ?? _getDefaultColors(context);
    final dimensoes = customDimensions ?? _getDefaultDimensions();
    final estilos = customTextStyles ?? _getDefaultTextStyles(context);

    final effectiveMargin =
        margin ?? EdgeInsets.only(bottom: dimensoes['marginS'] ?? 8.0);
    final effectivePadding =
        padding ?? EdgeInsets.all(dimensoes['paddingM'] ?? 12.0);

    return Container(
      margin: effectiveMargin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dimensoes['radiusS'] ?? 8.0),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: TaskUtils.getTaskBackgroundColor(dataLimite, cores),
              borderRadius: BorderRadius.circular(dimensoes['radiusS'] ?? 8.0),
              border: Border.all(
                color: TaskUtils.getTaskBorderColor(dataLimite, cores),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildTaskIcon(taskInfo, dimensoes),
                SizedBox(width: dimensoes['paddingM'] ?? 12.0),
                Expanded(
                  child: _buildTaskInfo(taskInfo, estilos, cores),
                ),
                if (showCompleteButton || showRescheduleButton)
                  _buildTaskActions(cores, dimensoes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskIcon(TaskInfo taskInfo, Map<String, double> dimensoes) {
    final iconSize = dimensoes['iconL'] ?? 40.0;
    final innerIconSize = dimensoes['iconS'] ?? 20.0;

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: taskInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(dimensoes['radiusS'] ?? 8.0),
      ),
      child: Icon(
        taskInfo.icon,
        color: taskInfo.color,
        size: innerIconSize,
      ),
    );
  }

  Widget _buildTaskInfo(TaskInfo taskInfo, Map<String, TextStyle> estilos,
      Map<String, Color> cores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          taskInfo.title,
          style: (estilos['labelLarge'] ?? const TextStyle()).copyWith(
            color: taskInfo.isOverdue ? cores['erro'] : cores['texto'],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (taskInfo.dateText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            taskInfo.dateText,
            style: (estilos['bodySmall'] ?? const TextStyle(fontSize: 12))
                .copyWith(
              color:
                  taskInfo.isOverdue ? cores['erro'] : cores['textoSecundario'],
            ),
          ),
        ],
        if (showObservacoes &&
            observacoes != null &&
            observacoes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            observacoes!,
            style: (estilos['bodySmall'] ?? const TextStyle(fontSize: 12))
                .copyWith(
              color: cores['textoSecundario'],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTaskActions(
      Map<String, Color> cores, Map<String, double> dimensoes) {
    final actionSize = dimensoes['iconL'] ?? 32.0;
    final iconSize = dimensoes['iconS'] ?? 16.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCompleteButton && onComplete != null)
          IconButton(
            onPressed: onComplete,
            icon: Icon(
              Icons.check_circle_outline,
              color: cores['sucesso'] ?? Colors.green,
              size: iconSize,
            ),
            constraints: BoxConstraints(
              minWidth: actionSize,
              minHeight: actionSize,
            ),
            padding: EdgeInsets.zero,
            tooltip: 'Marcar como concluída',
          ),
        if (showRescheduleButton && onReschedule != null)
          IconButton(
            onPressed: onReschedule,
            icon: Icon(
              Icons.schedule,
              color: cores['aviso'] ?? Colors.orange,
              size: iconSize,
            ),
            constraints: BoxConstraints(
              minWidth: actionSize,
              minHeight: actionSize,
            ),
            padding: EdgeInsets.zero,
            tooltip: 'Reagendar tarefa',
          ),
      ],
    );
  }

  // Métodos estáticos para extrair dados dos diferentes modelos
  static String? _extractTipoCuidado(dynamic tarefa) {
    if (tarefa == null) return null;

    // Tentar diferentes propriedades comuns
    if (tarefa is Map) {
      return tarefa['tipoCuidado'] ?? tarefa['tipo'] ?? tarefa['type'];
    }

    // Usar reflection para modelos tipados
    try {
      if (tarefa.runtimeType.toString().contains('Tarefa')) {
        // Para TarefaModel
        return tarefa.tipoCuidado;
      }
    } catch (e) {
      // Ignorar erros de reflection
    }

    return null;
  }

  static DateTime? _extractDataExecucao(dynamic tarefa) {
    if (tarefa == null) return null;

    if (tarefa is Map) {
      return tarefa['dataExecucao'] ?? tarefa['dataLimite'] ?? tarefa['date'];
    }

    try {
      if (tarefa.runtimeType.toString().contains('Tarefa')) {
        return tarefa.dataExecucao;
      }
    } catch (e) {
      // Ignorar erros de reflection
    }

    return null;
  }

  static String? _extractObservacoes(dynamic tarefa) {
    if (tarefa == null) return null;

    if (tarefa is Map) {
      return tarefa['observacoes'] ?? tarefa['notes'] ?? tarefa['description'];
    }

    try {
      if (tarefa.runtimeType.toString().contains('Tarefa')) {
        return tarefa.observacoes;
      }
    } catch (e) {
      // Ignorar erros de reflection
    }

    return null;
  }

  // Métodos para compatibilidade com controllers existentes
  static void _handleTap(dynamic controller, dynamic tarefa) {
    // Implementar baseado no tipo de controller
    // Por enquanto, não fazer nada
  }

  static void _handleComplete(dynamic controller, dynamic tarefa) {
    try {
      // Tentar chamar método de conclusão
      if (controller?.marcarTarefaConcluida != null) {
        controller.marcarTarefaConcluida(tarefa);
      }
    } catch (e) {
      // Fallback para mostrar um snackbar
      Get.snackbar('Erro', 'Não foi possível marcar a tarefa como concluída');
    }
  }

  static void _handleReschedule(dynamic controller, dynamic tarefa) {
    try {
      // Implementar reagendamento básico
      _showRescheduleDialog(controller, tarefa);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível reagendar a tarefa');
    }
  }

  static Future<void> _showRescheduleDialog(
      dynamic controller, dynamic tarefa) async {
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
      try {
        if (controller?.reagendarTarefa != null) {
          await controller.reagendarTarefa(tarefa, novaData);
        }
      } catch (e) {
        Get.snackbar('Erro', 'Não foi possível reagendar a tarefa');
      }
    }
  }

  // Métodos para cores, dimensões e estilos padrão
  Map<String, Color> _getDefaultColors(BuildContext context) {
    final theme = Theme.of(context);
    return {
      'erro': Colors.red,
      'erroClaro': Colors.red.withValues(alpha: 0.1),
      'fundoCard': theme.cardColor,
      'borda': theme.dividerColor,
      'texto': theme.textTheme.bodyMedium?.color ?? Colors.black,
      'textoSecundario': theme.textTheme.bodySmall?.color ?? Colors.grey,
      'sucesso': Colors.green,
      'aviso': Colors.orange,
    };
  }

  Map<String, double> _getDefaultDimensions() {
    return {
      'marginS': 8.0,
      'paddingM': 12.0,
      'paddingS': 8.0,
      'paddingXS': 4.0,
      'radiusS': 8.0,
      'iconL': 40.0,
      'iconS': 20.0,
    };
  }

  Map<String, TextStyle> _getDefaultTextStyles(BuildContext context) {
    final theme = Theme.of(context);
    return {
      'labelLarge': theme.textTheme.labelLarge ??
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      'bodySmall': theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
    };
  }
}
