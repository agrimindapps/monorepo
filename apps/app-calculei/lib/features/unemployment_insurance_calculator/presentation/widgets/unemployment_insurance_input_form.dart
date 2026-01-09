// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/utils/brazilian_currency_formatter.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';
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
      UnemploymentInsuranceInputFormState();
}

class UnemploymentInsuranceInputFormState
    extends State<UnemploymentInsuranceInputForm> {
  // Controllers
  final _averageSalaryController = TextEditingController();
  final _workMonthsController = TextEditingController();
  final _timesReceivedController = TextEditingController(text: '0');
  final _dismissalDateController = TextEditingController();

  // State
  DateTime? _dismissalDate;

  // Formatters

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

  /// Public method to submit the form from external button
  void submit() {
    _submitForm();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.labor;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: AccentCurrencyField(
              controller: _averageSalaryController,
              label: 'Salário Médio (últimos 3 meses)',
              helperText: 'Média dos últimos 3 salários',
              accentColor: accentColor,              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o salário médio';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Salário deve ser maior que zero';
                }
                return null;
              },
            ),
            right: AccentNumberField(
              controller: _workMonthsController,
              label: 'Meses Trabalhados',
              helperText: 'Tempo no último emprego',
              accentColor: accentColor,
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
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: AccentNumberField(
              controller: _timesReceivedController,
              label: 'Vezes que já recebeu',
              helperText: '0 = primeira vez, 1 = segunda vez, etc.',
              accentColor: accentColor,
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
            ),
            right: _DarkDateField(
              controller: _dismissalDateController,
              label: 'Data de Demissão',
              helperText: 'DD/MM/AAAA',
              accentColor: accentColor,
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
    if (value.length != 10) {
      return null;
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }
    if (day < 1 || day > 31) {
      return null;
    }
    if (month < 1 || month > 12) {
      return null;
    }
    if (year < 1900 || year > 2100) {
      return null;
    }

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
    if (!widget.formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final params = CalculateUnemploymentInsuranceParams(
      averageSalary: _parseNumericValue(_averageSalaryController.text),
      workMonths: int.tryParse(_workMonthsController.text) ?? 0,
      timesReceived: int.tryParse(_timesReceivedController.text) ?? 0,
      dismissalDate: _dismissalDate ?? DateTime.now(),
    );

    widget.onCalculate(params);
  }
}

/// Dark themed date input field
class _DarkDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const _DarkDateField({
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
