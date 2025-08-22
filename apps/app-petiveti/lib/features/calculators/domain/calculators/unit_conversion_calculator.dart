import '../entities/calculation_result.dart';
import '../entities/calculator_input.dart';
import 'base_calculator.dart';

enum UnitCategory {
  weight,
  volume,
  temperature,
  dosage,
  pressure,
  length,
}

enum WeightUnit {
  kg,
  g,
  mg,
  mcg,
  lb,
  oz,
}

enum VolumeUnit {
  l,
  ml,
  gallon,
  quart,
  pint,
  cup,
  fluidOz,
  tablespoon,
  teaspoon,
}

enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

enum DosageUnit {
  mgPerKg,
  mgPerLb,
  unitsPerKg,
  mlPerKg,
  iuPerKg,
}

enum PressureUnit {
  mmHg,
  kPa,
  psi,
  atm,
}

enum LengthUnit {
  cm,
  mm,
  m,
  inch,
  ft,
}

class UnitConversionInput extends CalculatorInput {
  final UnitCategory category;
  final double value;
  final String fromUnit;
  final String toUnit;
  final double? animalWeight; // Para conversões de dosagem

  const UnitConversionInput({
    required this.category,
    required this.value,
    required this.fromUnit,
    required this.toUnit,
    this.animalWeight,
  });

  @override
  List<Object?> get props => [
        category,
        value,
        fromUnit,
        toUnit,
        animalWeight,
      ];
}

class UnitConversionResult extends CalculationResult {
  final double convertedValue;
  final String fromUnitDisplay;
  final String toUnitDisplay;
  final String conversionFormula;
  final double conversionFactor;
  final List<String> relatedConversions;
  final List<String> veterinaryContext;

  const UnitConversionResult({
    required this.convertedValue,
    required this.fromUnitDisplay,
    required this.toUnitDisplay,
    required this.conversionFormula,
    required this.conversionFactor,
    required this.relatedConversions,
    required this.veterinaryContext,
    required super.timestamp,
    required super.calculatorType,
    super.notes,
  });

  @override
  String get primaryResult => convertedValue.toStringAsFixed(4);

  @override
  String get summary => '$fromUnitDisplay → $toUnitDisplay = $primaryResult';

  @override
  List<Object?> get props => [
        convertedValue,
        fromUnitDisplay,
        toUnitDisplay,
        conversionFormula,
        conversionFactor,
        relatedConversions,
        veterinaryContext,
        ...super.props,
      ];
}

class UnitConversionCalculator extends BaseCalculator<UnitConversionInput, UnitConversionResult> {
  @override
  String get name => 'Conversor de Unidades Veterinárias';

  @override
  String get description => 'Converte unidades comuns em medicina veterinária com contexto clínico';

  @override
  UnitConversionResult calculate(UnitConversionInput input) {
    _validateInput(input);

    double convertedValue;
    String formula;
    double factor;

    switch (input.category) {
      case UnitCategory.weight:
        final result = _convertWeight(input.value, input.fromUnit, input.toUnit);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;

      case UnitCategory.volume:
        final result = _convertVolume(input.value, input.fromUnit, input.toUnit);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;

      case UnitCategory.temperature:
        final result = _convertTemperature(input.value, input.fromUnit, input.toUnit);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;

      case UnitCategory.dosage:
        final result = _convertDosage(input.value, input.fromUnit, input.toUnit, input.animalWeight);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;

      case UnitCategory.pressure:
        final result = _convertPressure(input.value, input.fromUnit, input.toUnit);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;

      case UnitCategory.length:
        final result = _convertLength(input.value, input.fromUnit, input.toUnit);
        convertedValue = result['value']!;
        formula = result['formula']!;
        factor = result['factor']!;
        break;
    }

    final relatedConversions = _getRelatedConversions(input);
    final veterinaryContext = _getVeterinaryContext(input);

    return UnitConversionResult(
      convertedValue: convertedValue,
      fromUnitDisplay: '${input.value} ${_getUnitDisplay(input.fromUnit)}',
      toUnitDisplay: '${convertedValue.toStringAsFixed(4)} ${_getUnitDisplay(input.toUnit)}',
      conversionFormula: formula,
      conversionFactor: factor,
      relatedConversions: relatedConversions,
      veterinaryContext: veterinaryContext,
      timestamp: DateTime.now(),
      calculatorType: CalculatorType.unitConversion,
    );
  }

