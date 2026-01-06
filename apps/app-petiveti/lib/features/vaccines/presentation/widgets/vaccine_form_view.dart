import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccine_form_notifier.dart';

/// View do formulário de vacina (conteúdo visual)
class VaccineFormView extends ConsumerWidget {
  const VaccineFormView({
    super.key,
    required this.animalId,
    this.readOnly = false,
  });

  final String animalId;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(vaccineFormProvider(animalId));
    final formNotifier = ref.read(vaccineFormProvider(animalId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome da Vacina
        _buildTextField(
          label: 'Nome da Vacina *',
          value: formState.name,
          readOnly: readOnly,
          errorText: formState.nameError,
          suggestions: _commonVaccines,
          onChanged: (value) => formNotifier.updateField('name', value),
        ),
        const SizedBox(height: 16),

        // Data da Vacinação
        _buildDateField(
          context: context,
          label: 'Data da Vacinação *',
          value: formState.date,
          readOnly: readOnly,
          errorText: formState.dateError,
          onChanged: formNotifier.updateDate,
        ),
        const SizedBox(height: 16),

        // Veterinário
        _buildTextField(
          label: 'Veterinário *',
          value: formState.veterinarian,
          readOnly: readOnly,
          errorText: formState.veterinarianError,
          onChanged: (value) => formNotifier.updateField('veterinarian', value),
        ),
        const SizedBox(height: 16),

        // Status
        _buildStatusDropdown(
          context: context,
          value: formState.status,
          readOnly: readOnly,
          onChanged: formNotifier.updateStatus,
        ),
        const SizedBox(height: 16),

        // Lote
        _buildTextField(
          label: 'Lote',
          value: formState.batch ?? '',
          readOnly: readOnly,
          onChanged: (value) => formNotifier.updateField('batch', value),
        ),
        const SizedBox(height: 16),

        // Fabricante
        _buildTextField(
          label: 'Fabricante',
          value: formState.manufacturer ?? '',
          readOnly: readOnly,
          suggestions: _commonManufacturers,
          onChanged: (value) => formNotifier.updateField('manufacturer', value),
        ),
        const SizedBox(height: 16),

        // Dosagem
        _buildTextField(
          label: 'Dosagem',
          value: formState.dosage ?? '',
          readOnly: readOnly,
          onChanged: (value) => formNotifier.updateField('dosage', value),
        ),
        const SizedBox(height: 16),

        // Próxima Dose (Opcional)
        _buildDateField(
          context: context,
          label: 'Próxima Dose',
          value: formState.nextDueDate,
          readOnly: readOnly,
          onChanged: formNotifier.updateNextDueDate,
          allowClear: true,
        ),
        const SizedBox(height: 16),

        // Lembrete
        _buildDateField(
          context: context,
          label: 'Data do Lembrete',
          value: formState.reminderDate,
          readOnly: readOnly,
          onChanged: formNotifier.updateReminderDate,
          allowClear: true,
        ),
        const SizedBox(height: 16),

        // Obrigatória
        if (!readOnly)
          SwitchListTile(
            title: const Text('Vacina Obrigatória'),
            subtitle: const Text('Marcar como vacina obrigatória'),
            value: formState.isRequired,
            onChanged: formNotifier.updateIsRequired,
            contentPadding: EdgeInsets.zero,
          ),
        if (readOnly)
          ListTile(
            title: const Text('Vacina Obrigatória'),
            subtitle: Text(formState.isRequired ? 'Sim' : 'Não'),
            contentPadding: EdgeInsets.zero,
          ),
        const SizedBox(height: 16),

        // Observações
        _buildTextField(
          label: 'Observações',
          value: formState.notes ?? '',
          readOnly: readOnly,
          maxLines: 3,
          onChanged: (value) => formNotifier.updateField('notes', value),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required bool readOnly,
    String? errorText,
    List<String>? suggestions,
    int maxLines = 1,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (suggestions != null && !readOnly)
          Autocomplete<String>(
            initialValue: TextEditingValue(text: value),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return suggestions.where((option) {
                return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },
            onSelected: onChanged,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                  filled: readOnly,
                ),
                readOnly: readOnly,
                maxLines: maxLines,
                onChanged: onChanged,
              );
            },
          )
        else
          TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: errorText,
              filled: readOnly,
            ),
            readOnly: readOnly,
            maxLines: maxLines,
            onChanged: onChanged,
          ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required bool readOnly,
    String? errorText,
    required void Function(DateTime) onChanged,
    bool allowClear = false,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: readOnly
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    onChanged(picked);
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: errorText,
              filled: readOnly,
              suffixIcon: allowClear && value != null && !readOnly
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onChanged(DateTime.now()),
                    )
                  : const Icon(Icons.calendar_today),
            ),
            child: Text(
              value != null ? dateFormat.format(value) : 'Selecione',
              style: TextStyle(
                color: value == null
                    ? Theme.of(context).hintColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown({
    required BuildContext context,
    required VaccineStatus value,
    required bool readOnly,
    required void Function(VaccineStatus) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (readOnly)
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
            child: Text(_getStatusLabel(value)),
          )
        else
          DropdownButtonFormField<VaccineStatus>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: VaccineStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusLabel(status)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
          ),
      ],
    );
  }

  String _getStatusLabel(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return 'Agendada';
      case VaccineStatus.completed:
        return 'Completa';
      case VaccineStatus.applied:
        return 'Aplicada';
      case VaccineStatus.overdue:
        return 'Atrasada';
      case VaccineStatus.cancelled:
        return 'Cancelada';
    }
  }

  // Listas de sugestões
  static const List<String> _commonVaccines = [
    'V10 (Múltipla)',
    'V8 (Múltipla)',
    'Antirrábica',
    'Giárdia',
    'Gripe Canina',
    'Leishmaniose',
    'FeLV (Leucemia Felina)',
    'FIV (AIDS Felina)',
    'Tríplice Felina',
    'Quíntupla Felina',
  ];

  static const List<String> _commonManufacturers = [
    'Zoetis',
    'MSD Saúde Animal',
    'Boehringer Ingelheim',
    'Virbac',
    'Ceva Saúde Animal',
    'Elanco',
    'Merck Animal Health',
    'Ourofino',
    'Hertape Calier',
    'Vencofarma',
    'Biovet',
  ];
}
