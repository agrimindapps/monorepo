/// Calculadora de pH do Solo e Calagem
/// Calcula necessidade de calcário para correção do pH do solo
library;

enum SoilTexture {
  sandy, // Arenoso
  loam, // Franco
  clay, // Argiloso
}

class SoilPhResult {
  /// Quantidade de calcário necessária (kg)
  final double limeNeededKg;

  /// Quantidade de calcário por hectare (kg/ha)
  final double limeKgHa;

  /// Quantidade de calcário (toneladas)
  final double limeTons;

  /// Custo estimado (R$)
  final double estimatedCost;

  /// Diferença de pH a corrigir
  final double phDifference;

  /// Recomendações de aplicação
  final List<String> recommendations;

  const SoilPhResult({
    required this.limeNeededKg,
    required this.limeKgHa,
    required this.limeTons,
    required this.estimatedCost,
    required this.phDifference,
    required this.recommendations,
  });
}

class SoilPhCalculator {
  // Fatores de textura para cálculo de calagem
  static const Map<SoilTexture, double> textureFactors = {
    SoilTexture.sandy: 0.8,
    SoilTexture.loam: 1.0,
    SoilTexture.clay: 1.3,
  };

  static const Map<SoilTexture, String> textureNames = {
    SoilTexture.sandy: 'Arenoso',
    SoilTexture.loam: 'Franco',
    SoilTexture.clay: 'Argiloso',
  };

  // Preço médio do calcário (R$/ton)
  static const double limePrice = 150.0;

  /// Calcula necessidade de calcário
  static SoilPhResult calculate({
    required double currentPh,
    required double targetPh,
    required SoilTexture soilTexture,
    required double areaHa,
    double prnt = 90.0, // PRNT do calcário (Poder Relativo de Neutralização Total)
  }) {
    // Validação de pH
    if (currentPh >= targetPh) {
      // Não necessita calagem
      return SoilPhResult(
        limeNeededKg: 0,
        limeKgHa: 0,
        limeTons: 0,
        estimatedCost: 0,
        phDifference: 0,
        recommendations: ['Solo já está no pH adequado'],
      );
    }

    // Diferença de pH
    final phDifference = targetPh - currentPh;

    // Fator de textura
    final textureFactor = textureFactors[soilTexture]!;

    // Cálculo básico: NC (t/ha) = (pH alvo - pH atual) × fator textura × fator profundidade
    // Considerando profundidade padrão de 20cm
    var limeKgHa = phDifference * textureFactor * 1000;

    // Ajuste pelo PRNT (%)
    limeKgHa = limeKgHa * (100 / prnt);

    // Limite máximo recomendado: 5 ton/ha por aplicação
    limeKgHa = limeKgHa.clamp(0, 5000);

    // Total para a área
    final limeNeededKg = limeKgHa * areaHa;
    final limeTons = limeNeededKg / 1000;

    // Custo estimado
    final estimatedCost = limeTons * limePrice;

    // Recomendações
    final recommendations = _getRecommendations(
      phDifference,
      limeKgHa,
      soilTexture,
    );

    return SoilPhResult(
      limeNeededKg: double.parse(limeNeededKg.toStringAsFixed(1)),
      limeKgHa: double.parse(limeKgHa.toStringAsFixed(1)),
      limeTons: double.parse(limeTons.toStringAsFixed(2)),
      estimatedCost: double.parse(estimatedCost.toStringAsFixed(2)),
      phDifference: double.parse(phDifference.toStringAsFixed(1)),
      recommendations: recommendations,
    );
  }

  static List<String> _getRecommendations(
    double phDiff,
    double limeKgHa,
    SoilTexture texture,
  ) {
    final recommendations = <String>[];

    // Recomendações por quantidade
    if (limeKgHa > 4000) {
      recommendations.add('Alta dosagem: Parcele aplicação em 2 vezes (intervalo de 60 dias)');
    } else if (limeKgHa > 2000) {
      recommendations.add('Dosagem moderada: Aplicar em área total');
    } else if (limeKgHa > 0) {
      recommendations.add('Dosagem baixa: Aplicação única é suficiente');
    }

    // Tempo de reação
    if (texture == SoilTexture.sandy) {
      recommendations.add('Solo arenoso: Efeito do calcário em 30-60 dias');
    } else if (texture == SoilTexture.clay) {
      recommendations.add('Solo argiloso: Efeito do calcário em 90-120 dias');
    } else {
      recommendations.add('Solo franco: Efeito do calcário em 60-90 dias');
    }

    // Recomendações gerais
    recommendations.add('Aplicar 60-90 dias antes do plantio');
    recommendations.add('Incorporar ao solo com grade (15-20 cm)');
    recommendations.add('Distribuir uniformemente em área total');
    
    if (phDiff > 1.5) {
      recommendations.add('Grande correção: Considere análise de solo após 3 meses');
    }

    return recommendations;
  }

  static String getTextureName(SoilTexture texture) => textureNames[texture]!;
}
