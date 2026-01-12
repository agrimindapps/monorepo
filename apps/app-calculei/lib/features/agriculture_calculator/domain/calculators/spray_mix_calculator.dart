/// Calculadora de Calda de Pulverização
/// Calcula volume de calda, produtos e número de tanques para aplicação agrícola
library;

import 'package:equatable/equatable.dart';

/// Unidade de medida do produto
enum ProductUnit {
  mL, // Mililitros (líquido)
  g, // Gramas (sólido)
  kg, // Quilogramas (sólido)
  L, // Litros (líquido)
}

/// Informações de um produto a ser aplicado
class SprayProduct extends Equatable {
  /// Nome comercial do produto
  final String name;

  /// Dose do produto por hectare
  final double dosePerHa;

  /// Unidade de medida da dose
  final ProductUnit unit;

  const SprayProduct({
    required this.name,
    required this.dosePerHa,
    required this.unit,
  });

  @override
  List<Object?> get props => [name, dosePerHa, unit];

  SprayProduct copyWith({
    String? name,
    double? dosePerHa,
    ProductUnit? unit,
  }) {
    return SprayProduct(
      name: name ?? this.name,
      dosePerHa: dosePerHa ?? this.dosePerHa,
      unit: unit ?? this.unit,
    );
  }
}

/// Informação de produto calculado para o tanque
class ProductPerTank extends Equatable {
  /// Nome do produto
  final String productName;

  /// Quantidade por tanque
  final double quantityPerTank;

  /// Unidade de medida
  final ProductUnit unit;

  const ProductPerTank({
    required this.productName,
    required this.quantityPerTank,
    required this.unit,
  });

  @override
  List<Object?> get props => [productName, quantityPerTank, unit];
}

/// Resultado do cálculo de calda de pulverização
class SprayMixCalculation extends Equatable {
  /// Área a ser pulverizada (ha)
  final double areaToSpray;

  /// Taxa de aplicação (volume de calda) em L/ha
  final double applicationRate;

  /// Capacidade do tanque em litros
  final double tankCapacity;

  /// Lista de produtos a aplicar
  final List<SprayProduct> products;

  /// Volume total de calda necessário (litros)
  final double totalSprayVolume;

  /// Número de tanques necessários
  final int numberOfTanks;

  /// Volume de água por tanque (litros)
  final double waterPerTank;

  /// Produtos calculados por tanque
  final List<ProductPerTank> productsPerTank;

  /// Volume total de água necessário (litros)
  final double totalWater;

  /// Dicas de aplicação
  final List<String> applicationTips;

  const SprayMixCalculation({
    required this.areaToSpray,
    required this.applicationRate,
    required this.tankCapacity,
    required this.products,
    required this.totalSprayVolume,
    required this.numberOfTanks,
    required this.waterPerTank,
    required this.productsPerTank,
    required this.totalWater,
    required this.applicationTips,
  });

  factory SprayMixCalculation.empty() => const SprayMixCalculation(
        areaToSpray: 0,
        applicationRate: 0,
        tankCapacity: 0,
        products: [],
        totalSprayVolume: 0,
        numberOfTanks: 0,
        waterPerTank: 0,
        productsPerTank: [],
        totalWater: 0,
        applicationTips: [],
      );

  @override
  List<Object?> get props => [
        areaToSpray,
        applicationRate,
        tankCapacity,
        products,
        totalSprayVolume,
        numberOfTanks,
        waterPerTank,
        productsPerTank,
        totalWater,
        applicationTips,
      ];

  SprayMixCalculation copyWith({
    double? areaToSpray,
    double? applicationRate,
    double? tankCapacity,
    List<SprayProduct>? products,
    double? totalSprayVolume,
    int? numberOfTanks,
    double? waterPerTank,
    List<ProductPerTank>? productsPerTank,
    double? totalWater,
    List<String>? applicationTips,
  }) {
    return SprayMixCalculation(
      areaToSpray: areaToSpray ?? this.areaToSpray,
      applicationRate: applicationRate ?? this.applicationRate,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      products: products ?? this.products,
      totalSprayVolume: totalSprayVolume ?? this.totalSprayVolume,
      numberOfTanks: numberOfTanks ?? this.numberOfTanks,
      waterPerTank: waterPerTank ?? this.waterPerTank,
      productsPerTank: productsPerTank ?? this.productsPerTank,
      totalWater: totalWater ?? this.totalWater,
      applicationTips: applicationTips ?? this.applicationTips,
    );
  }
}

