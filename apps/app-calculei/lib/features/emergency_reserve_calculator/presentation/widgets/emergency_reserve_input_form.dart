// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_emergency_reserve_usecase.dart';
import '../../../../shared/widgets/responsive_input_row.dart';

/// Input form for emergency reserve calculation
class EmergencyReserveInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateEmergencyReserveParams) onCalculate;

  const EmergencyReserveInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<EmergencyReserveInputForm> createState() =>
      _EmergencyReserveInputFormState();
}

class _EmergencyReserveInputFormState extends State<EmergencyReserveInputForm> {
  // Controllers
  final _monthlyExpensesController = TextEditingController();
  final _extraExpensesController = TextEditingController(text: '0');
  final _desiredMonthsController = TextEditingController(text: '6');
  final _monthlySavingsController = TextEditingController(text: '0');

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _monthlyExpensesController.dispose();
    _extraExpensesController.dispose();
    _desiredMonthsController.dispose();
    _monthlySavingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.financial;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: _DarkCurrencyField(
              controller: _monthlyExpensesController,
              label: 'Despesas Mensais',
              helperText: 'Total de gastos fixos e variáveis',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe as despesas mensais';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Despesas devem ser maior que zero';
                }
                return null;
              },
            ),
            right: _DarkCurrencyField(
              controller: _extraExpensesController,
              label: 'Despesas Extras (opcional)',
              helperText: 'Custos eventuais ou sazonais',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final numericValue = _parseNumericValue(value);
                  if (numericValue < 0) {
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
              controller: _desiredMonthsController,
              label: 'Meses de Cobertura',
              helperText: 'Recomendado: 6 a 12 meses',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o número de meses';
                }
                final months = int.tryParse(value) ?? 0;
                if (months <= 0) {
                  return 'Meses deve ser maior que zero';
                }
                if (months > 120) {
                  return 'Máximo 120 meses (10 anos)';
                }
                return null;
              },
            ),
            right: _DarkCurrencyField(
              controller: _monthlySavingsController,
              label: 'Poupança Mensal (opcional)',
              helperText: 'Quanto pode poupar por mês',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final numericValue = _parseNumericValue(value);
                  if (numericValue < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
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

    final params = CalculateEmergencyReserveParams(
      monthlyExpenses: _parseNumericValue(_monthlyExpensesController.text),
      extraExpenses: _parseNumericValue(_extraExpensesController.text),
      desiredMonths: int.tryParse(_desiredMonthsController.text) ?? 6,
      monthlySavings: _parseNumericValue(_monthlySavingsController.text),
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
