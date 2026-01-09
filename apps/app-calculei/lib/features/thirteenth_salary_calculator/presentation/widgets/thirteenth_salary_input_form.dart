// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';
import '../../../../shared/widgets/responsive_input_row.dart';

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
  final _currencyFormatter = _CurrencyInputFormatter();

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
    const accentColor = CalculatorAccentColors.labor;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: _DarkCurrencyField(
              controller: _salaryController,
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
            left: _DarkDateField(
              controller: _admissionDateController,
              label: 'Data de Admissão',
              helperText: 'DD/MM/AAAA',
              accentColor: accentColor,
              formatter: _dateFormatter,
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
            right: _DarkDateField(
              controller: _calculationDateController,
              label: 'Data do Cálculo',
              helperText: 'DD/MM/AAAA',
              accentColor: accentColor,
              formatter: _dateFormatter,
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
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: _DarkNumberField(
              controller: _monthsController,
              label: 'Meses Trabalhados',
              helperText: 'Calculado automaticamente',
              accentColor: accentColor,
              enabled: false,
            ),
            right: _DarkNumberField(
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

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = double.parse(newText) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final newString = formatter.format(value).trim();

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

/// Dark themed currency input field
class _DarkCurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final TextInputFormatter formatter;
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
  final bool enabled;

  const _DarkNumberField({
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
    this.enabled = true,
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
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
            disabledBorder: OutlineInputBorder(
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

/// Dark themed date input field
class _DarkDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final MaskTextInputFormatter formatter;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const _DarkDateField({
    required this.controller,
    required this.label,
    required this.accentColor,
    required this.formatter,
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
          inputFormatters: [formatter],
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
