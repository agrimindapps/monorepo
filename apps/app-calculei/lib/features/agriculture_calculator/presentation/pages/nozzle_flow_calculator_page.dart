import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../domain/entities/nozzle_flow_calculation.dart';
import '../../domain/usecases/calculate_nozzle_flow_usecase.dart';
import '../providers/nozzle_flow_calculator_provider.dart';
import '../widgets/nozzle_flow_result_card.dart';

/// Página da calculadora de vazão de bicos pulverizadores
class NozzleFlowCalculatorPage extends ConsumerStatefulWidget {
  const NozzleFlowCalculatorPage({super.key});

  @override
  ConsumerState<NozzleFlowCalculatorPage> createState() =>
      _NozzleFlowCalculatorPageState();
}

class _NozzleFlowCalculatorPageState
    extends ConsumerState<NozzleFlowCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _applicationRateController = TextEditingController();
  final _workingSpeedController = TextEditingController();
  final _nozzleSpacingController = TextEditingController();
  final _pressureController = TextEditingController();
  final _numberOfNozzlesController = TextEditingController();

  // State
  NozzleType _selectedNozzleType = NozzleType.fanJet;

  @override
  void dispose() {
    _applicationRateController.dispose();
    _workingSpeedController.dispose();
    _nozzleSpacingController.dispose();
    _pressureController.dispose();
    _numberOfNozzlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorState = ref.watch(nozzleFlowCalculatorProvider);
    final result = calculatorState.calculation;

    return CalculatorPageLayout(
      title: 'Vazão de Bicos',
      subtitle: 'Cálculo de Bicos Pulverizadores',
      icon: Icons.water_drop,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
      maxContentWidth: 600,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de Bico
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    'Tipo de Bico',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NozzleType.values.map((type) {
                  return DarkChoiceChip(
                    label: type.displayName,
                    isSelected: _selectedNozzleType == type,
                    onSelected: () {
                      setState(() => _selectedNozzleType = type);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Taxa de Aplicação
              AdaptiveInputField(
                controller: _applicationRateController,
                label: 'Taxa de Aplicação',
                hintText: 'Ex: 200',
                suffix: 'L/ha',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a taxa de aplicação';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate <= 0) {
                    return 'Taxa deve ser maior que zero';
                  }
                  if (rate > 1000) {
                    return 'Taxa não pode exceder 1000 L/ha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Velocidade de Trabalho
              AdaptiveInputField(
                controller: _workingSpeedController,
                label: 'Velocidade de Trabalho',
                hintText: 'Ex: 6',
                suffix: 'km/h',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a velocidade';
                  }
                  final speed = double.tryParse(value);
                  if (speed == null || speed <= 0) {
                    return 'Velocidade deve ser maior que zero';
                  }
                  if (speed > 30) {
                    return 'Velocidade não pode exceder 30 km/h';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Espaçamento entre Bicos
              AdaptiveInputField(
                controller: _nozzleSpacingController,
                label: 'Espaçamento entre Bicos',
                hintText: 'Ex: 50',
                suffix: 'cm',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o espaçamento';
                  }
                  final spacing = double.tryParse(value);
                  if (spacing == null || spacing <= 0) {
                    return 'Espaçamento deve ser maior que zero';
                  }
                  if (spacing > 200) {
                    return 'Espaçamento não pode exceder 200 cm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pressão de Trabalho
              AdaptiveInputField(
                controller: _pressureController,
                label: 'Pressão de Trabalho',
                hintText: 'Ex: 3',
                suffix: 'bar',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a pressão';
                  }
                  final pressure = double.tryParse(value);
                  if (pressure == null || pressure <= 0) {
                    return 'Pressão deve ser maior que zero';
                  }
                  if (pressure > 10) {
                    return 'Pressão não pode exceder 10 bar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Número de Bicos
              AdaptiveInputField(
                controller: _numberOfNozzlesController,
                label: 'Número de Bicos na Barra',
                hintText: 'Ex: 24',
                suffix: 'bicos',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número de bicos';
                  }
                  final nozzles = int.tryParse(value);
                  if (nozzles == null || nozzles <= 0) {
                    return 'Número deve ser maior que zero';
                  }
                  if (nozzles > 100) {
                    return 'Número não pode exceder 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Error message
              if (calculatorState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          calculatorState.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Buttons
              CalculatorActionButtons(
                onCalculate: _handleCalculate,
                onClear: _handleClear,
                isLoading: calculatorState.isLoading,
                calculateLabel: 'Calcular Vazão',
                accentColor: CalculatorAccentColors.agriculture,
              ),

              // Result
              if (result != null) ...[
                const SizedBox(height: 24),
                NozzleFlowResultCard(calculation: result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleCalculate() {
    if (_formKey.currentState!.validate()) {
      final params = CalculateNozzleFlowParams(
        applicationRate: double.parse(_applicationRateController.text),
        workingSpeed: double.parse(_workingSpeedController.text),
        nozzleSpacing: double.parse(_nozzleSpacingController.text),
        pressure: double.parse(_pressureController.text),
        nozzleType: _selectedNozzleType,
        numberOfNozzles: int.parse(_numberOfNozzlesController.text),
      );

      ref.read(nozzleFlowCalculatorProvider.notifier).calculate(params);
    }
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    _applicationRateController.clear();
    _workingSpeedController.clear();
    _nozzleSpacingController.clear();
    _pressureController.clear();
    _numberOfNozzlesController.clear();
    setState(() {
      _selectedNozzleType = NozzleType.fanJet;
    });
    ref.read(nozzleFlowCalculatorProvider.notifier).clearCalculation();
  }
}
