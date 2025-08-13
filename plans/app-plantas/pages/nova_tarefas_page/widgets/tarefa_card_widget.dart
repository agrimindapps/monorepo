// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_repository.dart';
import '../controller/nova_tarefas_controller.dart';
import '../services/care_type_service.dart';
import 'tarefa_details_dialog.dart';

class TarefaCardWidget extends StatefulWidget {
  final TarefaModel tarefa;
  final NovaTarefasController controller;
  final bool isCompleted;

  const TarefaCardWidget({
    super.key,
    required this.tarefa,
    required this.controller,
    this.isCompleted = false,
  });

  @override
  State<TarefaCardWidget> createState() => _TarefaCardWidgetState();
}

class _TarefaCardWidgetState extends State<TarefaCardWidget> {
  PlantaModel? planta;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlantaInfo();
  }

  Future<void> _loadPlantaInfo() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();

      final result = await Future.any([
        plantaRepo.findById(widget.tarefa.plantaId),
        Future.delayed(const Duration(seconds: 10),
            () => throw TimeoutException('Timeout'))
      ]);

      if (mounted) {
        setState(() {
          planta = result;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Timeout')) {
      return 'Tempo limite excedido';
    } else if (error.toString().contains('Database')) {
      return 'Erro no banco de dados';
    } else if (error.toString().contains('Connection')) {
      return 'Erro de conexão';
    } else {
      return 'Erro ao carregar dados da planta';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.green;
    final backgroundColor = PlantasColors.surfaceColor;
    final textColor = PlantasColors.textColor;
    final secondaryTextColor = PlantasColors.textSecondaryColor;
    const lightTextColor = Colors.white;
    final cardShadow = [
      BoxShadow(
          color: PlantasColors.shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 2))
    ];

    final cor = widget.controller
        .getCorParaTipoCuidado(widget.tarefa.tipoCuidado, context);
    final icone =
        widget.controller.getIconeParaTipoCuidado(widget.tarefa.tipoCuidado);

    return GestureDetector(
      onTap: widget.isCompleted ? null : () => _showTaskDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: widget.isCompleted
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: secondaryTextColor.withValues(alpha: 0.3), width: 1),
              )
            : BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: cardShadow,
              ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Icon(
                      icone,
                      color: widget.isCompleted ? secondaryTextColor : cor,
                      size: 24,
                    ),
                    if (widget.isCompleted)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: lightTextColor,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CareTypeService.getName(widget.tarefa.tipoCuidado),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.isCompleted
                              ? secondaryTextColor
                              : textColor,
                          decoration: widget.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      _buildPlantInfo(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildPlantIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
    const primaryColor = Colors.green;
    final secondaryTextColor = PlantasColors.textSecondaryColor;
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              size: 14,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                errorMessage ?? 'Erro ao carregar',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            GestureDetector(
              onTap: _loadPlantaInfo,
              child: const Icon(
                Icons.refresh,
                size: 14,
                color: primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (planta != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 14,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              planta?.nome ?? 'Planta sem nome',
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
                decoration:
                    widget.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TarefaDetailsDialog(
        tarefa: widget.tarefa,
        controller: widget.controller,
      ),
    );
  }

  Widget _buildPlantIcon() {
    return Builder(
      builder: (context) {
        const primaryColor = Colors.green;
        final secondaryTextColor = PlantasColors.textSecondaryColor;

        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? secondaryTextColor.withValues(alpha: 0.2)
                : primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.eco,
            color: widget.isCompleted ? secondaryTextColor : primaryColor,
            size: 28,
          ),
        );
      },
    );
  }
}