  void _validateInput(UnitConversionInput input) {
    if (input.value < 0) {
      throw ArgumentError('Valor não pode ser negativo');
    }

    if (input.category == UnitCategory.dosage && input.animalWeight == null) {
      throw ArgumentError('Peso do animal é obrigatório para conversões de dosagem');
    }

    if (input.animalWeight != null && input.animalWeight! <= 0) {
      throw ArgumentError('Peso do animal deve ser maior que zero');
    }
  }

  Map<String, dynamic> _convertWeight(double value, String from, String to) {
    // Converter tudo para gramas primeiro
    final Map<String, double> toGrams = {
      'kg': 1000.0,
      'g': 1.0,
      'mg': 0.001,
      'mcg': 0.000001,
      'lb': 453.592,
      'oz': 28.3495,
    };

    double grams = value * toGrams[from]!;
    double result = grams / toGrams[to]!;
    double factor = toGrams[from]! / toGrams[to]!;

    String formula = 'Valor × ${factor.toStringAsFixed(6)}';
    if (factor == 1.0) {
      formula = 'Valor (mesma unidade)';
    } else if (factor > 1) {
      formula = 'Valor × ${factor.toStringAsFixed(2)}';
    } else {
      formula = 'Valor ÷ ${(1/factor).toStringAsFixed(2)}';
    }

    return {
      'value': result,
      'formula': formula,
      'factor': factor,
    };
  }

  Map<String, dynamic> _convertVolume(double value, String from, String to) {
    // Converter tudo para mL primeiro
    final Map<String, double> toML = {
      'l': 1000.0,
      'ml': 1.0,
      'gallon': 3785.41,
      'quart': 946.353,
      'pint': 473.176,
      'cup': 236.588,
      'fluidOz': 29.5735,
      'tablespoon': 14.7868,
      'teaspoon': 4.92892,
    };

    double ml = value * toML[from]!;
    double result = ml / toML[to]!;
    double factor = toML[from]! / toML[to]!;

    String formula = factor > 1 
        ? 'Valor × ${factor.toStringAsFixed(2)}'
        : 'Valor ÷ ${(1/factor).toStringAsFixed(2)}';

    return {
      'value': result,
      'formula': formula,
      'factor': factor,
    };
  }

  Map<String, dynamic> _convertTemperature(double value, String from, String to) {
    double result;
    String formula;

    if (from == to) {
      result = value;
      formula = 'Mesma unidade';
    } else if (from == 'celsius' && to == 'fahrenheit') {
      result = (value * 9/5) + 32;
      formula = '(°C × 9/5) + 32';
    } else if (from == 'fahrenheit' && to == 'celsius') {
      result = (value - 32) * 5/9;
      formula = '(°F - 32) × 5/9';
    } else if (from == 'celsius' && to == 'kelvin') {
      result = value + 273.15;
      formula = '°C + 273.15';
    } else if (from == 'kelvin' && to == 'celsius') {
      result = value - 273.15;
      formula = 'K - 273.15';
    } else if (from == 'fahrenheit' && to == 'kelvin') {
      result = (value - 32) * 5/9 + 273.15;
      formula = '((°F - 32) × 5/9) + 273.15';
    } else if (from == 'kelvin' && to == 'fahrenheit') {
      result = (value - 273.15) * 9/5 + 32;
      formula = '((K - 273.15) × 9/5) + 32';
    } else {
      throw ArgumentError('Conversão de temperatura não suportada');
    }

    return {
      'value': result,
      'formula': formula,
      'factor': 1.0, // Temperatura não tem fator linear simples
    };
  }

