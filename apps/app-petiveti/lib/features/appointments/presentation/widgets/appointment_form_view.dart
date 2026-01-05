import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/appointment.dart';
import '../providers/appointment_form_notifier.dart';

class AppointmentFormView extends ConsumerWidget {
  const AppointmentFormView({
    required this.animalId,
    this.readOnly = false,
    super.key,
  });

  final String animalId;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentFormProvider(animalId));
    final notifier = ref.read(appointmentFormProvider(animalId).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Veterinário
          _buildVeterinarianField(context, state, notifier),
          const SizedBox(height: 16),

          // Motivo da Consulta
          _buildReasonField(context, state, notifier),
          const SizedBox(height: 16),

          // Data
          _buildDateField(context, state, notifier),
          const SizedBox(height: 16),

          // Status
          _buildStatusField(context, state, notifier),
          const SizedBox(height: 16),

          // Diagnóstico
          _buildDiagnosisField(context, state, notifier),
          const SizedBox(height: 16),

          // Custo
          _buildCostField(context, state, notifier),
          const SizedBox(height: 16),

          // Observações
          _buildNotesField(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildVeterinarianField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: state.veterinarianName),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _veterinarianSuggestions.where((option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: readOnly ? null : (value) => notifier.updateField('veterinarianName', value),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Veterinário',
            hintText: 'Nome do veterinário',
            errorText: state.veterinarianNameError,
            prefixIcon: const Icon(Icons.person),
          ),
          enabled: !readOnly,
          onChanged: readOnly ? null : (value) => notifier.updateField('veterinarianName', value),
        );
      },
    );
  }

  Widget _buildReasonField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: state.reason),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _reasonSuggestions.where((option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: readOnly ? null : (value) => notifier.updateField('reason', value),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Motivo da Consulta',
            hintText: 'Ex: Consulta de rotina',
            errorText: state.reasonError,
            prefixIcon: const Icon(Icons.medical_services),
          ),
          enabled: !readOnly,
          onChanged: readOnly ? null : (value) => notifier.updateField('reason', value),
        );
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(state.date),
                );
                if (time != null) {
                  final dateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                  notifier.updateDate(dateTime);
                }
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data e Hora',
          errorText: state.dateError,
          prefixIcon: const Icon(Icons.calendar_today),
          enabled: !readOnly,
        ),
        child: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(state.date),
          style: TextStyle(
            color: readOnly ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return DropdownButtonFormField<AppointmentStatus>(
      value: state.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.info_outline),
      ),
      items: AppointmentStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getStatusLabel(status)),
        );
      }).toList(),
      onChanged: readOnly ? null : (value) {
        if (value != null) notifier.updateStatus(value);
      },
    );
  }

  Widget _buildDiagnosisField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return TextFormField(
      initialValue: state.diagnosis ?? '',
      decoration: const InputDecoration(
        labelText: 'Diagnóstico',
        hintText: 'Diagnóstico do veterinário (opcional)',
        prefixIcon: Icon(Icons.assignment),
      ),
      maxLines: 3,
      enabled: !readOnly,
      onChanged: readOnly ? null : (value) => notifier.updateField('diagnosis', value),
    );
  }

  Widget _buildCostField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return TextFormField(
      initialValue: state.cost?.toStringAsFixed(2) ?? '',
      decoration: InputDecoration(
        labelText: 'Custo',
        hintText: 'Valor da consulta (opcional)',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: 'R\$ ',
        errorText: state.costError,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      enabled: !readOnly,
      onChanged: readOnly
          ? null
          : (value) {
              final cost = double.tryParse(value);
              notifier.updateCost(cost);
            },
    );
  }

  Widget _buildNotesField(
    BuildContext context,
    state,
    AppointmentFormNotifier notifier,
  ) {
    return TextFormField(
      initialValue: state.notes ?? '',
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Informações adicionais (opcional)',
        prefixIcon: Icon(Icons.notes),
      ),
      maxLines: 4,
      enabled: !readOnly,
      onChanged: readOnly ? null : (value) => notifier.updateField('notes', value),
    );
  }

  String _getStatusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendada';
      case AppointmentStatus.inProgress:
        return 'Em Andamento';
      case AppointmentStatus.completed:
        return 'Concluída';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
    }
  }

  static const _veterinarianSuggestions = [
    'Dr. Silva',
    'Dr. João Santos',
    'Dra. Maria Oliveira',
    'Dr. Pedro Costa',
    'Dra. Ana Paula',
    'Dr. Carlos Eduardo',
    'Dra. Juliana Ferreira',
  ];

  static const _reasonSuggestions = [
    'Consulta de rotina',
    'Vacinação',
    'Castração',
    'Emergência',
    'Exame de sangue',
    'Ultrassom',
    'Raio-X',
    'Tratamento odontológico',
    'Cirurgia',
    'Retorno',
  ];
}
