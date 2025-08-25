import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../plants/presentation/providers/plants_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';

class TasksFab extends StatelessWidget {
  const TasksFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () => _showAddTaskBottomSheet(context),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text('Nova Tarefa'),
      elevation: 6,
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ChangeNotifierProvider.value(
            value: Provider.of<TasksProvider>(context, listen: false),
            child: _AddTaskBottomSheet(),
          ),
    );
  }
}

class _AddTaskBottomSheet extends StatefulWidget {
  @override
  State<_AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<_AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTaskType = 'watering';
  String _selectedPriority = 'medium';
  DateTime? _selectedDate;
  String? _selectedPlantId;
  bool _isCreatingTask = false;

  final List<Map<String, dynamic>> _taskTypes = [
    {'value': 'watering', 'label': 'Rega', 'icon': Icons.water_drop},
    {'value': 'fertilizing', 'label': 'Adubação', 'icon': Icons.eco},
    {'value': 'pruning', 'label': 'Poda', 'icon': Icons.content_cut},
    {'value': 'repotting', 'label': 'Transplante', 'icon': Icons.change_circle},
    {'value': 'inspection', 'label': 'Inspeção', 'icon': Icons.search},
    {'value': 'other', 'label': 'Outro', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Baixa', 'color': Colors.green},
    {'value': 'medium', 'label': 'Média', 'color': Colors.blue},
    {'value': 'high', 'label': 'Alta', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgente', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Nova Tarefa',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título da Tarefa',
                      hintText: 'Ex: Regar violeta africana',
                      prefixIcon: Icon(Icons.task_alt),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o título da tarefa';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Descrição (opcional)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      hintText: 'Detalhes sobre a tarefa...',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Planta - carregada dinamicamente
                  Consumer<PlantsProvider>(
                    builder: (context, plantsProvider, child) {
                      final plants = plantsProvider.plants;

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Planta',
                          prefixIcon: Icon(Icons.local_florist),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPlantId,
                        hint: const Text('Selecione uma planta'),
                        items:
                            plants.map((plant) {
                              return DropdownMenuItem<String>(
                                value: plant.id,
                                child: Text(plant.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPlantId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione uma planta';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tipo de tarefa
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Tarefa',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTaskType,
                    items:
                        _taskTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['value'] as String?,
                            child: Row(
                              children: [
                                Icon(type['icon'] as IconData?, size: 20),
                                const SizedBox(width: 8),
                                Text(type['label'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTaskType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Prioridade
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Prioridade',
                      prefixIcon: Icon(Icons.priority_high),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPriority,
                    items:
                        _priorities.map((priority) {
                          return DropdownMenuItem<String>(
                            value: priority['value'] as String?,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: priority['color'] as Color?,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(priority['label'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Data de vencimento
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Vencimento',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Selecione uma data',
                        style:
                            _selectedDate != null
                                ? null
                                : TextStyle(color: theme.hintColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCreatingTask ? null : _saveTask,
                          child:
                              _isCreatingTask
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Salvar Tarefa'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data de vencimento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingTask = true;
    });

    try {
      // Buscar dados da planta selecionada
      final plantsProvider = Provider.of<PlantsProvider>(
        context,
        listen: false,
      );
      final plant = plantsProvider.plants.firstWhere(
        (p) => p.id == _selectedPlantId!,
      );

      // Mapear tipo de tarefa para TaskType
      TaskType mapTaskType(String value) {
        switch (value) {
          case 'watering':
            return TaskType.watering;
          case 'fertilizing':
            return TaskType.fertilizing;
          case 'pruning':
            return TaskType.pruning;
          case 'repotting':
            return TaskType.repotting;
          case 'inspection':
            return TaskType.pestInspection;
          case 'other':
            return TaskType.custom;
          default:
            return TaskType.custom;
        }
      }

      // Mapear prioridade para TaskPriority
      TaskPriority mapPriority(String value) {
        switch (value) {
          case 'low':
            return TaskPriority.low;
          case 'medium':
            return TaskPriority.medium;
          case 'high':
            return TaskPriority.high;
          case 'urgent':
            return TaskPriority.urgent;
          default:
            return TaskPriority.medium;
        }
      }

      // Criar task entity
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: true,
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        plantId: plant.id,
        plantName: plant.name,
        type: mapTaskType(_selectedTaskType),
        status: TaskStatus.pending,
        priority: mapPriority(_selectedPriority),
        dueDate: _selectedDate!,
      );

      // Salvar usando o provider
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      final success = await tasksProvider.addTask(task);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarefa "${task.title}" criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao criar tarefa: ${tasksProvider.errorMessage ?? 'Erro desconhecido'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTask = false;
        });
      }
    }
  }
}
