/// Calculadora de Conversão de Unidades para Veterinária
/// Converte unidades comuns usadas em medicina veterinária
library;

enum UnitType {
  weight,
  length,
  temperature,
  volume,
  medication,
}

enum WeightUnit { kg, lb, g, oz }
enum LengthUnit { cm, inch, m, ft }
enum TemperatureUnit { celsius, fahrenheit }
enum VolumeUnit { ml, oz, l, gal }
enum MedicationUnit { mg, mcg, g, ml }

class UnitConversionResult {
  /// Valor original
  final double fromValue;

  /// Unidade original
  final String fromUnit;

  /// Valor convertido
  final double toValue;

  /// Unidade de destino
  final String toUnit;

  /// Tipo de conversão
  final String conversionType;

  /// Fórmula usada
  final String formula;

  const UnitConversionResult({
    required this.fromValue,
    required this.fromUnit,
    required this.toValue,
    required this.toUnit,
    required this.conversionType,
    required this.formula,
  });
}

class UnitConversionCalculator {
  // ========== CONVERSÕES DE PESO ==========
  static const double _kgToLb = 2.20462;
  static const double _kgToG = 1000.0;
  static const double _lbToOz = 16.0;

  // ========== CONVERSÕES DE COMPRIMENTO ==========
  static const double _cmToInch = 0.393701;
  static const double _mToFt = 3.28084;

  // ========== CONVERSÕES DE VOLUME ==========
  static const double _mlToOz = 0.033814;
  static const double _lToGal = 0.264172;

  // ========== CONVERSÕES DE MEDICAÇÃO ==========
  static const double _gToMg = 1000.0;
  static const double _mgToMcg = 1000.0;

  /// Converte peso
  static UnitConversionResult convertWeight({
    required double value,
    required WeightUnit fromUnit,
    required WeightUnit toUnit,
  }) {
    if (value < 0) {
      throw ArgumentError('Valor não pode ser negativo');
    }

    // Converte tudo para kg primeiro
    double valueInKg = switch (fromUnit) {
      WeightUnit.kg => value,
      WeightUnit.lb => value / _kgToLb,
      WeightUnit.g => value / _kgToG,
      WeightUnit.oz => value / (_kgToLb * _lbToOz),
    };

    // Converte de kg para unidade de destino
    double result = switch (toUnit) {
      WeightUnit.kg => valueInKg,
      WeightUnit.lb => valueInKg * _kgToLb,
      WeightUnit.g => valueInKg * _kgToG,
      WeightUnit.oz => valueInKg * _kgToLb * _lbToOz,
    };

    return UnitConversionResult(
      fromValue: value,
      fromUnit: _getWeightUnitName(fromUnit),
      toValue: result,
      toUnit: _getWeightUnitName(toUnit),
      conversionType: 'Peso',
      formula: _getWeightFormula(fromUnit, toUnit),
    );
  }

  /// Converte comprimento
  static UnitConversionResult convertLength({
    required double value,
    required LengthUnit fromUnit,
    required LengthUnit toUnit,
  }) {
    if (value < 0) {
      throw ArgumentError('Valor não pode ser negativo');
    }

    // Converte tudo para cm primeiro
    double valueInCm = switch (fromUnit) {
      LengthUnit.cm => value,
      LengthUnit.inch => value / _cmToInch,
      LengthUnit.m => value * 100,
      LengthUnit.ft => value / _mToFt * 100,
    };

    // Converte de cm para unidade de destino
    double result = switch (toUnit) {
      LengthUnit.cm => valueInCm,
      LengthUnit.inch => valueInCm * _cmToInch,
      LengthUnit.m => valueInCm / 100,
      LengthUnit.ft => valueInCm / 100 * _mToFt,
    };

    return UnitConversionResult(
      fromValue: value,
      fromUnit: _getLengthUnitName(fromUnit),
      toValue: result,
      toUnit: _getLengthUnitName(toUnit),
      conversionType: 'Comprimento',
      formula: _getLengthFormula(fromUnit, toUnit),
    );
  }

  /// Converte temperatura
  static UnitConversionResult convertTemperature({
    required double value,
    required TemperatureUnit fromUnit,
    required TemperatureUnit toUnit,
  }) {
    if (fromUnit == toUnit) {
      return UnitConversionResult(
        fromValue: value,
        fromUnit: _getTemperatureUnitName(fromUnit),
        toValue: value,
        toUnit: _getTemperatureUnitName(toUnit),
        conversionType: 'Temperatura',
        formula: 'Mesma unidade',
      );
    }

    double result;
    String formula;

    if (fromUnit == TemperatureUnit.celsius) {
      // °C para °F: (°C × 9/5) + 32
      result = (value * 9 / 5) + 32;
      formula = '(°C × 9/5) + 32';
    } else {
      // °F para °C: (°F - 32) × 5/9
      result = (value - 32) * 5 / 9;
      formula = '(°F - 32) × 5/9';
    }

    return UnitConversionResult(
      fromValue: value,
      fromUnit: _getTemperatureUnitName(fromUnit),
      toValue: result,
      toUnit: _getTemperatureUnitName(toUnit),
      conversionType: 'Temperatura',
      formula: formula,
    );
  }

