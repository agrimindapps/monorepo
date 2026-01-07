import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
                left: TextFormField(
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

                    if (numericValue > 1000000) {
                      return 'Salário muito alto';
                    }

                    return null;
                  },
                ),
                right: TextFormField(
                  controller: _vacationDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Dias de Férias',
                    border: OutlineInputBorder(),
                    helperText: 'De 1 a 30 dias',
                    suffixText: 'dias',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