  Map<String, dynamic> _convertDosage(double value, String from, String to, double? weight) {
    if (weight == null) {
      throw ArgumentError('Peso necessário para conversão de dosagem');
    }

    double result;
    String formula;
    double factor = 1.0;

    // Conversões comuns de dosagem
    if (from == 'mgPerKg' && to == 'mgPerLb') {
      result = value / 2.20462; // 1 kg = 2.20462 lb
      formula = 'mg/kg ÷ 2.205';
      factor = 1 / 2.20462;
    } else if (from == 'mgPerLb' && to == 'mgPerKg') {
      result = value * 2.20462;
      formula = 'mg/lb × 2.205';
      factor = 2.20462;
    } else if (from == 'mgPerKg') {
      // Calcular dose total para o animal
      result = value * weight;
      formula = 'mg/kg × peso(${weight}kg)';
      factor = weight;
    } else {
      result = value;
      formula = 'Conversão não implementada';
    }

    return {
      'value': result,
      'formula': formula,
      'factor': factor,
    };
  }

  Map<String, dynamic> _convertPressure(double value, String from, String to) {
    // Converter tudo para mmHg primeiro
    final Map<String, double> toMmHg = {
      'mmHg': 1.0,
      'kPa': 7.50062,
      'psi': 51.7149,
      'atm': 760.0,
    };

    double mmHg = value * toMmHg[from]!;
    double result = mmHg / toMmHg[to]!;
    double factor = toMmHg[from]! / toMmHg[to]!;

    String formula = factor > 1 
        ? 'Valor × ${factor.toStringAsFixed(3)}'
        : 'Valor ÷ ${(1/factor).toStringAsFixed(3)}';

    return {
      'value': result,
      'formula': formula,
      'factor': factor,
    };
  }

  Map<String, dynamic> _convertLength(double value, String from, String to) {
    // Converter tudo para cm primeiro
    final Map<String, double> toCm = {
      'cm': 1.0,
      'mm': 0.1,
      'm': 100.0,
      'inch': 2.54,
      'ft': 30.48,
    };

    double cm = value * toCm[from]!;
    double result = cm / toCm[to]!;
    double factor = toCm[from]! / toCm[to]!;

    String formula = factor > 1 
        ? 'Valor × ${factor.toStringAsFixed(3)}'
        : 'Valor ÷ ${(1/factor).toStringAsFixed(3)}';

    return {
      'value': result,
      'formula': formula,
      'factor': factor,
    };
  }

  List<String> _getRelatedConversions(UnitConversionInput input) {
    final conversions = <String>[];

    switch (input.category) {
      case UnitCategory.weight:
        if (input.value == 1 && input.fromUnit == 'kg') {
          conversions.addAll([
            '1 kg = 1,000 g',
            '1 kg = 1,000,000 mg',
            '1 kg = 2.205 lb',
            '1 kg = 35.274 oz',
          ]);
        }
        break;

      case UnitCategory.volume:
        if (input.value == 1 && input.fromUnit == 'ml') {
          conversions.addAll([
            '1 mL = 0.001 L',
            '1 mL = 0.034 fl oz',
            '1 mL = 0.068 tablespoon',
            '1 mL = 0.202 teaspoon',
          ]);
        }
        break;

      case UnitCategory.temperature:
        conversions.addAll([
          'Temperatura corporal normal cão: 38-39°C (100.4-102.2°F)',
          'Temperatura corporal normal gato: 38-39.2°C (100.4-102.6°F)',
          'Hipotermia: <37°C (<98.6°F)',
          'Febre: >39.5°C (>103.1°F)',
        ]);
        break;

      case UnitCategory.dosage:
        conversions.addAll([
          'Dosagem típica anti-inflamatório: 1-2 mg/kg',
          'Dosagem típica antibiótico: 10-20 mg/kg',
          'Dosagem típica analgésico: 2-4 mg/kg',
        ]);
        break;

      case UnitCategory.pressure:
        conversions.addAll([
          'Pressão arterial normal cão: 110-160 mmHg (sistólica)',
          'Pressão arterial normal gato: 120-180 mmHg (sistólica)',
          'Hipertensão: >180 mmHg',
        ]);
        break;

      case UnitCategory.length:
        conversions.addAll([
          'Altura média cão pequeno: 15-25 cm',
          'Altura média cão médio: 25-60 cm',
          'Altura média cão grande: 60+ cm',
        ]);
        break;
    }

    return conversions;
  }

