import '../entities/calculator_parameter.dart';

/// Serviço de conversão de unidades para calculadoras agrícolas
/// 
/// Implementa conversões completas entre todas as unidades suportadas
/// com precisão e validação adequadas para uso agrícola
class UnitConversionService {
  // Fatores de conversão base para diferentes categorias
  
  /// Conversões de área (base: metros quadrados)
  static const Map<ParameterUnit, double> _areaConversions = {
    ParameterUnit.metro2: 1.0,
    ParameterUnit.hectare: 10000.0,
    ParameterUnit.acre: 4046.86,
  };

  /// Conversões de volume (base: litros)
  static const Map<ParameterUnit, double> _volumeConversions = {
    ParameterUnit.litro: 1.0,
    ParameterUnit.metro3: 1000.0,
  };

  /// Conversões de peso/massa (base: gramas)
  static const Map<ParameterUnit, double> _weightConversions = {
    ParameterUnit.gramas: 1.0,
    ParameterUnit.grama: 1.0,
    ParameterUnit.kg: 1000.0,
    ParameterUnit.quilograma: 1000.0,
    ParameterUnit.tonelada: 1000000.0,
  };

  /// Conversões de distância (base: metros)
  static const Map<ParameterUnit, double> _distanceConversions = {
    ParameterUnit.metro: 1.0,
    ParameterUnit.centimetro: 0.01,
    ParameterUnit.milimetro: 0.001,
    ParameterUnit.kilometro: 1000.0,
  };

  /// Conversões de tempo (base: dias)
  static const Map<ParameterUnit, double> _timeConversions = {
    ParameterUnit.dia: 1.0,
    ParameterUnit.mes: 30.44, // Média de dias por mês
    ParameterUnit.ano: 365.25, // Considerando anos bissextos
  };

  /// Converte valor entre unidades da mesma categoria
  static ConversionResult convert({
    required double value,
    required ParameterUnit fromUnit,
    required ParameterUnit toUnit,
  }) {
    try {
      // Se as unidades são iguais, não há conversão
      if (fromUnit == toUnit) {
        return ConversionResult.success(value, fromUnit, toUnit);
      }

      // Determinar categoria e executar conversão
      final category = _getUnitCategory(fromUnit);
      
      if (category != _getUnitCategory(toUnit)) {
        return ConversionResult.error(
          'Não é possível converter entre categorias diferentes: '
          '${fromUnit.name} para ${toUnit.name}',
        );
      }

      final convertedValue = _performConversion(value, fromUnit, toUnit, category);
      
      if (convertedValue == null) {
        return ConversionResult.error(
          'Conversão não suportada: ${fromUnit.name} para ${toUnit.name}',
        );
      }

      return ConversionResult.success(convertedValue, fromUnit, toUnit);
    } catch (e) {
      return ConversionResult.error('Erro na conversão: $e');
    }
  }

  /// Converte múltiplos valores em lote
  static Map<String, ConversionResult> convertBatch({
    required Map<String, double> values,
    required Map<String, ParameterUnit> fromUnits,
    required Map<String, ParameterUnit> toUnits,
  }) {
    final results = <String, ConversionResult>{};

    for (final key in values.keys) {
      final value = values[key];
      final fromUnit = fromUnits[key];
      final toUnit = toUnits[key];

      if (value != null && fromUnit != null && toUnit != null) {
        results[key] = convert(
          value: value,
          fromUnit: fromUnit,
          toUnit: toUnit,
        );
      }
    }

    return results;
  }

  /// Normaliza valor para unidade base da categoria
  static double normalizeToBase(double value, ParameterUnit unit) {
    final category = _getUnitCategory(unit);
    
    switch (category) {
      case UnitCategory.area:
        return value * (_areaConversions[unit] ?? 1.0);
      case UnitCategory.volume:
        return value * (_volumeConversions[unit] ?? 1.0);
      case UnitCategory.weight:
        return value * (_weightConversions[unit] ?? 1.0);
      case UnitCategory.distance:
        return value * (_distanceConversions[unit] ?? 1.0);
      case UnitCategory.time:
        return value * (_timeConversions[unit] ?? 1.0);
      case UnitCategory.temperature:
        return _convertTemperatureToBase(value, unit);
      case UnitCategory.pressure:
        return _convertPressureToBase(value, unit);
      case UnitCategory.concentration:
        return value; // Base units vary, handled separately
      case UnitCategory.none:
      case UnitCategory.percentage:
      default:
        return value;
    }
  }

