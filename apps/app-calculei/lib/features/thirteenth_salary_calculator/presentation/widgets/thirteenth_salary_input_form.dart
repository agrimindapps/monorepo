// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';

/// Input form for 13th salary calculation
class ThirteenthSalaryInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateThirteenthSalaryParams) onCalculate;

  const ThirteenthSalaryInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<ThirteenthSalaryInputForm> createState() =>
      ThirteenthSalaryInputFormState();
}

class ThirteenthSalaryInputFormState extends State<ThirteenthSalaryInputForm> {
  // Controllers
  final _salaryController = TextEditingController();
  final _monthsController = TextEditingController(text: '12');
  final _admissionDateController = TextEditingController();
  final _calculationDateController = TextEditingController();
  final _absencesController = TextEditingController(text: '0');
  final _dependentsController = TextEditingController(text: '0');

  // State
  bool _isAdvancePayment = false;
  DateTime? _admissionDate;
  DateTime? _calculationDate;

  @override
  void initState() {
    super.initState();
    // Initialize with default dates
    _calculationDate = DateTime.now();
    _calculationDateController.text = _formatDate(_calculationDate!);

    _admissionDate = DateTime(
      _calculationDate!.year,
      1,
      1,
    ); // January 1st of current year
    _admissionDateController.text = _formatDate(_admissionDate!);

    _updateMonthsWorked();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _monthsController.dispose();
    _admissionDateController.dispose();
    _calculationDateController.dispose();
    _absencesController.dispose();
    _dependentsController.dispose();
    super.dispose();
  }

  /// Public method to submit the form from external button
  void submit() {
    _submitForm();
  }

  /// Public method to clear all input fields
  void clear() {
    _salaryController.clear();
    _absencesController.text = '0';
    _dependentsController.text = '0';
    
    // Reset to default dates
    setState(() {
      _calculationDate = DateTime.now();
      _calculationDateController.text = _formatDate(_calculationDate!);
      
      _admissionDate = DateTime(_calculationDate!.year, 1, 1);
      _admissionDateController.text = _formatDate(_admissionDate!);
      
      _isAdvancePayment = false;
      _updateMonthsWorked();
    });
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
              controller: _salaryController,
              label: 'Salário Bruto Mensal',
              helperText: 'Ex: 3.000,00',
              hintText: 'Ex: 3.000,00',
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
              controller: _dependentsController,
              label: 'Número de Dependentes',
              helperText: 'Para cálculo do IRRF',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final dependents = int.tryParse(value) ?? 0;
                  if (dependents < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: AccentDateField(
              controller: _admissionDateController,
              label: 'Data de Admissão',
              helperText: 'DD/MM/AAAA',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a data de admissão';
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
              initialDate: _admissionDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateSelected: (DateTime date) {
                setState(() {
                  _admissionDate = date;
                  _admissionDateController.text = _formatDate(date);
                  _updateMonthsWorked();
                });
              },
            ),
            right: AccentDateField(
              controller: _calculationDateController,
              label: 'Data do Cálculo',
              helperText: 'DD/MM/AAAA',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a data do cálculo';
                }
                final date = _parseDate(value);
                if (date == null) {
                  return 'Data inválida';
                }
                return null;
              },
              initialDate: _calculationDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateSelected: (DateTime date) {
                setState(() {
                  _calculationDate = date;
                  _calculationDateController.text = _formatDate(date);
                  _updateMonthsWorked();
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: AccentNumberField(
              controller: _monthsController,
              label: 'Meses Trabalhados',
              helperText: 'Calculado automaticamente',
              accentColor: accentColor,
            ),
            right: AccentNumberField(
              controller: _absencesController,
              label: 'Faltas Não Justificadas',
              helperText: 'Cada 15 faltas desconta 1 mês',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final absences = int.tryParse(value) ?? 0;
                  if (absences < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Advance Payment Switch
          SwitchListTile(
            title: const Text('Antecipação (2 parcelas)'),
            subtitle: const Text('1ª parcela: 50% bruto | 2ª parcela: líquido'),
            value: _isAdvancePayment,
            onChanged: (value) {
              setState(() {
                _isAdvancePayment = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _updateMonthsWorked() {
    if (_admissionDate != null && _calculationDate != null) {
      final months = _calculateMonthsWorked(_admissionDate!, _calculationDate!);
      _monthsController.text = months.toString();
    }
  }

  int _calculateMonthsWorked(DateTime admission, DateTime calculation) {
    // For 13th salary, we count full months worked in the current year
    // If admission is before current year, start from January 1st
    final yearStart = DateTime(calculation.year, 1, 1);
    final effectiveStart = admission.isAfter(yearStart) ? admission : yearStart;

    // Calculate months difference properly
    var months =
        (calculation.year - effectiveStart.year) * 12 +
        calculation.month -
        effectiveStart.month;

    // If day of calculation is >= day of admission, count current month
    // Brazilian rule: work 15+ days in a month = count as full month
    if (calculation.day >= 15 && effectiveStart.day <= 15) {
      months += 1;
    } else if (calculation.day >= effectiveStart.day) {
      months += 1;
    }

    // Ensure months is between 1 and 12
    if (months < 1) {
      months = 1;
    }
    if (months > 12) {
      months = 12;
    }

    return months;
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

    final params = CalculateThirteenthSalaryParams(
      grossSalary: _parseNumericValue(_salaryController.text),
      monthsWorked: int.tryParse(_monthsController.text) ?? 12,
      admissionDate: _admissionDate!,
      calculationDate: _calculationDate!,
      unjustifiedAbsences: int.tryParse(_absencesController.text) ?? 0,
      isAdvancePayment: _isAdvancePayment,
      dependents: int.tryParse(_dependentsController.text) ?? 0,
    );

    widget.onCalculate(params);
  }
}

