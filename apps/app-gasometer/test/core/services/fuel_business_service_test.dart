import 'package:flutter_test/flutter_test.dart';

import 'package:gasometer_drift/features/fuel/data/models/fuel_supply_model.dart';
import 'package:gasometer_drift/features/fuel/domain/services/fuel_business_service.dart';

void main() {
  group('FuelBusinessService - Financial Calculations', () {
    late FuelSupplyModel testFuelSupply;

    setUp(() {
      testFuelSupply = FuelSupplyModel(
        id: 'fuel-001',
        vehicleId: 'vehicle-001',
        fuelType: 0, // Gasoline
        liters: 40.0,
        totalPrice: 220.0,
        odometer: 10500.0,
        date: DateTime(2024, 1, 15).millisecondsSinceEpoch,
        fullTank: true,
        userId: 'user-001',
        isDirty: false,
        isDeleted: false,
        createdAtMs: DateTime(2024, 1, 15).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 15).millisecondsSinceEpoch,
        moduleName: 'gasometer',
      );
    });

    group('calculateConsumption', () {
      test('should calculate consumption correctly in km/L', () {
        // Arrange
        const previousOdometer = 10000.0;
        // Distance: 500 km, Liters: 40L
        // Expected: 500 / 40 = 12.5 km/L

        // Act
        final result = FuelBusinessService.calculateConsumption(
          testFuelSupply,
          previousOdometer,
        );

        // Assert
        expect(result, 12.5);
      });

      test('should return 0 when liters is 0', () {
        // Arrange
        final supply = testFuelSupply.copyWith(liters: 0.0);

        // Act
        final result = FuelBusinessService.calculateConsumption(
          supply,
          10000.0,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when liters is negative', () {
        // Arrange
        final supply = testFuelSupply.copyWith(liters: -10.0);

        // Act
        final result = FuelBusinessService.calculateConsumption(
          supply,
          10000.0,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when distance traveled is 0', () {
        // Arrange - same odometer
        final result = FuelBusinessService.calculateConsumption(
          testFuelSupply,
          10500.0,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when distance traveled is negative', () {
        // Arrange - previous odometer higher than current
        final result = FuelBusinessService.calculateConsumption(
          testFuelSupply,
          11000.0,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should handle decimal values correctly', () {
        // Arrange
        final supply = testFuelSupply.copyWith(odometer: 10543.7, liters: 38.5);
        const previousOdometer = 10000.0;
        // Distance: 543.7 km, Liters: 38.5L
        // Expected: 543.7 / 38.5 = 14.122...

        // Act
        final result = FuelBusinessService.calculateConsumption(
          supply,
          previousOdometer,
        );

        // Assert
        expect(result, closeTo(14.122, 0.001));
      });
    });

    group('calculateConsumptionL100km', () {
      test('should calculate L/100km correctly', () {
        // Arrange
        // 12.5 km/L = 100 / 12.5 = 8.0 L/100km
        const previousOdometer = 10000.0;

        // Act
        final result = FuelBusinessService.calculateConsumptionL100km(
          testFuelSupply,
          previousOdometer,
        );

        // Assert
        expect(result, 8.0);
      });

      test('should return 0 when consumption is 0', () {
        // Arrange
        final supply = testFuelSupply.copyWith(liters: 0.0);

        // Act
        final result = FuelBusinessService.calculateConsumptionL100km(
          supply,
          10000.0,
        );

        // Assert
        expect(result, 0.0);
      });
    });

    group('calculatePricePerLiter', () {
      test('should calculate price per liter correctly', () {
        // Arrange - 220.0 / 40.0 = 5.50

        // Act
        final result = FuelBusinessService.calculatePricePerLiter(
          testFuelSupply,
        );

        // Assert
        expect(result, 5.50);
      });

      test('should return 0 when liters is 0', () {
        // Arrange
        final supply = testFuelSupply.copyWith(liters: 0.0);

        // Act
        final result = FuelBusinessService.calculatePricePerLiter(supply);

        // Assert
        expect(result, 0.0);
      });

      test('should handle decimal precision correctly', () {
        // Arrange
        final supply = testFuelSupply.copyWith(
          totalPrice: 233.47,
          liters: 41.3,
        );
        // Expected: 233.47 / 41.3 = 5.653...

        // Act
        final result = FuelBusinessService.calculatePricePerLiter(supply);

        // Assert
        expect(result, closeTo(5.653, 0.001));
      });
    });

    group('calculateTotalValue', () {
      test('should calculate total value correctly', () {
        // Act
        final result = FuelBusinessService.calculateTotalValue(5.50, 40.0);

        // Assert
        expect(result, 220.0);
      });

      test('should handle zero values', () {
        // Act
        final result1 = FuelBusinessService.calculateTotalValue(0.0, 40.0);
        final result2 = FuelBusinessService.calculateTotalValue(5.50, 0.0);

        // Assert
        expect(result1, 0.0);
        expect(result2, 0.0);
      });

      test('should handle decimal values correctly', () {
        // Act
        final result = FuelBusinessService.calculateTotalValue(5.789, 38.5);

        // Assert
        expect(result, closeTo(222.876, 0.001));
      });
    });

    group('calculateAverageConsumption', () {
      test('should calculate average consumption from multiple supplies', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(odometer: 10500.0, liters: 40.0), // 12.5 km/L
          testFuelSupply.copyWith(odometer: 11100.0, liters: 50.0), // 12.0 km/L
          testFuelSupply.copyWith(odometer: 11750.0, liters: 50.0), // 13.0 km/L
        ];
        final previousOdometers = [10000.0, 10500.0, 11100.0];
        // Average: (12.5 + 12.0 + 13.0) / 3 = 12.5 km/L

        // Act
        final result = FuelBusinessService.calculateAverageConsumption(
          supplies,
          previousOdometers,
        );

        // Assert
        expect(result, closeTo(12.5, 0.001));
      });

      test('should return 0 when supplies list is empty', () {
        // Act
        final result = FuelBusinessService.calculateAverageConsumption([], []);

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when lists have different lengths', () {
        // Arrange
        final supplies = [testFuelSupply];
        final previousOdometers = [10000.0, 10500.0];

        // Act
        final result = FuelBusinessService.calculateAverageConsumption(
          supplies,
          previousOdometers,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should ignore invalid consumptions (zero or negative)', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(
            odometer: 10500.0,
            liters: 40.0,
          ), // Valid: 12.5
          testFuelSupply.copyWith(odometer: 10500.0, liters: 0.0), // Invalid: 0
          testFuelSupply.copyWith(
            odometer: 11100.0,
            liters: 50.0,
          ), // Valid: 12.0
        ];
        final previousOdometers = [10000.0, 10500.0, 10500.0];
        // Average: (12.5 + 12.0) / 2 = 12.25 km/L

        // Act
        final result = FuelBusinessService.calculateAverageConsumption(
          supplies,
          previousOdometers,
        );

        // Assert
        expect(result, closeTo(12.25, 0.001));
      });

      test('should return 0 when all consumptions are invalid', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(odometer: 10000.0, liters: 40.0),
          testFuelSupply.copyWith(odometer: 10500.0, liters: 0.0),
        ];
        final previousOdometers = [10000.0, 10500.0];

        // Act
        final result = FuelBusinessService.calculateAverageConsumption(
          supplies,
          previousOdometers,
        );

        // Assert
        expect(result, 0.0);
      });
    });

    group('calculateTotalFuelCost', () {
      test('should calculate total cost from multiple supplies', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(totalPrice: 220.0),
          testFuelSupply.copyWith(totalPrice: 275.0),
          testFuelSupply.copyWith(totalPrice: 198.50),
        ];
        // Expected: 220.0 + 275.0 + 198.50 = 693.50

        // Act
        final result = FuelBusinessService.calculateTotalFuelCost(supplies);

        // Assert
        expect(result, 693.50);
      });

      test('should return 0 for empty list', () {
        // Act
        final result = FuelBusinessService.calculateTotalFuelCost([]);

        // Assert
        expect(result, 0.0);
      });

      test('should handle single supply', () {
        // Act
        final result = FuelBusinessService.calculateTotalFuelCost([
          testFuelSupply,
        ]);

        // Assert
        expect(result, 220.0);
      });
    });

    group('calculateTotalLiters', () {
      test('should calculate total liters from multiple supplies', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(liters: 40.0),
          testFuelSupply.copyWith(liters: 50.0),
          testFuelSupply.copyWith(liters: 35.5),
        ];
        // Expected: 40.0 + 50.0 + 35.5 = 125.5

        // Act
        final result = FuelBusinessService.calculateTotalLiters(supplies);

        // Assert
        expect(result, 125.5);
      });

      test('should return 0 for empty list', () {
        // Act
        final result = FuelBusinessService.calculateTotalLiters([]);

        // Assert
        expect(result, 0.0);
      });
    });

    group('calculateAveragePricePerLiter', () {
      test('should calculate average price per liter correctly', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(totalPrice: 220.0, liters: 40.0), // 5.50
          testFuelSupply.copyWith(totalPrice: 275.0, liters: 50.0), // 5.50
          testFuelSupply.copyWith(totalPrice: 214.5, liters: 39.0), // 5.50
        ];
        // Total: 709.5, Total liters: 129.0
        // Average: 709.5 / 129.0 = 5.50

        // Act
        final result = FuelBusinessService.calculateAveragePricePerLiter(
          supplies,
        );

        // Assert
        expect(result, closeTo(5.50, 0.001));
      });

      test('should return 0 for empty list', () {
        // Act
        final result = FuelBusinessService.calculateAveragePricePerLiter([]);

        // Assert
        expect(result, 0.0);
      });

      test('should return 0 when total liters is 0', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(totalPrice: 220.0, liters: 0.0),
        ];

        // Act
        final result = FuelBusinessService.calculateAveragePricePerLiter(
          supplies,
        );

        // Assert
        expect(result, 0.0);
      });

      test('should handle varying prices correctly', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(totalPrice: 220.0, liters: 40.0), // 5.50
          testFuelSupply.copyWith(totalPrice: 300.0, liters: 50.0), // 6.00
          testFuelSupply.copyWith(totalPrice: 195.0, liters: 30.0), // 6.50
        ];
        // Total: 715.0, Total liters: 120.0
        // Average: 715.0 / 120.0 = 5.958...

        // Act
        final result = FuelBusinessService.calculateAveragePricePerLiter(
          supplies,
        );

        // Assert
        expect(result, closeTo(5.958, 0.001));
      });
    });

    group('filterByVehicle', () {
      test('should filter supplies by vehicle ID', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(vehicleId: 'vehicle-001'),
          testFuelSupply.copyWith(vehicleId: 'vehicle-002'),
          testFuelSupply.copyWith(vehicleId: 'vehicle-001'),
          testFuelSupply.copyWith(vehicleId: 'vehicle-003'),
        ];

        // Act
        final result = FuelBusinessService.filterByVehicle(
          supplies,
          'vehicle-001',
        );

        // Assert
        expect(result.length, 2);
        expect(result.every((s) => s.vehicleId == 'vehicle-001'), true);
      });

      test('should return empty list when no matches', () {
        // Arrange
        final supplies = [testFuelSupply.copyWith(vehicleId: 'vehicle-001')];

        // Act
        final result = FuelBusinessService.filterByVehicle(
          supplies,
          'vehicle-999',
        );

        // Assert
        expect(result.isEmpty, true);
      });

      test('should return empty list for empty input', () {
        // Act
        final result = FuelBusinessService.filterByVehicle([], 'vehicle-001');

        // Assert
        expect(result.isEmpty, true);
      });
    });

    group('filterByDateRange', () {
      test('should filter supplies within date range', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 10).millisecondsSinceEpoch,
          ),
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 15).millisecondsSinceEpoch,
          ),
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 20).millisecondsSinceEpoch,
          ),
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 25).millisecondsSinceEpoch,
          ),
        ];

        // Act
        final result = FuelBusinessService.filterByDateRange(
          supplies,
          DateTime(2024, 1, 12),
          DateTime(2024, 1, 22),
        );

        // Assert
        expect(result.length, 2);
        final dates = result
            .map((s) => DateTime.fromMillisecondsSinceEpoch(s.date))
            .toList();
        expect(dates.any((d) => d.day == 15), true);
        expect(dates.any((d) => d.day == 20), true);
      });

      test('should return empty list when no supplies in range', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 10).millisecondsSinceEpoch,
          ),
        ];

        // Act
        final result = FuelBusinessService.filterByDateRange(
          supplies,
          DateTime(2024, 2, 1),
          DateTime(2024, 2, 28),
        );

        // Assert
        expect(result.isEmpty, true);
      });

      test('should include boundary dates', () {
        // Arrange
        final supplies = [
          testFuelSupply.copyWith(
            date: DateTime(2024, 1, 15).millisecondsSinceEpoch,
          ),
        ];

        // Act
        final result = FuelBusinessService.filterByDateRange(
          supplies,
          DateTime(2024, 1, 15),
          DateTime(2024, 1, 15),
        );

        // Assert
        expect(result.length, 1);
      });
    });
  });
}
