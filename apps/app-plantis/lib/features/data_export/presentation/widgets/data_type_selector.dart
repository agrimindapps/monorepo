import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/export_request.dart';

/// Widget for selecting data types to export in Plantis
class DataTypeSelector extends StatefulWidget {
  final Set<DataType> selectedDataTypes;
  final Function(Set<DataType>) onSelectionChanged;
  final Map<DataType, int>? dataStatistics;

  const DataTypeSelector({
    super.key,
    required this.selectedDataTypes,
    required this.onSelectionChanged,
    this.dataStatistics,
  });

  @override
  State<DataTypeSelector> createState() => _DataTypeSelectorState();
}

class _DataTypeSelectorState extends State<DataTypeSelector> {
  late Set<DataType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedDataTypes);
  }

  void _toggleDataType(DataType dataType) {
    setState(() {
      if (_selectedTypes.contains(dataType)) {
        _selectedTypes.remove(dataType);
      } else {
        _selectedTypes.add(dataType);
      }
    });
    widget.onSelectionChanged(_selectedTypes);
  }

  void _selectAll() {
    setState(() {
      _selectedTypes = {
        DataType.plants,
        DataType.plantTasks,
        DataType.spaces,
        DataType.plantPhotos,
        DataType.plantComments,
        DataType.settings,
        DataType.customCare,
        DataType.reminders,
        DataType.userProfile,
      };
    });
    widget.onSelectionChanged(_selectedTypes);
  }

  void _selectNone() {
    setState(() {
      _selectedTypes.clear();
    });
    widget.onSelectionChanged(_selectedTypes);
  }

  IconData _getDataTypeIcon(DataType dataType) {
    switch (dataType) {
      case DataType.plants:
        return Icons.eco;
      case DataType.plantTasks:
        return Icons.task_alt;
      case DataType.spaces:
        return Icons.home_work;
      case DataType.plantPhotos:
        return Icons.photo_library;
      case DataType.plantComments:
        return Icons.comment;
      case DataType.settings:
        return Icons.settings;
      case DataType.customCare:
        return Icons.spa;
      case DataType.reminders:
        return Icons.notifications_active;
      case DataType.userProfile:
        return Icons.person;
      case DataType.all:
        return Icons.select_all;
    }
  }

  Color _getDataTypeColor(DataType dataType) {
    switch (dataType) {
      case DataType.plants:
        return PlantisColors.leaf;
      case DataType.plantTasks:
        return PlantisColors.primary;
      case DataType.spaces:
        return PlantisColors.secondary;
      case DataType.plantPhotos:
        return PlantisColors.accent;
      case DataType.plantComments:
        return Colors.purple;
      case DataType.settings:
        return Colors.grey[600]!;
      case DataType.customCare:
        return PlantisColors.sun;
      case DataType.reminders:
        return Colors.orange;
      case DataType.userProfile:
        return Colors.blue;
      case DataType.all:
        return PlantisColors.primary;
    }
  }

  String _getDataTypeDescription(DataType dataType) {
    switch (dataType) {
      case DataType.plants:
        return 'Todas as suas plantas cadastradas';
      case DataType.plantTasks:
        return 'Tarefas e lembretes das plantas';
      case DataType.spaces:
        return 'Espaços organizacionais criados';
      case DataType.plantPhotos:
        return 'Fotos das suas plantas (apenas metadados)';
      case DataType.plantComments:
        return 'Comentários e observações sobre plantas';
      case DataType.settings:
        return 'Configurações pessoais do aplicativo';
      case DataType.customCare:
        return 'Cuidados personalizados criados por você';
      case DataType.reminders:
        return 'Lembretes e notificações ativas';
      case DataType.userProfile:
        return 'Informações básicas do perfil';
      case DataType.all:
        return 'Todos os tipos de dados disponíveis';
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = [
      DataType.plants,
      DataType.plantTasks,
      DataType.spaces,
      DataType.plantPhotos,
      DataType.plantComments,
      DataType.customCare,
      DataType.reminders,
      DataType.settings,
      DataType.userProfile,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with selection controls
        Row(
          children: [
            Text(
              'Tipos de Dados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _selectAll,
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Todos'),
              style: TextButton.styleFrom(
                foregroundColor: PlantisColors.primary,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: _selectNone,
              icon: const Icon(Icons.deselect, size: 16),
              label: const Text('Nenhum'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Selection summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                _selectedTypes.isEmpty
                    ? Colors.orange.withAlpha(20)
                    : PlantisColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _selectedTypes.isEmpty
                      ? Colors.orange.withAlpha(60)
                      : PlantisColors.primary.withAlpha(60),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _selectedTypes.isEmpty ? Icons.warning : Icons.check_circle,
                color:
                    _selectedTypes.isEmpty
                        ? Colors.orange
                        : PlantisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedTypes.isEmpty
                      ? 'Selecione pelo menos um tipo de dados para exportar'
                      : '${_selectedTypes.length} tipos de dados selecionados',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        _selectedTypes.isEmpty
                            ? Colors.orange
                            : PlantisColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Data type list
        Column(
          children:
              availableTypes.map((dataType) {
                final isSelected = _selectedTypes.contains(dataType);
                final color = _getDataTypeColor(dataType);
                final count = widget.dataStatistics?[dataType];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleDataType(dataType),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? color.withAlpha(30)
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? color.withAlpha(100)
                                    : Theme.of(
                                      context,
                                    ).colorScheme.outline.withAlpha(100),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? color.withAlpha(50)
                                        : color.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getDataTypeIcon(dataType),
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dataType.displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (count != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withAlpha(30),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDataTypeDescription(dataType),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? color : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child:
                                  isSelected
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
