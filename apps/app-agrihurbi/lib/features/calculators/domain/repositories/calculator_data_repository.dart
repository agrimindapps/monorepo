/// Interface para repositório de dados das calculadoras
/// 
/// Define contrato para acesso aos dados hardcoded que foram extraídos
/// das calculadoras individuais. Implementa Dependency Inversion Principle.
abstract class ICalculatorDataRepository {
  
  // ============= CROP REQUIREMENTS =============
  
  /// Obtém exigências nutricionais de uma cultura
  Future<CropRequirementsData> getCropRequirements(String cropType, double expectedYield);
  
  /// Lista todas as culturas disponíveis
  Future<List<String>> getAvailableCrops();
  
  // ============= SOIL TEXTURE =============
  
  /// Obtém fatores relacionados à textura do solo
  Future<SoilTextureData> getSoilTextureFactors(String soilTexture);
  
  /// Lista todas as texturas de solo disponíveis
  Future<List<String>> getAvailableSoilTextures();
  
  // ============= FERTILIZER DATA =============
  
  /// Obtém lista de produtos fertilizantes disponíveis
  Future<List<FertilizerProduct>> getFertilizerProducts();
  
  /// Busca fertilizante por nutriente específico
  Future<FertilizerProduct?> getFertilizerByNutrient(String nutrient);
  
  // ============= APPLICATION SCHEDULE =============
  
  /// Obtém cronograma de aplicação para uma cultura
  Future<List<ApplicationSchedule>> getApplicationSchedule(String cropType);
  
  // ============= PREVIOUS CROP EFFECTS =============
  
  /// Obtém efeitos da cultura anterior
  Future<PreviousCropEffect> getPreviousCropEffect(String previousCrop);
  
  // ============= AGRONOMIC RECOMMENDATIONS =============
  
  /// Gera recomendações agronômicas baseadas nos inputs
  Future<List<String>> getAgronomicRecommendations({
    required String cropType,
    required String soilTexture,
    required double organicMatter,
    required double nNeed,
    required double pNeed,
    required double kNeed,
  });
  
  // ============= UNIT CONVERSION =============
  
  /// Obtém fator de conversão entre unidades
  Future<double> getConversionFactor(String fromUnit, String toUnit);
  
  // ============= VALIDATION RANGES =============
  
  /// Obtém ranges de validação para parâmetros
  Future<ValidationRanges> getValidationRanges(String parameterType);
}

// ============= DATA MODELS =============

/// Dados de exigências nutricionais de culturas
class CropRequirementsData {
  final String cropType;
  final double yieldTarget;
  final double nitrogenPerTon;
  final double phosphorusPerTon;
  final double potassiumPerTon;
  final double totalNitrogen;
  final double totalPhosphorus;
  final double totalPotassium;
  
  const CropRequirementsData({
    required this.cropType,
    required this.yieldTarget,
    required this.nitrogenPerTon,
    required this.phosphorusPerTon,
    required this.potassiumPerTon,
    required this.totalNitrogen,
    required this.totalPhosphorus,
    required this.totalPotassium,
  });
}

/// Dados relacionados à textura do solo
class SoilTextureData {
  final String textureClass;
  final double retentionFactor;
  final double nitrogenEfficiency;
  final double phosphorusEfficiency;
  final double potassiumEfficiency;
  final double infiltrationRate;
  final double organicMatterFactor;
  
  const SoilTextureData({
    required this.textureClass,
    required this.retentionFactor,
    required this.nitrogenEfficiency,
    required this.phosphorusEfficiency,
    required this.potassiumEfficiency,
    required this.infiltrationRate,
    required this.organicMatterFactor,
  });
}

/// Produto fertilizante
class FertilizerProduct {
  final String name;
  final Map<String, double> nutrientContent;
  final String unit;
  final double pricePerKg;
  final List<String> applicationMethods;
  final String notes;
  
  const FertilizerProduct({
    required this.name,
    required this.nutrientContent,
    required this.unit,
    required this.pricePerKg,
    required this.applicationMethods,
    required this.notes,
  });
}

/// Cronograma de aplicação
class ApplicationSchedule {
  final String period;
  final double nitrogenPercentage;
  final double phosphorusPercentage;
  final double potassiumPercentage;
  final String instructions;
  
  const ApplicationSchedule({
    required this.period,
    required this.nitrogenPercentage,
    required this.phosphorusPercentage,
    required this.potassiumPercentage,
    required this.instructions,
  });
}

/// Efeito da cultura anterior
class PreviousCropEffect {
  final String cropType;
  final double nitrogenContribution;
  final double organicMatterContribution;
  final String description;
  
  const PreviousCropEffect({
    required this.cropType,
    required this.nitrogenContribution,
    required this.organicMatterContribution,
    required this.description,
  });
}

/// Ranges de validação para parâmetros
class ValidationRanges {
  final double minValue;
  final double maxValue;
  final double optimalMin;
  final double optimalMax;
  final String unit;
  
  const ValidationRanges({
    required this.minValue,
    required this.maxValue,
    required this.optimalMin,
    required this.optimalMax,
    required this.unit,
  });
}