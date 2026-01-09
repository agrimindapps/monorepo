// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/utils/brazilian_currency_formatter.dart';
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
  State<OvertimeInputForm> createState() => OvertimeInputFormState();
}

class OvertimeInputFormState extends State<OvertimeInputForm> {
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
              controller: _grossSalaryController,
              label: 'Salário Bruto Mensal',
              helperText: 'Ex: 3.000,00',
              accentColor: accentColor,              validator: (value) {
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
            right: AccentNumberField(
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
            left: AccentNumberField(
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
            right: AccentNumberField(
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
            left: AccentNumberField(
              controller: _nightHoursController,
              label: 'Horas Noturnas (opcional)',
              helperText: 'Geralmente das 22h às 5h',
              accentColor: accentColor,
            ),
            right: AccentNumberField(
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
            left: AccentNumberField(
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
            right: AccentNumberField(
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
          AccentNumberField(
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
