import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/medication_dosage_input.dart';
import '../providers/medication_dosage_provider.dart';

/// Formulário de entrada de dados para cálculo de dosagem
class MedicationDosageInputForm extends StatefulWidget {
  const MedicationDosageInputForm({super.key});

  @override
  State<MedicationDosageInputForm> createState() =>
      _MedicationDosageInputFormState();
}

class _MedicationDosageInputFormState extends State<MedicationDosageInputForm> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _concentrationController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _concentrationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(medicationDosageProviderProvider);
        _updateControllers(provider);

        return Column(
          children: [
            _buildAnimalDataSection(provider),
            const SizedBox(height: 16),
            if (provider.selectedMedication != null) ...[
              _buildMedicationConfigSection(provider),
              const SizedBox(height: 16),
            ],
            _buildSpecialConditionsSection(provider),
            const SizedBox(height: 16),
            _buildNotesSection(provider),
          ],
        );
      },
    );
  }

  void _updateControllers(MedicationDosageProvider provider) {
    if (_weightController.text != provider.input.weight.toString()) {
      _weightController.text = provider.input.weight.toString();
    }

    final concentration = provider.input.concentration?.toString() ?? '';
    if (_concentrationController.text != concentration) {
      _concentrationController.text = concentration;
    }

    final notes = provider.input.veterinarianNotes ?? '';
    if (_notesController.text != notes) {
      _notesController.text = notes;
    }
  }

  Widget _buildAnimalDataSection(MedicationDosageProvider provider) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Dados do Animal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Espécie *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Species>(
                        value: provider.input.species,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            Species.values.map((species) {
                              return DropdownMenuItem(
                                value: species,
                                child: Row(
                                  children: [
                                    Icon(
                                      species == Species.dog
                                          ? Icons.pets
                                          : Icons.pets,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(species.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (species) {
                          if (species != null) {
                            provider.updateSpecies(species);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peso (kg) *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixText: 'kg',
                          hintText: '0.0',
                        ),
                        onChanged: (value) {
                          final weight = double.tryParse(value);
                          if (weight != null && weight > 0 && weight <= 100) {
                            provider.updateWeight(weight);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grupo de Idade *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AgeGroup>(
                  value: provider.input.ageGroup,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items:
                      AgeGroup.values.map((ageGroup) {
                        return DropdownMenuItem(
                          value: ageGroup,
                          child: Text(ageGroup.displayName),
                        );
                      }).toList(),
                  onChanged: (ageGroup) {
                    if (ageGroup != null) {
                      provider.updateAgeGroup(ageGroup);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationConfigSection(MedicationDosageProvider provider) {
    final medication = provider.selectedMedication!;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Configuração do Medicamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Icon(Icons.medication, color: Colors.red.shade600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        Text(
                          '${medication.category} • ${medication.activeIngredient}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (medication.concentrations.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Concentração',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<double>(
                          value: provider.input.concentration,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items:
                              medication.concentrations.map((concentration) {
                                return DropdownMenuItem(
                                  value: concentration.value,
                                  child: Text(concentration.description),
                                );
                              }).toList(),
                          onChanged: provider.updateConcentration,
                          hint: const Text('Selecionar'),
                        ),
                      ],
                    ),
                  ),

                if (medication.concentrations.isNotEmpty)
                  const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequência *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AdministrationFrequency>(
                        value: provider.input.frequency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            medication.recommendedFrequencies.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(frequency.displayName),
                              );
                            }).toList(),
                        onChanged: (frequency) {
                          if (frequency != null) {
                            provider.updateFrequency(frequency);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (medication.pharmaceuticalForms.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Forma Farmacêutica',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: provider.input.pharmaceuticalForm,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items:
                        medication.pharmaceuticalForms.map((form) {
                          return DropdownMenuItem(
                            value: form,
                            child: Text(form),
                          );
                        }).toList(),
                    onChanged: provider.updatePharmaceuticalForm,
                    hint: const Text('Selecionar forma'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            CheckboxListTile(
              title: const Text('Situação de Emergência'),
              subtitle: const Text(
                'Marque se for uma situação de emergência (pode usar dosagem mais alta)',
                style: TextStyle(fontSize: 12),
              ),
              value: provider.input.isEmergency,
              onChanged: (value) {
                if (value != null) {
                  provider.updateEmergencyFlag(value);
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialConditionsSection(MedicationDosageProvider provider) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Condições Especiais',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione todas as condições que se aplicam ao animal:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: SpecialCondition.values.length,
              itemBuilder: (context, index) {
                final condition = SpecialCondition.values[index];
                final isSelected = provider.input.specialConditions.contains(
                  condition,
                );

                return FilterChip(
                  label: Text(
                    condition.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.addSpecialCondition(condition);
                    } else {
                      provider.removeSpecialCondition(condition);
                    }
                  },
                  selectedColor: _getConditionColor(condition),
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(MedicationDosageProvider provider) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Notas Adicionais',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText:
                    'Observações do veterinário, histórico médico relevante, etc.',
              ),
              onChanged: provider.updateVeterinarianNotes,
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(SpecialCondition condition) {
    switch (condition) {
      case SpecialCondition.healthy:
        return Colors.green.shade600;
      case SpecialCondition.renalDisease:
      case SpecialCondition.hepaticDisease:
      case SpecialCondition.heartDisease:
        return Colors.red.shade600;
      case SpecialCondition.diabetes:
        return Colors.purple.shade600;
      case SpecialCondition.pregnant:
      case SpecialCondition.lactating:
        return Colors.pink.shade600;
      case SpecialCondition.geriatric:
        return Colors.orange.shade600;
    }
  }
}
