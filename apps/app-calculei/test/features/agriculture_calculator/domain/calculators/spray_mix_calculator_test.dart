import 'package:flutter_test/flutter_test.dart';
import 'package:app_calculei/features/agriculture_calculator/domain/calculators/spray_mix_calculator.dart';

void main() {
  group('SprayMixCalculator', () {
    test('should calculate spray mix correctly for basic scenario', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 200.0;
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Herbicida',
          dosePerHa: 2000.0,
          unit: ProductUnit.mL,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.areaToSpray, 10.0);
      expect(result.applicationRate, 200.0);
      expect(result.tankCapacity, 2000.0);
      expect(result.totalSprayVolume, 2000.0); // 10 ha × 200 L/ha
      expect(result.numberOfTanks, 1); // 2000 L ÷ 2000 L
      expect(result.productsPerTank.length, 1);
      expect(result.productsPerTank.first.productName, 'Herbicida');
      expect(result.productsPerTank.first.quantityPerTank, 20000.0); // 2000 mL/ha × (2000 L ÷ 200 L/ha)
      expect(result.waterPerTank, 1980.0); // 2000 L - 20 L (20000 mL converted)
    });

    test('should calculate multiple tanks correctly', () {
      // Arrange
      const areaHa = 25.0;
      const applicationRateLHa = 200.0;
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Herbicida',
          dosePerHa: 2000.0,
          unit: ProductUnit.mL,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.totalSprayVolume, 5000.0); // 25 ha × 200 L/ha
      expect(result.numberOfTanks, 3); // ceil(5000 L ÷ 2000 L) = 3 tanks
      expect(result.productsPerTank.first.quantityPerTank, 20000.0);
      expect(result.totalWater, 5940.0); // 1980 L/tank × 3 tanks
    });

    test('should handle multiple products correctly', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 200.0;
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Herbicida',
          dosePerHa: 2000.0,
          unit: ProductUnit.mL,
        ),
        const SprayProduct(
          name: 'Adjuvante',
          dosePerHa: 500.0,
          unit: ProductUnit.mL,
        ),
        const SprayProduct(
          name: 'Fertilizante Foliar',
          dosePerHa: 1.0,
          unit: ProductUnit.kg,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.productsPerTank.length, 3);
      expect(result.productsPerTank[0].productName, 'Herbicida');
      expect(result.productsPerTank[0].quantityPerTank, 20000.0); // 2000 mL/ha × 10
      expect(result.productsPerTank[1].productName, 'Adjuvante');
      expect(result.productsPerTank[1].quantityPerTank, 5000.0); // 500 mL/ha × 10
      expect(result.productsPerTank[2].productName, 'Fertilizante Foliar');
      expect(result.productsPerTank[2].quantityPerTank, 10.0); // 1 kg/ha × 10
      expect(result.productsPerTank[2].unit, ProductUnit.kg);

      // Water per tank = 2000 - (20 L + 5 L) = 1975 L (kg doesn't affect volume)
      expect(result.waterPerTank, 1975.0);
    });

    test('should handle low application rate', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 80.0; // Low volume
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Herbicida',
          dosePerHa: 1000.0,
          unit: ProductUnit.mL,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.totalSprayVolume, 800.0); // 10 ha × 80 L/ha
      expect(result.numberOfTanks, 1); // ceil(800 L ÷ 2000 L)
      expect(result.applicationTips.isNotEmpty, true);
      expect(
        result.applicationTips.any((tip) => tip.contains('Volume baixo')),
        true,
      );
    });

    test('should handle high application rate', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 400.0; // High volume
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Fungicida',
          dosePerHa: 1500.0,
          unit: ProductUnit.mL,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.totalSprayVolume, 4000.0); // 10 ha × 400 L/ha
      expect(result.numberOfTanks, 2); // ceil(4000 L ÷ 2000 L)
      expect(
        result.applicationTips.any((tip) => tip.contains('Volume alto')),
        true,
      );
    });

    test('should provide mixing order tips for multiple products', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 200.0;
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Herbicida',
          dosePerHa: 2000.0,
          unit: ProductUnit.mL,
        ),
        const SprayProduct(
          name: 'Adjuvante',
          dosePerHa: 500.0,
          unit: ProductUnit.mL,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(
        result.applicationTips.any((tip) => tip.contains('Ordem de mistura')),
        true,
      );
    });

    test('should calculate correctly with liters as product unit', () {
      // Arrange
      const areaHa = 10.0;
      const applicationRateLHa = 200.0;
      const tankCapacityL = 2000.0;
      final products = [
        const SprayProduct(
          name: 'Fertilizante Líquido',
          dosePerHa: 5.0,
          unit: ProductUnit.L,
        ),
      ];

      // Act
      final result = SprayMixCalculator.calculate(
        areaHa: areaHa,
        applicationRateLHa: applicationRateLHa,
        tankCapacityL: tankCapacityL,
        products: products,
      );

      // Assert
      expect(result.productsPerTank.first.quantityPerTank, 50.0); // 5 L/ha × 10
      expect(result.waterPerTank, 1950.0); // 2000 L - 50 L
    });

    test('should return proper unit labels', () {
      expect(SprayMixCalculator.getUnitLabel(ProductUnit.mL), 'mL');
      expect(SprayMixCalculator.getUnitLabel(ProductUnit.g), 'g');
      expect(SprayMixCalculator.getUnitLabel(ProductUnit.kg), 'kg');
      expect(SprayMixCalculator.getUnitLabel(ProductUnit.L), 'L');
    });

    test('should return proper unit names', () {
      expect(SprayMixCalculator.getUnitName(ProductUnit.mL), 'Mililitros');
      expect(SprayMixCalculator.getUnitName(ProductUnit.g), 'Gramas');
      expect(SprayMixCalculator.getUnitName(ProductUnit.kg), 'Quilogramas');
      expect(SprayMixCalculator.getUnitName(ProductUnit.L), 'Litros');
    });
  });

  group('SprayMixCalculation', () {
    test('should support copyWith', () {
      // Arrange
      const original = SprayMixCalculation(
        areaToSpray: 10.0,
        applicationRate: 200.0,
        tankCapacity: 2000.0,
        products: [],
        totalSprayVolume: 2000.0,
        numberOfTanks: 1,
        waterPerTank: 2000.0,
        productsPerTank: [],
        totalWater: 2000.0,
        applicationTips: [],
      );

      // Act
      final modified = original.copyWith(
        areaToSpray: 20.0,
        numberOfTanks: 2,
      );

      // Assert
      expect(modified.areaToSpray, 20.0);
      expect(modified.applicationRate, 200.0); // Unchanged
      expect(modified.numberOfTanks, 2);
      expect(modified.tankCapacity, 2000.0); // Unchanged
    });

    test('should create empty calculation', () {
      // Act
      final empty = SprayMixCalculation.empty();

      // Assert
      expect(empty.areaToSpray, 0);
      expect(empty.applicationRate, 0);
      expect(empty.totalSprayVolume, 0);
      expect(empty.numberOfTanks, 0);
      expect(empty.products, isEmpty);
      expect(empty.productsPerTank, isEmpty);
    });
  });

  group('SprayProduct', () {
    test('should support copyWith', () {
      // Arrange
      const original = SprayProduct(
        name: 'Test',
        dosePerHa: 1000.0,
        unit: ProductUnit.mL,
      );

      // Act
      final modified = original.copyWith(
        dosePerHa: 2000.0,
        unit: ProductUnit.L,
      );

      // Assert
      expect(modified.name, 'Test'); // Unchanged
      expect(modified.dosePerHa, 2000.0);
      expect(modified.unit, ProductUnit.L);
    });

    test('should support equality', () {
      // Arrange
      const product1 = SprayProduct(
        name: 'Test',
        dosePerHa: 1000.0,
        unit: ProductUnit.mL,
      );
      const product2 = SprayProduct(
        name: 'Test',
        dosePerHa: 1000.0,
        unit: ProductUnit.mL,
      );
      const product3 = SprayProduct(
        name: 'Other',
        dosePerHa: 1000.0,
        unit: ProductUnit.mL,
      );

      // Assert
      expect(product1, equals(product2));
      expect(product1, isNot(equals(product3)));
    });
  });
}