  List<String> _getVeterinaryContext(UnitConversionInput input) {
    final context = <String>[];

    switch (input.category) {
      case UnitCategory.weight:
        context.addAll([
          '📊 Importante para cálculo de dosagens',
          '⚖️ Monitorar variações para avaliar saúde',
          '🎯 Base para necessidades calóricas',
        ]);
        break;

      case UnitCategory.volume:
        context.addAll([
          '💉 Crucial para administração de medicamentos',
          '💧 Importante para fluidoterapia',
          '🥛 Base para cálculo de hidratação',
        ]);
        break;

      case UnitCategory.temperature:
        context.addAll([
          '🌡️ Indicador vital primário',
          '🔥 Febre indica processo inflamatório',
          '❄️ Hipotermia pode indicar choque',
          '📋 Verificar sempre antes de procedimentos',
        ]);
        break;

      case UnitCategory.dosage:
        context.addAll([
          '💊 Dosagem precisa previne toxicidade',
          '⚖️ Sempre calcular baseado no peso atual',
          '🕐 Respeitar intervalos entre doses',
          '📞 Consultar veterinário se dúvidas',
        ]);
        break;

      case UnitCategory.pressure:
        context.addAll([
          '❤️ Indicador de saúde cardiovascular',
          '🔍 Importante em cirurgias',
          '💊 Pode ser afetada por medicamentos',
        ]);
        break;

      case UnitCategory.length:
        context.addAll([
          '📏 Importante para equipamentos (coleiras, etc)',
          '🏥 Necessário para alguns exames',
          '📊 Usado em cálculos de superfície corporal',
        ]);
        break;
    }

    return context;
  }

  String _getUnitDisplay(String unit) {
    final Map<String, String> displays = {
      // Weight
      'kg': 'kg',
      'g': 'g',
      'mg': 'mg',
      'mcg': 'μg',
      'lb': 'lb',
      'oz': 'oz',
      
      // Volume
      'l': 'L',
      'ml': 'mL',
      'gallon': 'gal',
      'quart': 'qt',
      'pint': 'pt',
      'cup': 'cup',
      'fluidOz': 'fl oz',
      'tablespoon': 'tbsp',
      'teaspoon': 'tsp',
      
      // Temperature
      'celsius': '°C',
      'fahrenheit': '°F',
      'kelvin': 'K',
      
      // Dosage
      'mgPerKg': 'mg/kg',
      'mgPerLb': 'mg/lb',
      'unitsPerKg': 'UI/kg',
      'mlPerKg': 'mL/kg',
      'iuPerKg': 'IU/kg',
      
      // Pressure
      'mmHg': 'mmHg',
      'kPa': 'kPa',
      'psi': 'psi',
      'atm': 'atm',
      
      // Length
      'cm': 'cm',
      'mm': 'mm',
      'm': 'm',
      'inch': 'in',
      'ft': 'ft',
    };

    return displays[unit] ?? unit;
  }

  @override
  Map<String, dynamic> getInputParameters() {
    return {
      'category': {
        'type': 'enum',
        'label': 'Categoria de conversão',
        'options': UnitCategory.values,
        'required': true,
      },
      'value': {
        'type': 'double',
        'label': 'Valor a converter',
        'min': 0.0,
        'max': 999999.0,
        'step': 0.001,
        'required': true,
      },
      'fromUnit': {
        'type': 'string',
        'label': 'Unidade de origem',
        'required': true,
      },
      'toUnit': {
        'type': 'string',
        'label': 'Unidade de destino',
        'required': true,
      },
      'animalWeight': {
        'type': 'double',
        'label': 'Peso do animal (kg) - para dosagens',
        'min': 0.1,
        'max': 100.0,
        'step': 0.1,
        'required': false,
      },
    };
  }
}