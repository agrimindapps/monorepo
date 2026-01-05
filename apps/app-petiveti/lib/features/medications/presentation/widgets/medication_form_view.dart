import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/form_components/form_components.dart';
import '../../domain/entities/medication.dart';
import '../providers/medication_form_notifier.dart';
import '../providers/medication_form_state.dart';

class MedicationFormView extends ConsumerWidget {
  const MedicationFormView({
    required this.animalId,
    required this.formKey,
    required this.isReadOnly,
    super.key,
  });

  final String? animalId;
  final GlobalKey<FormState> formKey;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationFormProvider(animalId));

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimalSelector(context, ref, state),
            const SizedBox(height: 20),
            _buildNameField(context, ref, state),
            const SizedBox(height: 16),
            _buildTypeSelector(context, ref, state),
            const SizedBox(height: 16),
            _buildDosageField(context, ref, state),
            const SizedBox(height: 16),
            _buildFrequencyField(context, ref, state),
            const SizedBox(height: 16),
            _buildDurationField(context, ref, state),
            const SizedBox(height: 16),
            _buildDateSection(context, ref, state),
            const SizedBox(height: 16),
            _buildPrescribedByField(context, ref, state),
            const SizedBox(height: 16),
            _buildNotesField(context, ref, state),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelector(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return PetiVetiFormComponents.animalRequired(
      initialValue: state.animalId,
      onChanged: isReadOnly ? null : (value) {},
    );
  }

  Widget _buildNameField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.name,
      decoration: const InputDecoration(
        labelText: 'Nome do Medicamento',
        border: OutlineInputBorder(),
      ),
      readOnly: isReadOnly,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o nome do medicamento';
        }
        return null;
      },
      onChanged: isReadOnly
          ? null
          : (value) => ref.read(medicationFormProvider(animalId).notifier).updateName(value),
    );
  }

  Widget _buildTypeSelector(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return DropdownButtonFormField<MedicationType>(
      value: state.type,
      decoration: const InputDecoration(
        labelText: 'Tipo',
        border: OutlineInputBorder(),
      ),
      items: MedicationType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getMedicationTypeLabel(type)),
        );
      }).toList(),
      onChanged: isReadOnly
          ? null
          : (value) {
              if (value != null) {
                ref.read(medicationFormProvider(animalId).notifier).updateType(value);
              }
            },
    );
  }

  Widget _buildDosageField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.dosage,
      decoration: const InputDecoration(
        labelText: 'Dosagem',
        border: OutlineInputBorder(),
        hintText: 'Ex: 1 comprimido, 5ml',
      ),
      readOnly: isReadOnly,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a dosagem';
        }
        return null;
      },
      onChanged: isReadOnly
          ? null
          : (value) => ref.read(medicationFormProvider(animalId).notifier).updateDosage(value),
    );
  }

  Widget _buildFrequencyField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.frequency,
      decoration: const InputDecoration(
        labelText: 'Frequência',
        border: OutlineInputBorder(),
        hintText: 'Ex: A cada 8 horas, 2x ao dia',
      ),
      readOnly: isReadOnly,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a frequência';
        }
        return null;
      },
      onChanged: isReadOnly
          ? null
          : (value) =>
              ref.read(medicationFormProvider(animalId).notifier).updateFrequency(value),
    );
  }

  Widget _buildDurationField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.duration,
      decoration: const InputDecoration(
        labelText: 'Duração (opcional)',
        border: OutlineInputBorder(),
        hintText: 'Ex: 7 dias, 2 semanas',
      ),
      readOnly: isReadOnly,
      onChanged: isReadOnly
          ? null
          : (value) =>
              ref.read(medicationFormProvider(animalId).notifier).updateDuration(value),
    );
  }

  Widget _buildDateSection(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período do Tratamento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                ref,
                state,
                'Data de Início',
                state.startDate,
                (date) => ref
                    .read(medicationFormProvider(animalId).notifier)
                    .updateStartDate(date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                context,
                ref,
                state,
                'Data de Término',
                state.endDate,
                (date) =>
                    ref.read(medicationFormProvider(animalId).notifier).updateEndDate(date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    WidgetRef ref,
    MedicationFormState state,
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: isReadOnly
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${date.day}/${date.month}/${date.year}'),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescribedByField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.prescribedBy,
      decoration: const InputDecoration(
        labelText: 'Prescrito por (opcional)',
        border: OutlineInputBorder(),
        hintText: 'Nome do veterinário',
      ),
      readOnly: isReadOnly,
      onChanged: isReadOnly
          ? null
          : (value) =>
              ref.read(medicationFormProvider(animalId).notifier).updatePrescribedBy(value),
    );
  }

  Widget _buildNotesField(BuildContext context, WidgetRef ref, MedicationFormState state) {
    return TextFormField(
      initialValue: state.notes,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        border: OutlineInputBorder(),
        hintText: 'Informações adicionais',
      ),
      maxLines: 3,
      readOnly: isReadOnly,
      onChanged: isReadOnly
          ? null
          : (value) => ref.read(medicationFormProvider(animalId).notifier).updateNotes(value),
    );
  }

  String _getMedicationTypeLabel(MedicationType type) {
    switch (type) {
      case MedicationType.antibiotic:
        return 'Antibiótico';
      case MedicationType.antiInflammatory:
        return 'Anti-inflamatório';
      case MedicationType.painkiller:
        return 'Analgésico';
      case MedicationType.antiparasitic:
        return 'Antiparasitário';
      case MedicationType.vitamin:
        return 'Vitamina';
      case MedicationType.supplement:
        return 'Suplemento';
      case MedicationType.other:
        return 'Outro';
    }
  }
}
