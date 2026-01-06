// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
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
      _ThirteenthSalaryInputFormState();
}

class _ThirteenthSalaryInputFormState extends State<ThirteenthSalaryInputForm> {
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Salary Input
          TextFormField(
            controller: _salaryController,
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
          const SizedBox(height: 16),

          // Admission Date
          TextFormField(
            controller: _admissionDateController,
            decoration: const InputDecoration(
              labelText: 'Data de Admissão',
              border: OutlineInputBorder(),
              helperText: 'DD/MM/AAAA',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: [_dateFormatter],
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
            onChanged: (value) {
              final date = _parseDate(value);
              if (date != null) {
                setState(() {
                  _admissionDate = date;
                  _updateMonthsWorked();
                });
              }
            },
            onTap: () => _selectDate(context, true),
          ),
          const SizedBox(height: 16),

          // Calculation Date
          TextFormField(
            controller: _calculationDateController,
            decoration: const InputDecoration(
              labelText: 'Data do Cálculo',
              border: OutlineInputBorder(),
              helperText: 'DD/MM/AAAA',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: [_dateFormatter],
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
            onChanged: (value) {
              final date = _parseDate(value);
              if (date != null) {
                setState(() {
                  _calculationDate = date;
                  _updateMonthsWorked();
                });
              }
            },
            onTap: () => _selectDate(context, false),
          ),
          const SizedBox(height: 16),

          // Months Worked (auto-calculated)
          TextFormField(
            controller: _monthsController,
            decoration: const InputDecoration(
              labelText: 'Meses Trabalhados',
              border: OutlineInputBorder(),
              helperText: 'Calculado automaticamente',
              suffixIcon: Icon(Icons.lock),
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),

          // Unjustified Absences
          TextFormField(
            controller: _absencesController,
            decoration: const InputDecoration(
              labelText: 'Faltas Não Justificadas',
              border: OutlineInputBorder(),
              helperText: 'Cada 15 faltas desconta 1 mês',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final absences = int.tryParse(value) ?? 0;
                if (absences < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
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
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final dependents = int.tryParse(value) ?? 0;
                if (dependents < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
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
    var months = (calculation.year - effectiveStart.year) * 12 +
        calculation.month - effectiveStart.month;
    
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

  Future<void> _selectDate(BuildContext context, bool isAdmission) async {
    final initialDate = isAdmission
        ? _admissionDate ?? DateTime.now()
        : _calculationDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isAdmission) {
          _admissionDate = picked;
          _admissionDateController.text = _formatDate(picked);
        } else {
          _calculationDate = picked;
          _calculationDateController.text = _formatDate(picked);
        }
        _updateMonthsWorked();
      });
    }
  }

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) return;

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