  /// Converte volume
  static UnitConversionResult convertVolume({
    required double value,
    required VolumeUnit fromUnit,
    required VolumeUnit toUnit,
  }) {
    if (value < 0) {
      throw ArgumentError('Valor não pode ser negativo');
    }

    // Converte tudo para ml primeiro
    double valueInMl = switch (fromUnit) {
      VolumeUnit.ml => value,
      VolumeUnit.oz => value / _mlToOz,
      VolumeUnit.l => value * 1000,
      VolumeUnit.gal => value / _lToGal * 1000,
    };

    // Converte de ml para unidade de destino
    double result = switch (toUnit) {
      VolumeUnit.ml => valueInMl,
      VolumeUnit.oz => valueInMl * _mlToOz,
      VolumeUnit.l => valueInMl / 1000,
      VolumeUnit.gal => valueInMl / 1000 * _lToGal,
    };

    return UnitConversionResult(
      fromValue: value,
      fromUnit: _getVolumeUnitName(fromUnit),
      toValue: result,
      toUnit: _getVolumeUnitName(toUnit),
      conversionType: 'Volume',
      formula: _getVolumeFormula(fromUnit, toUnit),
    );
  }

  /// Converte medicação
  static UnitConversionResult convertMedication({
    required double value,
    required MedicationUnit fromUnit,
    required MedicationUnit toUnit,
  }) {
    if (value < 0) {
      throw ArgumentError('Valor não pode ser negativo');
    }

    // Converte tudo para mg primeiro
    double valueInMg = switch (fromUnit) {
      MedicationUnit.mg => value,
      MedicationUnit.mcg => value / _mgToMcg,
      MedicationUnit.g => value * _gToMg,
      MedicationUnit.ml => value, // ml = mg para maioria dos medicamentos
    };

    // Converte de mg para unidade de destino
    double result = switch (toUnit) {
      MedicationUnit.mg => valueInMg,
      MedicationUnit.mcg => valueInMg * _mgToMcg,
      MedicationUnit.g => valueInMg / _gToMg,
      MedicationUnit.ml => valueInMg, // ml = mg (aproximação)
    };

    return UnitConversionResult(
      fromValue: value,
      fromUnit: _getMedicationUnitName(fromUnit),
      toValue: result,
      toUnit: _getMedicationUnitName(toUnit),
      conversionType: 'Medicação',
      formula: _getMedicationFormula(fromUnit, toUnit),
    );
  }

  // Helper methods para nomes de unidades
  static String _getWeightUnitName(WeightUnit unit) {
    return switch (unit) {
      WeightUnit.kg => 'kg',
      WeightUnit.lb => 'lb',
      WeightUnit.g => 'g',
      WeightUnit.oz => 'oz',
    };
  }

  static String _getLengthUnitName(LengthUnit unit) {
    return switch (unit) {
      LengthUnit.cm => 'cm',
      LengthUnit.inch => 'polegadas',
      LengthUnit.m => 'm',
      LengthUnit.ft => 'pés',
    };
  }

  static String _getTemperatureUnitName(TemperatureUnit unit) {
    return switch (unit) {
      TemperatureUnit.celsius => '°C',
      TemperatureUnit.fahrenheit => '°F',
    };
  }

  static String _getVolumeUnitName(VolumeUnit unit) {
    return switch (unit) {
      VolumeUnit.ml => 'ml',
      VolumeUnit.oz => 'oz',
      VolumeUnit.l => 'L',
      VolumeUnit.gal => 'galões',
    };
  }

  static String _getMedicationUnitName(MedicationUnit unit) {
    return switch (unit) {
      MedicationUnit.mg => 'mg',
      MedicationUnit.mcg => 'mcg',
      MedicationUnit.g => 'g',
      MedicationUnit.ml => 'ml',
    };
  }

  // Helper methods para fórmulas
  static String _getWeightFormula(WeightUnit from, WeightUnit to) {
    return '${_getWeightUnitName(from)} → ${_getWeightUnitName(to)}';
  }

  static String _getLengthFormula(LengthUnit from, LengthUnit to) {
    return '${_getLengthUnitName(from)} → ${_getLengthUnitName(to)}';
  }

  static String _getVolumeFormula(VolumeUnit from, VolumeUnit to) {
    return '${_getVolumeUnitName(from)} → ${_getVolumeUnitName(to)}';
  }

  static String _getMedicationFormula(MedicationUnit from, MedicationUnit to) {
    return '${_getMedicationUnitName(from)} → ${_getMedicationUnitName(to)}';
  }
}
