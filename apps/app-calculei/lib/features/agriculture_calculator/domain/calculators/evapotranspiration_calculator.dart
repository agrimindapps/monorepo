/// Calculadora de Evapotranspiração
/// Estima evapotranspiração de referência (ETo) e necessidades hídricas
library;

class EvapotranspirationResult {
  /// Evapotranspiração de referência (mm/dia)
  final double etoMmDay;

  /// Evapotranspiração semanal (mm)
  final double etoWeekly;

  /// Evapotranspiração mensal (mm)
  final double etoMonthly;

  /// Volume de água por hectare diário (m³/ha)
  final double dailyWaterM3Ha;

  /// Volume de água por hectare semanal (m³/ha)
  final double weeklyWaterM3Ha;

  /// Classificação da demanda evaporativa
  final String demandClassification;

  /// Recomendações de irrigação
  final List<String> recommendations;

  const EvapotranspirationResult({
    required this.etoMmDay,
    required this.etoWeekly,
    required this.etoMonthly,
    required this.dailyWaterM3Ha,
    required this.weeklyWaterM3Ha,
    required this.demandClassification,
    required this.recommendations,
  });
}

class EvapotranspirationCalculator {
  /// Calcula evapotranspiração usando fórmula de Penman-Monteith simplificada
  static EvapotranspirationResult calculate({
    required double temperatureC,
    required double humidityPercent,
    required double windSpeedKmH,
    required double solarRadiationMJm2,
  }) {
    // Conversões
    final windSpeedMs = windSpeedKmH / 3.6;

    // Cálculo simplificado de ETo (Penman-Monteith simplificado)
    // ETo = 0.0023 × (Tmed + 17.8) × √(Tmax - Tmin) × Ra
    // Aqui usamos uma aproximação baseada nos dados disponíveis

    // Pressão de vapor de saturação (kPa)
    final es = 0.6108 * _exp((17.27 * temperatureC) / (temperatureC + 237.3));
    
    // Pressão de vapor atual (kPa)
    final ea = es * (humidityPercent / 100);
    
    // Déficit de pressão de vapor (kPa)
    final vpd = es - ea;

    // Radiação líquida estimada (simplificada)
    final rn = solarRadiationMJm2 * 0.77; // Assume 77% da radiação como líquida

    // Fator aerodinâmico (simplificado)
    final aerodynamicFactor = 900 / (temperatureC + 273);
    final windTerm = aerodynamicFactor * windSpeedMs * vpd;

    // Fator radiativo
    final radiationTerm = 0.408 * rn;

    // ETo (mm/dia) - Penman-Monteith simplificado
    var etoMmDay = (radiationTerm + windTerm) / (1 + 0.34 * windSpeedMs);

    // Validação e limites
    etoMmDay = etoMmDay.clamp(1.0, 15.0);

    // Evapotranspiração semanal e mensal
    final etoWeekly = etoMmDay * 7;
    final etoMonthly = etoMmDay * 30;

    // Conversão para volume (m³/ha)
    // 1 mm = 10 m³/ha
    final dailyWaterM3Ha = etoMmDay * 10;
    final weeklyWaterM3Ha = etoWeekly * 10;

    // Classificação da demanda
    final demandClassification = _classifyDemand(etoMmDay);

    // Recomendações
    final recommendations = _getRecommendations(
      etoMmDay,
      temperatureC,
      humidityPercent,
      windSpeedMs,
    );

    return EvapotranspirationResult(
      etoMmDay: double.parse(etoMmDay.toStringAsFixed(2)),
      etoWeekly: double.parse(etoWeekly.toStringAsFixed(1)),
      etoMonthly: double.parse(etoMonthly.toStringAsFixed(1)),
      dailyWaterM3Ha: double.parse(dailyWaterM3Ha.toStringAsFixed(1)),
      weeklyWaterM3Ha: double.parse(weeklyWaterM3Ha.toStringAsFixed(1)),
      demandClassification: demandClassification,
      recommendations: recommendations,
    );
  }

  static double _exp(double x) {
    // Aproximação de e^x para uso no cálculo
    return 2.71828182845904523536.pow(x);
  }

  static String _classifyDemand(double eto) {
    if (eto < 3.0) {
      return 'Baixa';
    } else if (eto < 5.0) {
      return 'Moderada';
    } else if (eto < 7.0) {
      return 'Alta';
    } else {
      return 'Muito Alta';
    }
  }

  static List<String> _getRecommendations(
    double eto,
    double temp,
    double humidity,
    double wind,
  ) {
    final recommendations = <String>[];

    // Análise de ETo
    if (eto > 7.0) {
      recommendations.add('Demanda evaporativa muito alta: Irrigação frequente necessária');
      recommendations.add('Considere irrigação diária ou dia sim, dia não');
    } else if (eto > 5.0) {
      recommendations.add('Demanda alta: Monitore umidade do solo regularmente');
    } else if (eto > 3.0) {
      recommendations.add('Demanda moderada: Irrigação a cada 2-3 dias pode ser suficiente');
    } else {
      recommendations.add('Demanda baixa: Irrigação espaçada é adequada');
    }

    // Condições específicas
    if (temp > 30) {
      recommendations.add('Temperatura elevada: Evite irrigação nas horas mais quentes');
    }

    if (humidity < 40) {
      recommendations.add('Baixa umidade: Maior perda de água por evaporação');
    }

    if (wind > 3.0) {
      recommendations.add('Vento forte: Afeta distribuição de água na irrigação por aspersão');
    }

    // Recomendações gerais
    recommendations.add('Ajuste valores de ETo pelo coeficiente da cultura (Kc)');
    recommendations.add('Monitore previsão do tempo para otimizar irrigação');
    recommendations.add('Use sensores de umidade do solo para precisão');

    return recommendations;
  }
}

// Extensão para potência
extension on double {
  double pow(double exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return this;
    
    double result = 1;
    double base = this;
    int exp = exponent.abs().toInt();
    
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    
    if (exponent < 0) {
      return 1 / result;
    }
    
    return result;
  }
}
