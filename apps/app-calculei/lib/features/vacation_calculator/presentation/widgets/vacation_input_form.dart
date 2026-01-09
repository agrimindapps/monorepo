import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';

/// Input form for vacation calculation parameters
class VacationInputForm extends StatefulWidget {
  final void Function(
    double grossSalary,
    int vacationDays,
    bool sellVacationDays,
  )
  onCalculate;

  const VacationInputForm({super.key, required this.onCalculate});

  @override
  State<VacationInputForm> createState() => _VacationInputFormState();
}

class _VacationInputFormState extends State<VacationInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _vacationDaysController = TextEditingController(text: '30');

  bool _sellVacationDays = false;

  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _salaryController.dispose();
    _vacationDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.labor;

    return Form(
      key: _formKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dados para Cálculo',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Salary and Vacation Days Row
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

                    if (numericValue > 1000000) {
                      return 'Salário muito alto';
                    }

                    return null;
                  },
                ),
                right: _DarkNumberField(
                  controller: _vacationDaysController,
                  label: 'Dias de Férias',
                  helperText: 'De 1 a 30 dias',
                  accentColor: accentColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe os dias';
                    }

                    final days = int.tryParse(value);
                    if (days == null || days < 1 || days > 30) {
                      return 'Dias devem estar entre 1 e 30';
                    }

                    if (_sellVacationDays && days < 10) {
                      return 'Para vender dias, precisa ter pelo menos 10';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Sell Vacation Days Switch
              SwitchListTile(
                title: const Text('Vender 1/3 das Férias'),
                subtitle: const Text(
                  'Abono pecuniário (converter até 10 dias em dinheiro)',
                  style: TextStyle(fontSize: 12),
                ),
                value: _sellVacationDays,
                onChanged: (value) {
                  setState(() {
                    _sellVacationDays = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Calculate Button
              FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular Férias'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final grossSalary = _parseNumericValue(_salaryController.text);
    final vacationDays = int.parse(_vacationDaysController.text);

    widget.onCalculate(grossSalary, vacationDays, _sellVacationDays);
  }

  double _parseNumericValue(String value) {
    // Remove everything except digits and comma
    final cleaned = value.replaceAll(RegExp(r'[^\d,]'), '');

    // Replace comma with dot
    final normalized = cleaned.replaceAll(',', '.');

    return double.tryParse(normalized) ?? 0.0;
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
