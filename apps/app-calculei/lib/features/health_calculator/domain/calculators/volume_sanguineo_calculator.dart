/// Calculadora de Volume Sanguíneo
/// Estima o volume total de sangue no corpo usando fórmulas de Nadler
library;

import 'bmi_calculator.dart' show Gender;

class BloodVolumeResult {
  final double volumeLiters;
  final double volumeMl;
  final String method;
  final String interpretation;
  final String recommendation;

  const BloodVolumeResult({
    required this.volumeLiters,
    required this.volumeMl,
    required this.method,
    required this.interpretation,
    required this.recommendation,
  });
}

class VolumeSanguineoCalculator {
  /// Calcula o volume sanguíneo usando fórmula de Nadler ou método simplificado
  static BloodVolumeResult calculate({
    required double weightKg,
    required double heightCm,
    required Gender gender,
    bool useSimplified = false,
  }) {
    final volumeLiters = useSimplified
        ? _calculateSimplified(weightKg, gender)
        : _calculateNadler(weightKg, heightCm, gender);

    final roundedVolume = double.parse(volumeLiters.toStringAsFixed(2));
    final volumeMl = roundedVolume * 1000;

    final method = useSimplified ? 'Método Simplificado' : 'Fórmula de Nadler';
    final interpretation = _getInterpretation(roundedVolume, weightKg);
    final recommendation = _getRecommendation();

    return BloodVolumeResult(
      volumeLiters: roundedVolume,
      volumeMl: double.parse(volumeMl.toStringAsFixed(0)),
      method: method,
      interpretation: interpretation,
      recommendation: recommendation,
    );
  }

  /// Fórmula de Nadler (mais precisa)
  static double _calculateNadler(double weightKg, double heightCm, Gender gender) {
    final heightM = heightCm / 100;

    if (gender == Gender.male) {
      // Homens: 0.3669 × h³ + 0.03219 × w + 0.6041
      return (0.3669 * heightM * heightM * heightM) +
          (0.03219 * weightKg) +
          0.6041;
    } else {
      // Mulheres: 0.3561 × h³ + 0.03308 × w + 0.1833
      return (0.3561 * heightM * heightM * heightM) +
          (0.03308 * weightKg) +
          0.1833;
    }
  }

  /// Método simplificado
  static double _calculateSimplified(double weightKg, Gender gender) {
    final mlPerKg = gender == Gender.male ? 70.0 : 65.0;
    return (weightKg * mlPerKg) / 1000;
  }

  static String _getInterpretation(double volumeLiters, double weightKg) {
    final mlPerKg = (volumeLiters * 1000) / weightKg;

    if (mlPerKg < 60) {
      return 'Volume abaixo da média - possível desidratação ou anemia.';
    } else if (mlPerKg <= 80) {
      return 'Volume sanguíneo dentro da faixa normal.';
    } else {
      return 'Volume acima da média - pode indicar retenção de líquidos.';
    }
  }

  static String _getRecommendation() {
    return 'O volume sanguíneo é importante para transporte de oxigênio e nutrientes. '
        'Mantenha-se hidratado e faça check-ups regulares para monitorar hemoglobina.';
  }
}
