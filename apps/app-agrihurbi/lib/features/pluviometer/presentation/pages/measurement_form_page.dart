import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rainfall_measurement_entity.dart';
import '../providers/pluviometer_provider.dart';

/// Página de formulário para criar/editar medição
class MeasurementFormPage extends ConsumerStatefulWidget {
  const MeasurementFormPage({
    super.key,
    this.measurement,
    this.preselectedRainGaugeId,
  });

  final RainfallMeasurementEntity? measurement;
  final String? preselectedRainGaugeId;

  @override
  ConsumerState<MeasurementFormPage> createState() =>
      _MeasurementFormPageState();
}

class _MeasurementFormPageState extends ConsumerState<MeasurementFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _observationsController;
  late String? _selectedRainGaugeId;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool get isEditing => widget.measurement != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.measurement?.amount.toString() ?? '',
    );
    _observationsController = TextEditingController(
      text: widget.measurement?.observations ?? '',
    );
    _selectedRainGaugeId = widget.measurement?.rainGaugeId ??
        widget.preselectedRainGaugeId;
    _selectedDate = widget.measurement?.measurementDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(
      widget.measurement?.measurementDate ?? DateTime.now(),
    );

    // Carrega pluviômetros se ainda não carregados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gaugesState = ref.read(rainGaugesProvider);
      if (gaugesState.gauges.isEmpty) {
        ref.read(rainGaugesProvider.notifier).loadGauges();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementsProvider);
    final gaugesState = ref.watch(rainGaugesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Medição' : 'Nova Medição'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pluviômetro
            DropdownButtonFormField<String>(
              initialValue: _selectedRainGaugeId,
              decoration: const InputDecoration(
                labelText: 'Pluviômetro *',
                prefixIcon: Icon(Icons.speed),
              ),
              items: gaugesState.gauges
                  .map(
                    (g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.description),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedRainGaugeId = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione um pluviômetro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quantidade
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Quantidade (mm) *',
                hintText: 'Ex: 25.5',
                prefixIcon: Icon(Icons.water_drop),
                suffixText: 'mm',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantidade é obrigatória';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Digite um número válido';
                }
                if (amount < 0) {
                  return 'Quantidade não pode ser negativa';
                }
                if (amount > 1000) {
                  return 'Quantidade parece inválida';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Data e Hora
            Text(
              'Data e Hora da Medição',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_formatDate(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Observações
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Ex: Chuva forte com ventania',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Botão de salvar
            FilledButton.icon(
              onPressed: state.isLoading ? null : _saveMeasurement,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isEditing ? 'Atualizar' : 'Salvar'),
            ),

            // Mensagem de erro
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    final measurementDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final measurement = RainfallMeasurementEntity(
      id: widget.measurement?.id ?? '',
      createdAt: widget.measurement?.createdAt,
      updatedAt: widget.measurement?.updatedAt,
      isActive: true,
      rainGaugeId: _selectedRainGaugeId!,
      measurementDate: measurementDate,
      amount: double.parse(_amountController.text.trim()),
      observations: _observationsController.text.trim().isEmpty
          ? null
          : _observationsController.text.trim(),
      objectId: widget.measurement?.objectId,
    );

    final notifier = ref.read(measurementsProvider.notifier);
    final success = isEditing
        ? await notifier.updateMeasurement(measurement)
        : await notifier.createMeasurement(measurement);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Medição atualizada com sucesso'
              : 'Medição criada com sucesso'),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
