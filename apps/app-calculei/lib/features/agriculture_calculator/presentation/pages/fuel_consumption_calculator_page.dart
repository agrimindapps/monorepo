import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/fuel_consumption_calculator.dart';

/// Página da calculadora de consumo de combustível
class FuelConsumptionCalculatorPage extends StatefulWidget {
  const FuelConsumptionCalculatorPage({super.key});

  @override
  State<FuelConsumptionCalculatorPage> createState() =>
      _FuelConsumptionCalculatorPageState();
}

class _FuelConsumptionCalculatorPageState
    extends State<FuelConsumptionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _powerController = TextEditingController(text: '100');
  final _hoursController = TextEditingController(text: '8');
  final _areaController = TextEditingController();
  final _fuelPriceController = TextEditingController(text: '5.50');

  LoadFactor _loadFactor = LoadFactor.medium;
  OperationType _operationType = OperationType.soilPreparation;
  FuelConsumptionResult? _result;

  @override
  void dispose() {
    _powerController.dispose();
    _hoursController.dispose();
    _areaController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      try {
        final power = double.parse(_powerController.text);
        final hours = double.parse(_hoursController.text);
        final area = _areaController.text.isNotEmpty
            ? double.parse(_areaController.text)
            : null;
        final fuelPrice = _fuelPriceController.text.isNotEmpty
            ? double.parse(_fuelPriceController.text)
            : null;

        final result = FuelConsumptionCalculator.calculate(
          tractorPowerHP: power,
          loadFactor: _loadFactor,
          operationType: _operationType,
          hoursWorked: hours,
          areaWorked: area,
          fuelPricePerLiter: fuelPrice,
        );

        setState(() {
          _result = result;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cálculo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _powerController.text = '100';
      _hoursController.text = '8';
      _areaController.clear();
      _fuelPriceController.text = '5.50';
      _loadFactor = LoadFactor.medium;
      _operationType = OperationType.soilPreparation;
      _result = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Consumo de Combustível',
      subtitle: 'Máquinas Agrícolas',
      icon: Icons.local_gas_station,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share handled by ShareButton in result card
            },
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tractor Power
              _buildSectionTitle('Equipamento'),
              const SizedBox(height: 12),
              AdaptiveInputField(
                label: 'Potência do Trator',
                controller: _powerController,
                suffix: 'HP',
                hint: 'Ex: 100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a potência';
                  }
                  final power = double.tryParse(value);
                  if (power == null || power <= 0 || power > 500) {
                    return 'Potência entre 1 e 500 HP';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Load Factor
              _buildSectionTitle('Fator de Carga'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LoadFactor.values.map((factor) {
                  return DarkChoiceChip(
                    label: FuelConsumptionCalculator.getLoadFactorName(factor),
                    isSelected: _loadFactor == factor,
                    onSelected: () {
                      setState(() => _loadFactor = factor);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Operation Type
              _buildSectionTitle('Tipo de Operação'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OperationType.values.map((type) {
                  return DarkChoiceChip(
                    label: FuelConsumptionCalculator.getOperationTypeName(type),
                    isSelected: _operationType == type,
                    onSelected: () {
                      setState(() => _operationType = type);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Work parameters
              _buildSectionTitle('Parâmetros de Trabalho'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 250,
                    child: AdaptiveInputField(
                      label: 'Horas Trabalhadas',
                      controller: _hoursController,
                      suffix: 'h',
                      hint: 'Ex: 8',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe as horas';
                        }
                        final hours = double.tryParse(value);
                        if (hours == null || hours <= 0 || hours > 1000) {
                          return 'Horas entre 0 e 1000';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: AdaptiveInputField(
                      label: 'Área Trabalhada (opcional)',
                      controller: _areaController,
                      suffix: 'ha',
                      hint: 'Ex: 50',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final area = double.tryParse(value);
                          if (area == null || area < 0 || area > 10000) {
                            return 'Área entre 0 e 10000 ha';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fuel price
              SizedBox(
                width: 250,
                child: AdaptiveInputField(
                  label: 'Preço do Diesel (opcional)',
                  controller: _fuelPriceController,
                  suffix: 'R\$/L',
                  hint: 'Ex: 5.50',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final price = double.tryParse(value);
                      if (price == null || price <= 0 || price > 100) {
                        return 'Preço entre 0 e 100 R\$/L';
                      }
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _reset,
                accentColor: CalculatorAccentColors.agriculture,
              ),

              // Result Card
              if (_result != null) ...[
                const SizedBox(height: 32),
                _FuelConsumptionResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

/// Result card widget for fuel consumption calculation
class _FuelConsumptionResultCard extends StatelessWidget {
  final FuelConsumptionResult result;

  const _FuelConsumptionResultCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CalculatorAccentColors.agriculture;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resultado',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: _formatShareText(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total Consumption Highlight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumo Total',
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.totalConsumption.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details Grid
            _buildDetailRow(
              'Potência do Trator',
              '${result.tractorPower.toStringAsFixed(0)} HP',
              Icons.agriculture,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Fator de Carga',
              FuelConsumptionCalculator.getLoadFactorName(result.loadFactor),
              Icons.speed,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Tipo de Operação',
              FuelConsumptionCalculator.getOperationTypeName(
                  result.operationType),
              Icons.build,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Consumo por Hora',
              '${result.consumptionPerHour.toStringAsFixed(2)} L/h',
              Icons.access_time,
            ),

            if (result.consumptionPerHectare > 0) ...[
              _buildDivider(),
              _buildDetailRow(
                'Consumo por Hectare',
                '${result.consumptionPerHectare.toStringAsFixed(2)} L/ha',
                Icons.landscape,
              ),
            ],

            if (result.fieldCapacity > 0) ...[
              _buildDivider(),
              _buildDetailRow(
                'Capacidade de Campo',
                '${result.fieldCapacity.toStringAsFixed(2)} ha/h',
                Icons.speed,
              ),
            ],

            _buildDivider(),
            _buildDetailRow(
              'Horas Trabalhadas',
              '${result.hoursWorked.toStringAsFixed(1)} h',
              Icons.schedule,
            ),

            if (result.areaWorked > 0) ...[
              _buildDivider(),
              _buildDetailRow(
                'Área Trabalhada',
                '${result.areaWorked.toStringAsFixed(2)} ha',
                Icons.terrain,
              ),
            ],

            _buildDivider(),
            _buildDetailRow(
              'Custo Estimado',
              'R\$ ${result.estimatedCost.toStringAsFixed(2)}',
              Icons.attach_money,
            ),

            // Recommendations
            if (result.recommendations.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: accentColor.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recomendações',
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...result.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            rec,
                            style: TextStyle(
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: CalculatorAccentColors.agriculture.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black.withValues(alpha: 0.95),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Divider(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
          height: 1,
        );
      },
    );
  }

  String _formatShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🚜 CONSUMO DE COMBUSTÍVEL');
    buffer.writeln();
    buffer.writeln('Equipamento:');
    buffer.writeln('• Potência: ${result.tractorPower.toStringAsFixed(0)} HP');
    buffer.writeln(
        '• Carga: ${FuelConsumptionCalculator.getLoadFactorName(result.loadFactor)}');
    buffer.writeln(
        '• Operação: ${FuelConsumptionCalculator.getOperationTypeName(result.operationType)}');
    buffer.writeln();
    buffer.writeln('Consumo:');
    buffer.writeln(
        '• Por Hora: ${result.consumptionPerHour.toStringAsFixed(2)} L/h');
    if (result.consumptionPerHectare > 0) {
      buffer.writeln(
          '• Por Hectare: ${result.consumptionPerHectare.toStringAsFixed(2)} L/ha');
    }
    buffer.writeln(
        '• Total: ${result.totalConsumption.toStringAsFixed(1)} L');
    buffer.writeln();
    buffer.writeln('Trabalho Realizado:');
    buffer.writeln('• Horas: ${result.hoursWorked.toStringAsFixed(1)} h');
    if (result.areaWorked > 0) {
      buffer.writeln('• Área: ${result.areaWorked.toStringAsFixed(2)} ha');
    }
    buffer.writeln();
    buffer.writeln(
        'Custo Estimado: R\$ ${result.estimatedCost.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Calculado por App Calculei');

    return buffer.toString();
  }
}
