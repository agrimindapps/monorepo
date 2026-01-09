// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_overtime_usecase.dart';
import '../../../../shared/widgets/responsive_input_row.dart';

/// Input form for overtime calculation
class OvertimeInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateOvertimeParams) onCalculate;

  const OvertimeInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<OvertimeInputForm> createState() => _OvertimeInputFormState();
}

class _OvertimeInputFormState extends State<OvertimeInputForm> {
  // Controllers
  final _grossSalaryController = TextEditingController();
  final _weeklyHoursController = TextEditingController(text: '44');
  final _hours50Controller = TextEditingController(text: '0');
  final _hours100Controller = TextEditingController(text: '0');
  final _nightHoursController = TextEditingController(text: '0');
  final _nightPercentageController = TextEditingController(text: '20');
  final _sundayHolidayHoursController = TextEditingController(text: '0');
  final _workDaysController = TextEditingController(text: '22');
  final _dependentsController = TextEditingController(text: '0');

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _grossSalaryController.dispose();
    _weeklyHoursController.dispose();
    _hours50Controller.dispose();
    _hours100Controller.dispose();
    _nightHoursController.dispose();
    _nightPercentageController.dispose();
    _sundayHolidayHoursController.dispose();
    _workDaysController.dispose();
    _dependentsController.dispose();
    super.dispose();
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
            left: _DarkCurrencyField(
              controller: _grossSalaryController,
              label: 'Salário Bruto Mensal',
              helperText: 'Ex: 3.000,00',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o salário';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Salário deve ser maior que zero';
                }
                return null;
              },
            ),
            right: _DarkNumberField(
              controller: _weeklyHoursController,
              label: 'Horas Semanais Contratadas',
              helperText: 'Geralmente 44 horas',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe as horas semanais';
                }
                final hours = int.tryParse(value) ?? 0;
                if (hours <= 0) {
                  return 'Horas devem ser maior que zero';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: _DarkNumberField(
              controller: _hours50Controller,
              label: 'Horas Extras 50%',
              helperText: 'Horas trabalhadas em dias normais',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = int.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
            right: _DarkNumberField(
              controller: _hours100Controller,
              label: 'Horas Extras 100%',
              helperText: 'Domingos e feriados',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = int.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: _DarkNumberField(
              controller: _nightHoursController,
              label: 'Horas Noturnas (opcional)',
              helperText: 'Geralmente das 22h às 5h',
              accentColor: accentColor,
            ),
            right: _DarkNumberField(
              controller: _nightPercentageController,
              label: 'Adicional Noturno (%)',
              helperText: 'Mínimo legal: 20%',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final percentage = double.tryParse(value) ?? 0;
                  if (percentage < 0 || percentage > 100) {
                    return 'Percentual deve estar entre 0 e 100';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: _DarkNumberField(
              controller: _sundayHolidayHoursController,
              label: 'Horas Domingo/Feriado (opcional)',
              helperText: 'Horas trabalhadas em domingos ou feriados',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = double.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
            right: _DarkNumberField(
              controller: _workDaysController,
              label: 'Dias Úteis no Mês',
              helperText: 'Geralmente 22 dias',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe os dias úteis';
                }
                final days = int.tryParse(value) ?? 0;
                if (days <= 0) {
                  return 'Dias devem ser maior que zero';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Dependents
          _DarkNumberField(
            controller: _dependentsController,
            label: 'Número de Dependentes',
            helperText: 'Para cálculo do IRRF',
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  double _parseNumericValue(String value) {
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0;
  }

  /// Public method to trigger calculation from parent widget
  void calculate() {
    _submitForm();
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

    final params = CalculateOvertimeParams(
      grossSalary: _parseNumericValue(_grossSalaryController.text),
      weeklyHours: int.tryParse(_weeklyHoursController.text) ?? 44,
      hours50: double.tryParse(_hours50Controller.text) ?? 0,
      hours100: double.tryParse(_hours100Controller.text) ?? 0,
      nightHours: double.tryParse(_nightHoursController.text) ?? 0,
      nightAdditionalPercentage:
          double.tryParse(_nightPercentageController.text) ?? 20,
      sundayHolidayHours:
          double.tryParse(_sundayHolidayHoursController.text) ?? 0,
      workDaysMonth: int.tryParse(_workDaysController.text) ?? 22,
      dependents: int.tryParse(_dependentsController.text) ?? 0,
    );

    widget.onCalculate(params);
  }
}

/// Dark themed currency input field
class _DarkCurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final MaskTextInputFormatter formatter;
  final String? Function(String?)? validator;

  const _DarkCurrencyField({
    required this.controller,
    required this.label,
    required this.accentColor,
    required this.formatter,
    this.helperText,
    this.validator,
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
          keyboardType: TextInputType.number,
          inputFormatters: [formatter],
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            prefixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
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

/// Dark themed number input field
class _DarkNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;

  const _DarkNumberField({
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
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
