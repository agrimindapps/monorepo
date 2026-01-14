import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
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
    const accentColor = CalculatorAccentColors.pet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CalculatorPageLayout(
      title: 'Conversor Veterinário',
      subtitle: 'Conversão de Unidades',
      icon: Icons.swap_horiz,
      accentColor: accentColor,
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              Share.share('''
📋 Conversão de Unidades - Calculei App

${_result!.conversionType}
${_result!.fromValue.toStringAsFixed(2)} ${_result!.fromUnit} = ${_result!.toValue.toStringAsFixed(2)} ${_result!.toUnit}

Fórmula: ${_result!.formula}

_________________
Calculado por Calculei
by Agrimind
https://calculei.agrimind.com.br''');
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
              // Unit Type Selection
              Text(
                'Tipo de Conversão',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UnitType.values.map((type) {
                  final isSelected = _unitType == type;
                  return Material(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.15)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _unitType = type;
                          _result = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? accentColor
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getUnitTypeIcon(type),
                              size: 18,
                              color: isSelected
                                  ? accentColor
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.black.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getUnitTypeLabel(type),
                              style: TextStyle(
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? accentColor
                                    : isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.black.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Value Input
              AdaptiveInputField(
                label: 'Valor',
                hintText: 'Ex: 10',
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
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

              const SizedBox(height: 20),

              // From/To Unit Selectors
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'De:',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFromUnitDropdown(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28, left: 12, right: 12),
                    child: Icon(
                      Icons.arrow_forward,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Para:',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.7),
                            fontSize: 13,
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

              const SizedBox(height: 32),

              // Calculate button
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.pet,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _UnitConversionResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFromUnitDropdown() {
    const accentColor = CalculatorAccentColors.pet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _getFromUnitValue(),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: accentColor,
        ),
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
    const accentColor = CalculatorAccentColors.pet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _getToUnitValue(),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: accentColor,
        ),
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

  void _clear() {
    _valueController.clear();
    setState(() {
      _unitType = UnitType.weight;
      _fromWeightUnit = WeightUnit.kg;
      _toWeightUnit = WeightUnit.lb;
      _fromLengthUnit = LengthUnit.cm;
      _toLengthUnit = LengthUnit.inch;
      _fromTempUnit = TemperatureUnit.celsius;
      _toTempUnit = TemperatureUnit.fahrenheit;
      _fromVolumeUnit = VolumeUnit.ml;
      _toVolumeUnit = VolumeUnit.oz;
      _fromMedUnit = MedicationUnit.mg;
      _toMedUnit = MedicationUnit.mcg;
      _result = null;
    });
  }
}

class _UnitConversionResultCard extends StatelessWidget {
  final UnitConversionResult result;

  const _UnitConversionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.pet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main result
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      result.fromValue.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.fromUnit,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.arrow_forward,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      result.toValue.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.toUnit,
                      style: TextStyle(
                        fontSize: 14,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  label: 'Tipo',
                  value: result.conversionType,
                  isDark: isDark,
                ),
                Divider(
                  height: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
                _DetailRow(
                  label: 'Conversão',
                  value: result.formula,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
