// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../../database/planta_model.dart';

class TaskItemWidget extends StatelessWidget {
  final Map<String, dynamic> tarefa;
  final PlantaModel planta;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const TaskItemWidget({
    super.key,
    required this.tarefa,
    required this.planta,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final tipoTarefa =
        (tarefa['tipo'] ?? tarefa['tipoCuidado'] ?? '') as String;
    final dataLimite =
        (tarefa['dataLimite'] ?? tarefa['dataExecucao']) as DateTime?;
    final isOverdue = dataLimite != null && dataLimite.isBefore(DateTime.now());

    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    final decorations = PlantasDesignTokens.decorations(context);
    final textStyles = PlantasDesignTokens.textStyles(context);

    return Container(
      margin: EdgeInsets.only(bottom: dimensoes['marginS']!),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dimensoes['radiusS']!),
          child: Container(
            padding: EdgeInsets.all(dimensoes['paddingM']!),
            decoration: BoxDecoration(
              border: Border.all(
                color: isOverdue
                    ? cores['erro']!.withValues(alpha: 0.3)
                    : cores['borda']!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(dimensoes['radiusS']!),
              color: isOverdue ? cores['erroClaro']! : cores['fundoCard']!,
            ),
            child: Row(
              children: [
                Container(
                  width: dimensoes['iconL']!,
                  height: dimensoes['iconL']!,
                  decoration: BoxDecoration(
                    color: _getTaskColor(tipoTarefa).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(dimensoes['radiusS']!),
                  ),
                  child: Icon(
                    _getTaskIcon(tipoTarefa),
                    color: _getTaskColor(tipoTarefa),
                    size: dimensoes['iconS']!,
                  ),
                ),
                SizedBox(width: dimensoes['paddingM']!),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTaskTitle(tipoTarefa),
                        style: textStyles['labelLarge']!.copyWith(
                          color: isOverdue ? cores['erro'] : cores['texto'],
                        ),
                      ),
                      SizedBox(height: dimensoes['paddingXS']!),
                      if (dataLimite != null)
                        Text(
                          isOverdue
                              ? 'Atrasado desde ${DateFormat('dd/MM').format(dataLimite)}'
                              : 'Até ${DateFormat('dd/MM').format(dataLimite)}',
                          style: textStyles['bodySmall']!.copyWith(
                            color: isOverdue
                                ? cores['erro']
                                : cores['textoSecundario'],
                          ),
                        ),
                    ],
                  ),
                ),
                if (onComplete != null)
                  IconButton(
                    onPressed: onComplete,
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: cores['sucesso'],
                      size: dimensoes['iconS']!,
                    ),
                    constraints: BoxConstraints(
                      minWidth: dimensoes['iconL']!,
                      minHeight: dimensoes['iconL']!,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTaskIcon(String tipo) {
    switch (tipo) {
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

  Color _getTaskColor(String tipo) {
    switch (tipo) {
      case 'agua':
        return Colors.blue;
      case 'adubo':
        return Colors.green;
      case 'banho_sol':
        return Colors.orange;
      case 'pragas':
        return Colors.purple;
      case 'poda':
        return Colors.pink;
      case 'replante':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getTaskTitle(String tipo) {
    switch (tipo) {
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
}
