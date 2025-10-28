// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../domain/usecases/calculate_unemployment_insurance_usecase.dart';

/// Input form for unemployment insurance calculation
class UnemploymentInsuranceInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateUnemploymentInsuranceParams) onCalculate;

  const UnemploymentInsuranceInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<UnemploymentInsuranceInputForm> createState() =>
      _UnemploymentInsuranceInputFormState();
}

class _UnemploymentInsuranceInputFormState
    extends State<UnemploymentInsuranceInputForm> {
  // Controllers
  final _averageSalaryController = TextEditingController();
  final _workMonthsController = TextEditingController();
  final _timesReceivedController = TextEditingController(text: '0');
  final _dismissalDateController = TextEditingController();

  // State
  DateTime? _dismissalDate;

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    _dismissalDate = DateTime.now();
    _dismissalDateController.text = _formatDate(_dismissalDate!);
  }

  @override
  void dispose() {
    _averageSalaryController.dispose();
    _workMonthsController.dispose();
    _timesReceivedController.dispose();
    _dismissalDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Average Salary (last 3 months)
          TextFormField(
            controller: _averageSalaryController,
            decoration: const InputDecoration(
              labelText: 'Salário Médio (últimos 3 meses)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Média dos últimos 3 salários',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o salário médio';
              }
              final numericValue = _parseNumericValue(value);
              if (numericValue <= 0) {
                return 'Salário deve ser maior que zero';
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Work Months
          TextFormField(
            controller: _workMonthsController,
            decoration: const InputDecoration(
              labelText: 'Meses Trabalhados',
              border: OutlineInputBorder(),
              helperText: 'Tempo no último emprego',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe os meses trabalhados';
              }
              final months = int.tryParse(value) ?? 0;
              if (months < 0) {
                return 'Valor não pode ser negativo';
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Times Received
          TextFormField(
            controller: _timesReceivedController,
            decoration: const InputDecoration(
              labelText: 'Vezes que já recebeu',
              border: OutlineInputBorder(),
              helperText: '0 = primeira vez, 1 = segunda vez, etc.',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final times = int.tryParse(value) ?? 0;
                if (times < 0) {
                  return 'Valor não pode ser negativo';
                }
                if (times > 10) {
                  return 'Valor muito alto';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Dismissal Date
          TextFormField(
            controller: _dismissalDateController,
            decoration: const InputDecoration(
              labelText: 'Data de Demissão',
              border: OutlineInputBorder(),
              helperText: 'DD/MM/AAAA',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: [_dateFormatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a data de demissão';
              }
              final date = _parseDate(value);
              if (date == null) {
                return 'Data inválida';
              }
              if (date.isAfter(DateTime.now())) {
                return 'Data não pode ser futura';
              }
              return null;
            },
            onChanged: (value) {
              final date = _parseDate(value);
              if (date != null) {
                setState(() {
                  _dismissalDate = date;
                });
              }
            },
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  double _parseNumericValue(String value) {
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0;
  }

  DateTime? _parseDate(String value) {
    if (value.length != 10) return null;

    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1900 || year > 2100) return null;

    try {
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dismissalDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dismissalDate = picked;
        _dismissalDateController.text = _formatDate(picked);
      });
    }
  }

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) return;

    final params = CalculateUnemploymentInsuranceParams(
      averageSalary: _parseNumericValue(_averageSalaryController.text),
      workMonths: int.tryParse(_workMonthsController.text) ?? 0,
      timesReceived: int.tryParse(_timesReceivedController.text) ?? 0,
      dismissalDate: _dismissalDate ?? DateTime.now(),
    );

    widget.onCalculate(params);
  }
}
