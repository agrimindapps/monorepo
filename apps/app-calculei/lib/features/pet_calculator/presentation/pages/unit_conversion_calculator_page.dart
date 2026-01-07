import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/unit_conversion_calculator.dart';

/// Página da calculadora de Conversão de Unidades
class UnitConversionCalculatorPage extends StatefulWidget {
  const UnitConversionCalculatorPage({super.key});

  @override
  State<UnitConversionCalculatorPage> createState() =>
      _UnitConversionCalculatorPageState();
}

class _UnitConversionCalculatorPageState
    extends State<UnitConversionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  UnitType _unitType = UnitType.weight;
  
  // Weight
  WeightUnit _fromWeightUnit = WeightUnit.kg;
  WeightUnit _toWeightUnit = WeightUnit.lb;
  
  // Length
  LengthUnit _fromLengthUnit = LengthUnit.cm;
  LengthUnit _toLengthUnit = LengthUnit.inch;
  
  // Temperature
  TemperatureUnit _fromTempUnit = TemperatureUnit.celsius;
  TemperatureUnit _toTempUnit = TemperatureUnit.fahrenheit;
  
  // Volume
  VolumeUnit _fromVolumeUnit = VolumeUnit.ml;
  VolumeUnit _toVolumeUnit = VolumeUnit.oz;
  
  // Medication
  MedicationUnit _fromMedUnit = MedicationUnit.mg;
  MedicationUnit _toMedUnit = MedicationUnit.mcg;

  UnitConversionResult? _result;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversão de Unidades'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Conversor Veterinário',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Converta unidades comuns em medicina veterinária: peso, comprimento, temperatura, volume e medicação.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Tipo de Conversão',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Unit Type Selection
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: UnitType.values.map((type) {
                                return ChoiceChip(
                                  label: Text(_getUnitTypeLabel(type)),
                                  avatar: Icon(
                                    _getUnitTypeIcon(type),
                                    size: 18,
                                  ),
                                  selected: _unitType == type,
                                  onSelected: (_) {
                                    setState(() {
                                      _unitType = type;
                                      _result = null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Value Input
                            StandardInputField(
                              label: 'Valor',
                              controller: _valueController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*\.?\d*'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // From/To Unit Selectors
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'De:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildFromUnitDropdown(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Para:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildToUnitDropdown(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Converter',
                              icon: Icons.swap_horiz,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result
                  if (_result != null)
                    _UnitConversionResultCard(result: _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFromUnitDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _getFromUnitValue(),
        isExpanded: true,
        underline: const SizedBox(),
        items: _getUnitOptions().map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() => _setFromUnit(newValue));
          }
        },
      ),
    );
  }

  Widget _buildToUnitDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _getToUnitValue(),
        isExpanded: true,
        underline: const SizedBox(),
        items: _getUnitOptions().map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() => _setToUnit(newValue));
          }
        },
      ),
    );
  }

  String _getUnitTypeLabel(UnitType type) {
    return switch (type) {
      UnitType.weight => 'Peso',
      UnitType.length => 'Comprimento',
      UnitType.temperature => 'Temperatura',
      UnitType.volume => 'Volume',
      UnitType.medication => 'Medicação',
    };
  }

  IconData _getUnitTypeIcon(UnitType type) {
    return switch (type) {
      UnitType.weight => Icons.monitor_weight,
      UnitType.length => Icons.straighten,
      UnitType.temperature => Icons.thermostat,
      UnitType.volume => Icons.water_drop,
      UnitType.medication => Icons.medication,
    };
  }

  List<String> _getUnitOptions() {
    return switch (_unitType) {
      UnitType.weight => ['kg', 'lb', 'g', 'oz'],
      UnitType.length => ['cm', 'polegadas', 'm', 'pés'],
      UnitType.temperature => ['°C', '°F'],
      UnitType.volume => ['ml', 'oz', 'L', 'galões'],
      UnitType.medication => ['mg', 'mcg', 'g', 'ml'],
    };
  }

  String _getFromUnitValue() {
    return switch (_unitType) {
      UnitType.weight => _fromWeightUnit.name,
      UnitType.length => _fromLengthUnit == LengthUnit.inch
          ? 'polegadas'
          : _fromLengthUnit == LengthUnit.ft
              ? 'pés'
              : _fromLengthUnit.name,
      UnitType.temperature => _fromTempUnit == TemperatureUnit.celsius ? '°C' : '°F',
      UnitType.volume => _fromVolumeUnit == VolumeUnit.gal
          ? 'galões'
          : _fromVolumeUnit.name,
      UnitType.medication => _fromMedUnit.name,
    };
  }

  String _getToUnitValue() {
    return switch (_unitType) {
      UnitType.weight => _toWeightUnit.name,
      UnitType.length => _toLengthUnit == LengthUnit.inch
          ? 'polegadas'
          : _toLengthUnit == LengthUnit.ft
              ? 'pés'
              : _toLengthUnit.name,
      UnitType.temperature => _toTempUnit == TemperatureUnit.celsius ? '°C' : '°F',
      UnitType.volume => _toVolumeUnit == VolumeUnit.gal ? 'galões' : _toVolumeUnit.name,
      UnitType.medication => _toMedUnit.name,
    };
  }

  void _setFromUnit(String value) {
    switch (_unitType) {
      case UnitType.weight:
        _fromWeightUnit = WeightUnit.values.firstWhere((e) => e.name == value);
        break;
      case UnitType.length:
        if (value == 'polegadas') {
          _fromLengthUnit = LengthUnit.inch;
        } else if (value == 'pés') {
          _fromLengthUnit = LengthUnit.ft;
        } else {
          _fromLengthUnit = LengthUnit.values.firstWhere((e) => e.name == value);
        }
        break;
      case UnitType.temperature:
        _fromTempUnit = value == '°C'
            ? TemperatureUnit.celsius
            : TemperatureUnit.fahrenheit;
        break;
      case UnitType.volume:
        if (value == 'galões') {
          _fromVolumeUnit = VolumeUnit.gal;
        } else {
          _fromVolumeUnit = VolumeUnit.values.firstWhere((e) => e.name == value);
        }
        break;
      case UnitType.medication:
        _fromMedUnit = MedicationUnit.values.firstWhere((e) => e.name == value);
        break;
    }
  }

  void _setToUnit(String value) {
    switch (_unitType) {
      case UnitType.weight:
        _toWeightUnit = WeightUnit.values.firstWhere((e) => e.name == value);
        break;
      case UnitType.length:
        if (value == 'polegadas') {
          _toLengthUnit = LengthUnit.inch;
        } else if (value == 'pés') {
          _toLengthUnit = LengthUnit.ft;
        } else {
          _toLengthUnit = LengthUnit.values.firstWhere((e) => e.name == value);
        }
        break;
      case UnitType.temperature:
        _toTempUnit = value == '°C'
            ? TemperatureUnit.celsius
            : TemperatureUnit.fahrenheit;
        break;
      case UnitType.volume:
        if (value == 'galões') {
          _toVolumeUnit = VolumeUnit.gal;
        } else {
          _toVolumeUnit = VolumeUnit.values.firstWhere((e) => e.name == value);
        }
        break;
      case UnitType.medication:
        _toMedUnit = MedicationUnit.values.firstWhere((e) => e.name == value);
        break;
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final value = double.parse(_valueController.text);

    final result = switch (_unitType) {
      UnitType.weight => UnitConversionCalculator.convertWeight(
          value: value,
          fromUnit: _fromWeightUnit,
          toUnit: _toWeightUnit,
        ),
      UnitType.length => UnitConversionCalculator.convertLength(
          value: value,
          fromUnit: _fromLengthUnit,
          toUnit: _toLengthUnit,
        ),
      UnitType.temperature => UnitConversionCalculator.convertTemperature(
          value: value,
          fromUnit: _fromTempUnit,
          toUnit: _toTempUnit,
        ),
      UnitType.volume => UnitConversionCalculator.convertVolume(
          value: value,
          fromUnit: _fromVolumeUnit,
          toUnit: _toVolumeUnit,
        ),
      UnitType.medication => UnitConversionCalculator.convertMedication(
          value: value,
          fromUnit: _fromMedUnit,
          toUnit: _toMedUnit,
        ),
    };

    setState(() => _result = result);
  }
}

class _UnitConversionResultCard extends StatelessWidget {
  final UnitConversionResult result;

  const _UnitConversionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: '''
📋 Conversão de Unidades - Calculei App

${result.conversionType}
${result.fromValue.toStringAsFixed(2)} ${result.fromUnit} = ${result.toValue.toStringAsFixed(2)} ${result.toUnit}

Fórmula: ${result.formula}

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            result.fromValue.toStringAsFixed(2),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          Text(
                            result.fromUnit,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            result.toValue.toStringAsFixed(2),
                            style:
                                Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                          ),
                          Text(
                            result.toUnit,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'Tipo',
                    value: result.conversionType,
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Conversão',
                    value: result.formula,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
