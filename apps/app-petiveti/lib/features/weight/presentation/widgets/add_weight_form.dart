import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/domain/entities/animal_enums.dart';
import '../../../animals/presentation/providers/animals_provider.dart';
import '../../domain/entities/weight.dart';
import '../providers/weights_provider.dart';

class AddWeightForm extends ConsumerStatefulWidget {
  final Weight? weight; // For editing
  final String? initialAnimalId;
  
  const AddWeightForm({
    super.key,
    this.weight,
    this.initialAnimalId,
  });

  @override
  ConsumerState<AddWeightForm> createState() => _AddWeightFormState();
}

class _AddWeightFormState extends ConsumerState<AddWeightForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  Animal? _selectedAnimal;
  DateTime _selectedDate = DateTime.now();
  int? _bodyConditionScore;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.weight != null) {
      // Editing mode
      final weight = widget.weight!;
      _weightController.text = weight.weight.toString();
      _notesController.text = weight.notes ?? '';
      _selectedDate = weight.date;
      _bodyConditionScore = weight.bodyConditionScore;
    }

    // Load animals for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsProvider.notifier).loadAnimals();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalsState = ref.watch(animalsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weight != null ? 'Editar Peso' : 'Novo Registro'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveWeight,
            child: Text(
              'Salvar',
              style: TextStyle(
                color: _isLoading ? theme.disabledColor : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Animal Selection
            PetiVetiFormComponents.animalRequired(
              value: _selectedAnimal?.id,
              onChanged: (animalId) {
                final animal = animalsState.animals.firstWhere((a) => a.id == animalId);
                setState(() {
                  _selectedAnimal = animal;
                });
              },
            ),
            const SizedBox(height: 24),

            // Weight Input
            Text(
              'Peso',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: 'Ex: 5.5',
                prefixIcon: const Icon(Icons.monitor_weight),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Peso é obrigatório';
                }
                
                final weight = double.tryParse(value.trim());
                if (weight == null) {
                  return 'Digite um peso válido';
                }
                
                if (weight <= 0) {
                  return 'Peso deve ser maior que zero';
                }
                
                if (weight > 200) {
                  return 'Peso muito alto. Verifique o valor';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date Selection
            DateTimePickerField.date(
              value: _selectedDate,
              onChanged: (date) {
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              label: 'Data do Registro',
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 24),

            // Body Condition Score
            Text(
              'Condição Corporal (Opcional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escala de 1 a 9, onde 1 = muito magro, 5 = ideal, 9 = obeso',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Muito Magro',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        'Ideal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Obeso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: _bodyConditionScore?.toDouble() ?? 0,
                      min: 0,
                      max: 9,
                      divisions: 9,
                      label: _bodyConditionScore != null 
                          ? _bodyConditionScore.toString() 
                          : 'Não informado',
                      onChanged: (value) {
                        setState(() {
                          _bodyConditionScore = value == 0 ? null : value.round();
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(10, (index) {
                      if (index == 0) {
                        return Text(
                          'N/A',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        );
                      }
                      return Text(
                        index.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _bodyConditionScore == index 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withAlpha(153),
                          fontWeight: _bodyConditionScore == index 
                              ? FontWeight.bold 
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            PetiVetiFormComponents.notesGeneral(
              controller: _notesController,
              isRequired: false,
            ),
            const SizedBox(height: 32),

            // Save Button
            widget.weight != null
                ? PetiVetiFormComponents.submitUpdate(
                    onSubmit: _saveWeight,
                    isLoading: _isLoading,
                  )
                : PetiVetiFormComponents.submitCreate(
                    onSubmit: _saveWeight,
                    isLoading: _isLoading,
                    itemName: 'Registro de Peso',
                  ),
            const SizedBox(height: 16),

            // Quick weight suggestions (for new records)
            if (widget.weight == null && _selectedAnimal != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Pesos Comuns para ${_selectedAnimal!.species}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildWeightSuggestions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSuggestions(BuildContext context) {
    if (_selectedAnimal == null) return const SizedBox.shrink();
    
    List<double> suggestions = [];
    
    switch (_selectedAnimal!.species) {
      case AnimalSpecies.dog:
        suggestions = [2.5, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0];
        break;
      case AnimalSpecies.cat:
        suggestions = [2.0, 3.0, 4.0, 5.0, 6.0, 7.0];
        break;
      default:
        suggestions = [1.0, 2.0, 5.0, 10.0];
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((weight) {
        return ActionChip(
          label: Text('${weight}kg'),
          onPressed: () {
            _weightController.text = weight.toString();
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(127),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimal == null) return;

    setState(() => _isLoading = true);

    try {
      final weightValue = double.parse(_weightController.text.trim());
      
      final weight = Weight(
        id: widget.weight?.id ?? UuidGenerator.generate(),
        animalId: _selectedAnimal!.id,
        weight: weightValue,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        bodyConditionScore: _bodyConditionScore,
        createdAt: widget.weight?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.weight != null) {
        await ref.read(weightsProvider.notifier).updateWeight(weight);
      } else {
        await ref.read(weightsProvider.notifier).addWeight(weight);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.weight != null 
                ? 'Registro de peso atualizado com sucesso' 
                : 'Registro de peso adicionado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar registro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getDateSubtitle() {
    final now = DateTime.now();
    final difference = now.difference(_selectedDate).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '$difference dias atrás';
    } else {
      return 'Há ${(difference / 7).floor()} semanas';
    }
  }
}