/// Calculadora de calda de pulverização
class SprayMixCalculator {
  /// Calcula a calda de pulverização
  static SprayMixCalculation calculate({
    required double areaHa,
    required double applicationRateLHa,
    required double tankCapacityL,
    required List<SprayProduct> products,
  }) {
    // 1. Volume total de calda = área × taxa de aplicação
    final totalSprayVolume = areaHa * applicationRateLHa;

    // 2. Número de tanques = volume total ÷ capacidade do tanque (arredonda para cima)
    final numberOfTanks = (totalSprayVolume / tankCapacityL).ceil();

    // 3. Volume de água por tanque (considerando volume total dos produtos)
    // Primeiro calculamos volume total dos produtos por tanque
    double totalProductVolumePerTank = 0;
    final productsPerTank = <ProductPerTank>[];

    for (final product in products) {
      // Quantidade do produto por tanque = (dose/ha) × (capacidade tanque ÷ volume calda/ha)
      final quantityPerTank = product.dosePerHa * (tankCapacityL / applicationRateLHa);

      productsPerTank.add(
        ProductPerTank(
          productName: product.name,
          quantityPerTank: double.parse(quantityPerTank.toStringAsFixed(2)),
          unit: product.unit,
        ),
      );

      // Converte para litros se necessário para calcular volume
      if (product.unit == ProductUnit.L) {
        totalProductVolumePerTank += quantityPerTank;
      } else if (product.unit == ProductUnit.mL) {
        totalProductVolumePerTank += quantityPerTank / 1000;
      }
      // Sólidos (g, kg) não afetam significativamente o volume
    }

    // Água por tanque = capacidade tanque - volume produtos líquidos
    final waterPerTank = tankCapacityL - totalProductVolumePerTank;

    // Volume total de água
    final totalWater = waterPerTank * numberOfTanks;

    // Dicas de aplicação
    final applicationTips = _getApplicationTips(
      applicationRateLHa,
      tankCapacityL,
      numberOfTanks,
      products.length,
    );

    return SprayMixCalculation(
      areaToSpray: double.parse(areaHa.toStringAsFixed(2)),
      applicationRate: double.parse(applicationRateLHa.toStringAsFixed(1)),
      tankCapacity: double.parse(tankCapacityL.toStringAsFixed(1)),
      products: products,
      totalSprayVolume: double.parse(totalSprayVolume.toStringAsFixed(1)),
      numberOfTanks: numberOfTanks,
      waterPerTank: double.parse(waterPerTank.toStringAsFixed(1)),
      productsPerTank: productsPerTank,
      totalWater: double.parse(totalWater.toStringAsFixed(1)),
      applicationTips: applicationTips,
    );
  }

  static List<String> _getApplicationTips(
    double applicationRate,
    double tankCapacity,
    int numberOfTanks,
    int numberOfProducts,
  ) {
    final tips = <String>[];

    // Dicas por volume de aplicação
    if (applicationRate < 100) {
      tips.add('Volume baixo: Ideal para herbicidas pós-emergentes');
      tips.add('Use pontas de pulverização adequadas para baixo volume');
    } else if (applicationRate >= 100 && applicationRate <= 200) {
      tips.add('Volume médio: Uso geral para maioria dos defensivos');
    } else {
      tips.add('Volume alto: Melhor cobertura, indicado para fungicidas/inseticidas');
    }

    // Dicas de preparo da calda
    if (numberOfProducts > 1) {
      tips.add('Ordem de mistura: Pós molháveis → Suspensões → Emulsões → Solúveis');
      tips.add('Aguarde dissolução completa entre cada produto');
    }

    // Dicas gerais
    tips.add('Complete água até 3/4 do tanque antes de adicionar produtos');
    tips.add('Mantenha agitação constante durante aplicação');
    tips.add('Aplique em horários de menor temperatura (antes 10h ou após 16h)');
    
    if (tankCapacity >= 2000) {
      tips.add('Tanque grande: Verifique calibração de bomba e bicos regularmente');
    }

    if (numberOfTanks > 10) {
      tips.add('Muitos tanques: Considere aumentar volume de aplicação se possível');
    }

    tips.add('Use água limpa e de boa qualidade');
    tips.add('Descarte adequado de sobras conforme legislação');

    return tips;
  }

  static String getUnitLabel(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.mL:
        return 'mL';
      case ProductUnit.g:
        return 'g';
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.L:
        return 'L';
    }
  }

  static String getUnitName(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.mL:
        return 'Mililitros';
      case ProductUnit.g:
        return 'Gramas';
      case ProductUnit.kg:
        return 'Quilogramas';
      case ProductUnit.L:
        return 'Litros';
    }
  }
}