  /// Converte valor da unidade base para unidade específica
  static double denormalizeFromBase(double baseValue, ParameterUnit unit) {
    final category = _getUnitCategory(unit);
    
    switch (category) {
      case UnitCategory.area:
        return baseValue / (_areaConversions[unit] ?? 1.0);
      case UnitCategory.volume:
        return baseValue / (_volumeConversions[unit] ?? 1.0);
      case UnitCategory.weight:
        return baseValue / (_weightConversions[unit] ?? 1.0);
      case UnitCategory.distance:
        return baseValue / (_distanceConversions[unit] ?? 1.0);
      case UnitCategory.time:
        return baseValue / (_timeConversions[unit] ?? 1.0);
      case UnitCategory.temperature:
        return _convertTemperatureFromBase(baseValue, unit);
      case UnitCategory.pressure:
        return _convertPressureFromBase(baseValue, unit);
      case UnitCategory.concentration:
        return baseValue; // Base units vary, handled separately
      case UnitCategory.none:
      case UnitCategory.percentage:
      default:
        return baseValue;
    }
  }

  /// Obtém unidades compatíveis para conversão
  static List<ParameterUnit> getCompatibleUnits(ParameterUnit unit) {
    final category = _getUnitCategory(unit);
    
    switch (category) {
      case UnitCategory.area:
        return [ParameterUnit.metro2, ParameterUnit.hectare, ParameterUnit.acre];
      case UnitCategory.volume:
        return [ParameterUnit.litro, ParameterUnit.metro3];
      case UnitCategory.weight:
        return [
          ParameterUnit.gramas,
          ParameterUnit.grama,
          ParameterUnit.kg,
          ParameterUnit.quilograma,
          ParameterUnit.tonelada,
        ];
      case UnitCategory.distance:
        return [
          ParameterUnit.milimetro,
          ParameterUnit.centimetro,
          ParameterUnit.metro,
          ParameterUnit.kilometro,
        ];
      case UnitCategory.time:
        return [ParameterUnit.dia, ParameterUnit.mes, ParameterUnit.ano];
      case UnitCategory.temperature:
        return [ParameterUnit.celsius];
      case UnitCategory.pressure:
        return [ParameterUnit.bar, ParameterUnit.atm];
      case UnitCategory.concentration:
        return [ParameterUnit.ppm, ParameterUnit.mgL, ParameterUnit.mgdm3];
      default:
        return [unit];
    }
  }

  /// Determina a categoria de uma unidade
  static UnitCategory _getUnitCategory(ParameterUnit unit) {
    if (_areaConversions.containsKey(unit)) return UnitCategory.area;
    if (_volumeConversions.containsKey(unit)) return UnitCategory.volume;
    if (_weightConversions.containsKey(unit)) return UnitCategory.weight;
    if (_distanceConversions.containsKey(unit)) return UnitCategory.distance;
    if (_timeConversions.containsKey(unit)) return UnitCategory.time;
    
    switch (unit) {
      case ParameterUnit.celsius:
        return UnitCategory.temperature;
      case ParameterUnit.bar:
      case ParameterUnit.atm:
        return UnitCategory.pressure;
      case ParameterUnit.ppm:
      case ParameterUnit.mgL:
      case ParameterUnit.mgdm3:
      case ParameterUnit.cmolcdm3:
        return UnitCategory.concentration;
      case ParameterUnit.percentual:
        return UnitCategory.percentage;
      default:
        return UnitCategory.none;
    }
  }

