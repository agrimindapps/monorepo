/// Calculadora de Fluidoterapia para Pets
/// Calcula volumes de fluidos para manutenção e reposição
library;

class FluidTherapyResult {
  /// Volume de manutenção (ml/24h)
  final double maintenanceVolumeMl;

  /// Volume de déficit/desidratação (ml)
  final double deficitVolumeMl;

  /// Volume total nas 24h (ml)
  final double totalVolume24h;

  /// Taxa horária de infusão (ml/h)
  final double hourlyRateMl;

  /// Taxa em gotas/minuto (macrogotas)
  final double dropsPerMinute;

  /// Percentual de desidratação
  final double dehydrationPercent;

  /// Recomendações
  final List<String> recommendations;

  const FluidTherapyResult({
    required this.maintenanceVolumeMl,
    required this.deficitVolumeMl,
    required this.totalVolume24h,
    required this.hourlyRateMl,
    required this.dropsPerMinute,
    required this.dehydrationPercent,
    required this.recommendations,
  });
}

class FluidTherapyCalculator {
  /// Faixa de manutenção: 50-60 ml/kg/dia (média 55)
  static const double _maintenanceFactorMlPerKg = 55.0;

  /// Calcula a fluidoterapia necessária
  static FluidTherapyResult calculate({
    required double weightKg,
    required double dehydrationPercentage,
    double? customMaintenanceFactor,
  }) {
    // Validação
    if (weightKg <= 0 || weightKg > 100) {
      throw ArgumentError('Peso deve estar entre 0 e 100 kg');
    }
    if (dehydrationPercentage < 0 || dehydrationPercentage > 15) {
      throw ArgumentError('Desidratação deve estar entre 0 e 15%');
    }

    final maintenanceFactor =
        customMaintenanceFactor ?? _maintenanceFactorMlPerKg;

    // 1. Volume de manutenção (ml/24h)
    // Fórmula: 50-60 ml × peso(kg)
    final maintenanceVolumeMl = maintenanceFactor * weightKg;

    // 2. Volume de déficit (ml)
    // Fórmula: peso(kg) × desidratação(%) × 10
    final deficitVolumeMl = weightKg * dehydrationPercentage * 10;

    // 3. Volume total nas 24h
    final totalVolume24h = maintenanceVolumeMl + deficitVolumeMl;

    // 4. Taxa horária (ml/h)
    final hourlyRateMl = totalVolume24h / 24;

    // 5. Taxa em gotas/minuto (macrogotas)
    // ml/h ÷ 3 = gotas/min (aproximação: 60 min/h ÷ 20 gotas/ml = 3)
    final dropsPerMinute = hourlyRateMl / 3;

    final recommendations = _getRecommendations(
      dehydrationPercentage,
      weightKg,
      totalVolume24h,
    );

    return FluidTherapyResult(
      maintenanceVolumeMl: maintenanceVolumeMl,
      deficitVolumeMl: deficitVolumeMl,
      totalVolume24h: totalVolume24h,
      hourlyRateMl: hourlyRateMl,
      dropsPerMinute: dropsPerMinute,
      dehydrationPercent: dehydrationPercentage,
      recommendations: recommendations,
    );
  }

  static List<String> _getRecommendations(
    double dehydrationPercent,
    double weightKg,
    double totalVolume,
  ) {
    final recommendations = <String>[
      '⚠️ ESTE CÁLCULO É APENAS ORIENTATIVO',
      'Fluidoterapia deve ser prescrita por veterinário',
      'Monitorar sinais vitais durante aplicação',
    ];

    // Severidade da desidratação
    if (dehydrationPercent < 5) {
      recommendations.add('✅ Desidratação leve - considere via oral');
      recommendations.add('Ofereça água fresca frequentemente');
    } else if (dehydrationPercent < 8) {
      recommendations.add('⚠️ Desidratação moderada - via subcutânea ou IV');
      recommendations.add('Reposição em 12-24 horas');
      recommendations.add('Monitorar turgor de pele e mucosas');
    } else if (dehydrationPercent < 12) {
      recommendations.add('🚨 Desidratação severa - VIA IV OBRIGATÓRIA');
      recommendations.add('Internação veterinária necessária');
      recommendations.add('Reposição gradual para evitar sobrecarga');
      recommendations.add('Monitorar função cardíaca e renal');
    } else {
      recommendations.add('🚨 EMERGÊNCIA - RISCO DE VIDA');
      recommendations.add('Atendimento veterinário imediato');
      recommendations.add('Terapia intensiva necessária');
    }

    // Volume alto - cuidados especiais
    if (totalVolume > 1000) {
      recommendations.add('Volume alto - dividir em múltiplas aplicações');
      recommendations.add('Evitar sobrecarga circulatória');
    }

    // Pets pequenos
    if (weightKg < 5) {
      recommendations.add('Pet pequeno - atenção à velocidade de infusão');
      recommendations.add('Maior risco de sobrecarga de volume');
    }

    recommendations.add('Ajustar conforme resposta clínica do paciente');
    recommendations.add('Soro fisiológico ou Ringer Lactato são opções comuns');

    return recommendations;
  }

  /// Avalia grau de desidratação por sinais clínicos
  static String getDehydrationGuide(double percentage) {
    if (percentage < 5) {
      return 'Leve: Mucosas ligeiramente secas, turgor normal';
    } else if (percentage < 8) {
      return 'Moderada: Mucosas secas, turgor reduzido (< 2s), olhos levemente encovados';
    } else if (percentage < 12) {
      return 'Severa: Mucosas muito secas, turgor lento (2-3s), olhos encovados, fraqueza';
    } else {
      return 'Crítica: Choque, colapso circulatório, risco de morte iminente';
    }
  }
}
