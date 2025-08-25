// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../../database/planta_model.dart';
import '../interfaces/plantas_controller_interface.dart';
import 'plant_actions_menu.dart';
import 'plant_header_widget.dart';
import 'task_status_widget.dart';

class PlantCardWidget extends StatefulWidget {
  final PlantaModel planta;
  final IPlantasController controller;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const PlantCardWidget({
    super.key,
    required this.planta,
    required this.controller,
    this.onTap,
    this.onEdit,
    this.onRemove,
  });

  @override
  State<PlantCardWidget> createState() => _PlantCardWidgetState();
}

class _PlantCardWidgetState extends State<PlantCardWidget>
    with AutomaticKeepAliveClientMixin {
  // Cache para evitar múltiplas chamadas
  Future<List<Map<String, dynamic>>>? _tarefasFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeTarefas();
  }

  @override
  void didUpdateWidget(PlantCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Só recarrega se a planta mudou
    if (oldWidget.planta.id != widget.planta.id ||
        oldWidget.planta.updatedAt != widget.planta.updatedAt) {
      _initializeTarefas();
    }
  }

  void _initializeTarefas() {
    _tarefasFuture = widget.controller.getTarefasPendentes(widget.planta.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return _PlantCardContent(
      key: ValueKey('plant_card_${widget.planta.id}'),
      planta: widget.planta,
      controller: widget.controller,
      onTap: widget.onTap,
      onEdit: widget.onEdit,
      onRemove: widget.onRemove,
      tarefasFuture: _tarefasFuture!,
    );
  }
}

class _PlantCardContent extends StatelessWidget {
  final PlantaModel planta;
  final IPlantasController controller;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final Future<List<Map<String, dynamic>>> tarefasFuture;

  const _PlantCardContent({
    super.key,
    required this.planta,
    required this.controller,
    required this.tarefasFuture,
    this.onTap,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: tarefasFuture,
      builder: (context, snapshot) {
        final tarefasPendentes = snapshot.data ?? [];

        return _PlantCardUI(
          key: ValueKey('plant_ui_${planta.id}'),
          planta: planta,
          controller: controller,
          tarefasPendentes: tarefasPendentes,
          onTap: onTap,
          onEdit: onEdit,
          onRemove: onRemove,
        );
      },
    );
  }
}

class _PlantCardUI extends StatelessWidget {
  final PlantaModel planta;
  final IPlantasController controller;
  final List<Map<String, dynamic>> tarefasPendentes;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const _PlantCardUI({
    super.key,
    required this.planta,
    required this.controller,
    required this.tarefasPendentes,
    this.onTap,
    this.onEdit,
    this.onRemove,
  });

  // Removed static constants - now using design tokens

  @override
  Widget build(BuildContext context) {
    const dimensoes = PlantasDesignTokens.dimensoes;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: dimensoes['marginS']!,
        vertical: dimensoes['marginS']!,
      ),
      child: Card(
        elevation: dimensoes['elevationS'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensoes['radiusL']!),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dimensoes['radiusL']!),
          child: Padding(
            padding: EdgeInsets.all(dimensoes['paddingM']!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: dimensoes['marginM']),
                _buildTaskStatus(),
                SizedBox(height: dimensoes['marginS']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PlantHeaderWidget(
            key: ValueKey('header_${planta.id}'),
            planta: planta,
            controller: controller,
          ),
        ),
        PlantActionsMenu(
          key: ValueKey('actions_${planta.id}'),
          onEdit: onEdit,
          onRemove: onRemove,
        ),
      ],
    );
  }

  Widget _buildTaskStatus() {
    return TaskStatusWidget(
      key: ValueKey('tasks_${planta.id}_${tarefasPendentes.length}'),
      tarefasPendentes: tarefasPendentes,
    );
  }
}