  /// Executa conversão entre unidades da mesma categoria
  static double? _performConversion(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
    UnitCategory category,
  ) {
    switch (category) {
      case UnitCategory.area:
        return _convertBetweenUnits(value, fromUnit, toUnit, _areaConversions);
      case UnitCategory.volume:
        return _convertBetweenUnits(value, fromUnit, toUnit, _volumeConversions);
      case UnitCategory.weight:
        return _convertBetweenUnits(value, fromUnit, toUnit, _weightConversions);
      case UnitCategory.distance:
        return _convertBetweenUnits(value, fromUnit, toUnit, _distanceConversions);
      case UnitCategory.time:
        return _convertBetweenUnits(value, fromUnit, toUnit, _timeConversions);
      case UnitCategory.temperature:
        return _convertTemperature(value, fromUnit, toUnit);
      case UnitCategory.pressure:
        return _convertPressure(value, fromUnit, toUnit);
      case UnitCategory.concentration:
        return _convertConcentration(value, fromUnit, toUnit);
      default:
        return null;
    }
  }

  /// Conversão genérica entre unidades usando fatores
  static double _convertBetweenUnits(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
    Map<ParameterUnit, double> conversionFactors,
  ) {
    final fromFactor = conversionFactors[fromUnit] ?? 1.0;
    final toFactor = conversionFactors[toUnit] ?? 1.0;
    
    // Converter para base e depois para unidade final
    final baseValue = value * fromFactor;
    return baseValue / toFactor;
  }

  /// Conversões específicas de temperatura
  static double _convertTemperature(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
  ) {
    // Por enquanto, apenas Celsius é suportado
    if (fromUnit == ParameterUnit.celsius && toUnit == ParameterUnit.celsius) {
      return value;
    }
    throw UnsupportedError('Conversão de temperatura não suportada');
  }

  static double _convertTemperatureToBase(double value, ParameterUnit unit) {
    if (unit == ParameterUnit.celsius) return value;
    throw UnsupportedError('Unidade de temperatura não suportada: $unit');
  }

  static double _convertTemperatureFromBase(double baseValue, ParameterUnit unit) {
    if (unit == ParameterUnit.celsius) return baseValue;
    throw UnsupportedError('Unidade de temperatura não suportada: $unit');
  }

  /// Conversões específicas de pressão
  static double _convertPressure(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
  ) {
    const barToAtm = 0.986923; // 1 bar = 0.986923 atm
    
    if (fromUnit == ParameterUnit.bar && toUnit == ParameterUnit.atm) {
      return value * barToAtm;
    } else if (fromUnit == ParameterUnit.atm && toUnit == ParameterUnit.bar) {
      return value / barToAtm;
    } else if (fromUnit == toUnit) {
      return value;
    }
    
    throw UnsupportedError('Conversão de pressão não suportada: $fromUnit para $toUnit');
  }

  static double _convertPressureToBase(double value, ParameterUnit unit) {
    // Base: bar
    if (unit == ParameterUnit.bar) return value;
    if (unit == ParameterUnit.atm) return value / 0.986923;
    throw UnsupportedError('Unidade de pressão não suportada: $unit');
  }

  static double _convertPressureFromBase(double baseValue, ParameterUnit unit) {
    // Base: bar
    if (unit == ParameterUnit.bar) return baseValue;
    if (unit == ParameterUnit.atm) return baseValue * 0.986923;
    throw UnsupportedError('Unidade de pressão não suportada: $unit');
  }

  /// Conversões específicas de concentração
  static double _convertConcentration(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
  ) {
    // Conversões básicas de concentração
    // Nota: Algumas conversões podem precisar de densidade específica
    
    if (fromUnit == toUnit) return value;
    
    // ppm para mg/L (para água, são aproximadamente iguais)
    if (fromUnit == ParameterUnit.ppm && toUnit == ParameterUnit.mgL) {
      return value;
    } else if (fromUnit == ParameterUnit.mgL && toUnit == ParameterUnit.ppm) {
      return value;
    }
    
    // mg/L para mg/dm³ (são iguais)
    if ((fromUnit == ParameterUnit.mgL && toUnit == ParameterUnit.mgdm3) ||
        (fromUnit == ParameterUnit.mgdm3 && toUnit == ParameterUnit.mgL)) {
      return value;
    }
    
    throw UnsupportedError('Conversão de concentração não suportada: $fromUnit para $toUnit');
  }

