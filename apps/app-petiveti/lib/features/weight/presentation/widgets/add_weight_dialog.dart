import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/domain/entities/animal_enums.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/weight.dart';
import '../providers/weights_provider.dart';

class AddWeightDialog extends ConsumerStatefulWidget {
  final Weight? weight;
  final String? initialAnimalId;

  const AddWeightDialog({super.key, this.weight, this.initialAnimalId});

  @override
  ConsumerState<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends ConsumerState<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  Animal? _selectedAnimal;
  DateTime _selectedDate = DateTime.now();
  int? _bodyConditionScore;
  bool _isLoading = false;

  bool get _isEditing => widget.weight != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.weight != null) {
      final weight = widget.weight!;
      _weightController.text = weight.weight.toString();
      _notesController.text = weight.notes ?? '';
      _selectedDate = weight.date;
      _bodyConditionScore = weight.bodyConditionScore;
    }
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

    // Set selected animal from initial data
    if (_selectedAnimal == null && animalsState.animals.isNotEmpty) {
      final initialId = widget.weight?.animalId ?? widget.initialAnimalId;
      if (initialId != null) {
        for (final animal in animalsState.animals) {
          if (animal.id == initialId) {
            _selectedAnimal = animal;
            break;
          }
        }
      }
    }

    return PetFormDialog(
      title: 'Peso',
      subtitle: 'Acompanhe o peso do seu pet',
      headerIcon: Icons.monitor_weight,
      isLoading: _isLoading,
      confirmButtonText: _isEditing ? 'Salvar' : 'Cadastrar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(),
            const SizedBox(height: 16),
            _buildAnimalSection(animalsState.animals),
            _buildWeightSection(),
            _buildDateSection(),
            _buildBodyConditionSection(theme),
            _buildNotesSection(),
            if (!_isEditing && _selectedAnimal != null)
              _buildSuggestionsSection(theme),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Peso' : 'Novo Registro',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildAnimalSection(List<Animal> animals) {
    return FormSectionWidget(
      title: 'Animal',
      icon: Icons.pets,
      children: [
        PetiVetiFormComponents.animalRequired(
          value: _selectedAnimal?.id,
          onChanged: (animalId) {
            Animal? animal;
            for (final a in animals) {
              if (a.id == animalId) {
                animal = a;
                break;
              }
            }
            setState(() => _selectedAnimal = animal);
          },
        ),
      ],
    );
  }

  Widget _buildWeightSection() {
    return FormSectionWidget(
      title: 'Peso',
      icon: Icons.monitor_weight,
      children: [
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Peso *',
            hintText: 'Ex: 5.5',
            suffixText: 'kg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Peso é obrigatório';
            }
            final weight = double.tryParse(value.trim());
            if (weight == null) return 'Digite um peso válido';
            if (weight <= 0) return 'Peso deve ser maior que zero';
            if (weight > 200) return 'Peso muito alto. Verifique o valor';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return FormSectionWidget(
      title: 'Data',
      icon: Icons.calendar_today,
      children: [
        DateTimePickerField.date(
          value: _selectedDate,
          label: 'Data do Registro',
          onChanged: (date) {
            if (date != null) setState(() => _selectedDate = date);
          },
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildBodyConditionSection(ThemeData theme) {
    return FormSectionWidget(
      title: 'Condição Corporal (Opcional)',
      icon: Icons.health_and_safety,
      children: [
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
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
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
      ],
    );
  }

  Widget _buildNotesSection() {
    return FormSectionWidget(
      title: 'Observações',
      icon: Icons.notes,
      children: [
        PetiVetiFormComponents.notesGeneral(
          controller: _notesController,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
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

    return FormSectionWidget(
      title: 'Pesos Comuns para ${_selectedAnimal!.species.displayName}',
      icon: Icons.lightbulb_outline,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((weight) {
            return ActionChip(
              label: Text('${weight}kg'),
              onPressed: () => _weightController.text = weight.toString(),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: theme.colorScheme.outline.withAlpha(127),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return _isEditing
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _saveWeight,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isLoading,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _saveWeight,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isLoading,
            itemName: 'Registro de Peso',
          );
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
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
            content: Text(
              widget.weight != null
                  ? 'Registro de peso atualizado com sucesso'
                  : 'Registro de peso adicionado com sucesso',
            ),
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
}
