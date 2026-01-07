// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
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
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: TextFormField(
              controller: _grossSalaryController,
              decoration: const InputDecoration(
                labelText: 'Salário Bruto Mensal',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
                helperText: 'Ex: 3.000,00',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_currencyFormatter],
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
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _weeklyHoursController,
              decoration: const InputDecoration(
                labelText: 'Horas Semanais Contratadas',
                border: OutlineInputBorder(),
                helperText: 'Geralmente 44 horas',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onSaved: (_) => _submitForm(),
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: TextFormField(
              controller: _hours50Controller,
              decoration: const InputDecoration(
                labelText: 'Horas Extras 50%',
                border: OutlineInputBorder(),
                helperText: 'Horas trabalhadas em dias normais',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = int.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _hours100Controller,
              decoration: const InputDecoration(
                labelText: 'Horas Extras 100%',
                border: OutlineInputBorder(),
                helperText: 'Domingos e feriados',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = int.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
              onSaved: (_) => _submitForm(),
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: TextFormField(
              controller: _nightHoursController,
              decoration: const InputDecoration(
                labelText: 'Horas Noturnas (opcional)',
                border: OutlineInputBorder(),
                helperText: 'Geralmente das 22h às 5h',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _nightPercentageController,
              decoration: const InputDecoration(
                labelText: 'Adicional Noturno (%)',
                border: OutlineInputBorder(),
                helperText: 'Mínimo legal: 20%',
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final percentage = double.tryParse(value) ?? 0;
                  if (percentage < 0 || percentage > 100) {
                    return 'Percentual deve estar entre 0 e 100';
                  }
                }
                return null;
              },
              onSaved: (_) => _submitForm(),
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: TextFormField(
              controller: _sundayHolidayHoursController,
              decoration: const InputDecoration(
                labelText: 'Horas Domingo/Feriado (opcional)',
                border: OutlineInputBorder(),
                helperText: 'Horas trabalhadas em domingos ou feriados',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = double.tryParse(value) ?? 0;
                  if (hours < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _workDaysController,
              decoration: const InputDecoration(
                labelText: 'Dias Úteis no Mês',
                border: OutlineInputBorder(),
                helperText: 'Geralmente 22 dias',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onSaved: (_) => _submitForm(),
            ),
          ),
          const SizedBox(height: 16),

          // Dependents
          TextFormField(
            controller: _dependentsController,
            decoration: const InputDecoration(
              labelText: 'Número de Dependentes',
              border: OutlineInputBorder(),
              helperText: 'Para cálculo do IRRF',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSaved: (_) => _submitForm(),
          ),
        ],
      ),
    );
  }

  double _parseNumericValue(String value) {
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0;
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