  /// Formata valor com unidade apropriada
  static String formatValueWithUnit(
    double value,
    ParameterUnit unit, {
    int? decimalPlaces,
  }) {
    final unitSymbol = _getUnitSymbol(unit);
    final places = decimalPlaces ?? _getDefaultDecimalPlaces(unit);
    
    final formattedValue = value.toStringAsFixed(places);
    
    if (unitSymbol.isEmpty) {
      return formattedValue;
    }
    
    return '$formattedValue $unitSymbol';
  }

  /// Obtém símbolo da unidade
  static String _getUnitSymbol(ParameterUnit unit) {
    switch (unit) {
      case ParameterUnit.hectare:
        return 'ha';
      case ParameterUnit.metro2:
        return 'm²';
      case ParameterUnit.acre:
        return 'acre';
      case ParameterUnit.litro:
        return 'L';
      case ParameterUnit.metro3:
        return 'm³';
      case ParameterUnit.kg:
      case ParameterUnit.quilograma:
        return 'kg';
      case ParameterUnit.tonelada:
        return 't';
      case ParameterUnit.gramas:
      case ParameterUnit.grama:
        return 'g';
      case ParameterUnit.metro:
        return 'm';
      case ParameterUnit.centimetro:
        return 'cm';
      case ParameterUnit.kilometro:
        return 'km';
      case ParameterUnit.milimetro:
        return 'mm';
      case ParameterUnit.percentual:
        return '%';
      case ParameterUnit.dia:
        return 'dias';
      case ParameterUnit.mes:
        return 'meses';
      case ParameterUnit.ano:
        return 'anos';
      case ParameterUnit.celsius:
        return '°C';
      case ParameterUnit.bar:
        return 'bar';
      case ParameterUnit.atm:
        return 'atm';
      case ParameterUnit.ppm:
        return 'ppm';
      case ParameterUnit.mgL:
        return 'mg/L';
      case ParameterUnit.mgdm3:
        return 'mg/dm³';
      case ParameterUnit.cmolcdm3:
        return 'cmolc/dm³';
      case ParameterUnit.plantasha:
        return 'plantas/ha';
      case ParameterUnit.cabecas:
        return 'cabeças';
      case ParameterUnit.mcalkg:
        return 'Mcal/kg';
      case ParameterUnit.litroha:
        return 'L/ha';
      case ParameterUnit.gcm3:
        return 'g/cm³';
      case ParameterUnit.dsm:
        return 'dS/m';
      default:
        return '';
    }
  }

  /// Obtém número padrão de casas decimais por unidade
  static int _getDefaultDecimalPlaces(ParameterUnit unit) {
    switch (unit) {
      case ParameterUnit.hectare:
      case ParameterUnit.acre:
      case ParameterUnit.metro2:
        return 2;
      case ParameterUnit.kg:
      case ParameterUnit.quilograma:
        return 1;
      case ParameterUnit.gramas:
      case ParameterUnit.grama:
        return 0;
      case ParameterUnit.tonelada:
        return 3;
      case ParameterUnit.percentual:
        return 1;
      case ParameterUnit.celsius:
        return 1;
      case ParameterUnit.ppm:
      case ParameterUnit.mgL:
      case ParameterUnit.mgdm3:
        return 2;
      default:
        return 2;
    }
  }
}

/// Categorias de unidades para conversão
enum UnitCategory {
  area,
  volume,
  weight,
  distance,
  time,
  temperature,
  pressure,
  concentration,
  percentage,
  none,
}

/// Resultado de conversão de unidade
class ConversionResult {
  final bool isSuccess;
  final double? value;
  final ParameterUnit? fromUnit;
  final ParameterUnit? toUnit;
  final String? errorMessage;

  const ConversionResult._({
    required this.isSuccess,
    this.value,
    this.fromUnit,
    this.toUnit,
    this.errorMessage,
  });

  factory ConversionResult.success(
    double value,
    ParameterUnit fromUnit,
    ParameterUnit toUnit,
  ) {
    return ConversionResult._(
      isSuccess: true,
      value: value,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
  }

  factory ConversionResult.error(String message) {
    return ConversionResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}