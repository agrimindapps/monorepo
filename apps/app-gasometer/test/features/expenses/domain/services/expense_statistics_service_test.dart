import 'package:flutter_test/flutter_test.dart';
import '../../../../../lib/features/expenses/domain/entities/expense_entity.dart';
import '../../../../../lib/features/expenses/domain/services/expense_statistics_service.dart';
import '../../../../../lib/features/vehicles/domain/entities/vehicle_entity.dart';

void main() {
  group('ExpenseStatisticsService', () {
    late ExpenseStatisticsService service;
    late List<ExpenseEntity> testExpenses;

    setUp(() {
      service = ExpenseStatisticsService();
      testExpenses = [
        ExpenseEntity(
          id: '1',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          description: 'Abastecimento',
          amount: 150.0,
          date: DateTime(2024, 1, 15),
          odometer: 50000,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          metadata: const {},
        ),
        ExpenseEntity(
          id: '2',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.maintenance,
          description: 'Troca de óleo',
          amount: 200.0,
          date: DateTime(2024, 2, 15),
          odometer: 52000,
          createdAt: DateTime(2024, 2, 15),
          updatedAt: DateTime(2024, 2, 15),
          metadata: const {},
        ),
        ExpenseEntity(
          id: '3',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          description: 'Abastecimento',
          amount: 180.0,
          date: DateTime(2024, 3, 15),
          odometer: 54000,
          createdAt: DateTime(2024, 3, 15),
          updatedAt: DateTime(2024, 3, 15),
          metadata: const {},
        ),
      ];
    });

    test('deve calcular estatísticas básicas corretamente', () {
      final stats = service.calculateStats(testExpenses);

      expect(stats['totalRecords'], equals(3));
      expect(stats['totalAmount'], equals(530.0));
      expect(stats['averageAmount'], equals(530.0 / 3));
      expect(stats['highestExpense'], equals(200.0));
      expect(stats['lowestExpense'], equals(150.0));
    });

    test('deve retornar estatísticas vazias para lista vazia', () {
      final stats = service.calculateStats([]);

      expect(stats['totalRecords'], equals(0));
      expect(stats['totalAmount'], equals(0.0));
      expect(stats['averageAmount'], equals(0.0));
    });

    test('deve agrupar por tipo corretamente', () {
      final stats = service.calculateStats(testExpenses);

      final byType = stats['byType'] as Map<String, double>;
      final countByType = stats['countByType'] as Map<String, int>;

      expect(byType['Combustível'], equals(330.0)); // 150 + 180
      expect(byType['Manutenção'], equals(200.0));
      expect(countByType['Combustível'], equals(2));
      expect(countByType['Manutenção'], equals(1));
    });

    test('deve identificar tipo mais caro', () {
      final stats = service.calculateStats(testExpenses);

      expect(stats['mostExpensiveType'], equals('Combustível'));
      expect(stats['mostExpensiveTypeAmount'], equals(330.0));
    });

    test('deve calcular estatísticas por período', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 2, 28);
      
      final stats = service.calculateStatsByPeriod(testExpenses, start, end);

      expect(stats['totalRecords'], equals(2)); // Janeiro e Fevereiro
      expect(stats['totalAmount'], equals(350.0)); // 150 + 200
      expect(stats['days'], equals(59)); // 31 + 28 + 1
    });

    test('deve calcular estatísticas de crescimento', () {
      final stats = service.calculateGrowthStats(testExpenses);

      expect(stats['hasGrowthData'], isTrue);
      expect(stats['trend'], isA<String>());
      expect(stats['growthPercentage'], isA<double>());
    });

    test('deve detectar anomalias', () {
      // Adicionar uma despesa muito alta para teste de anomalia
      final expensesWithAnomaly = [
        ...testExpenses,
        ExpenseEntity(
          id: '4',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.maintenance,
          description: 'Reparo caro',
          amount: 5000.0, // Valor anômalo
          date: DateTime(2024, 4, 15),
          odometer: 56000,
          createdAt: DateTime(2024, 4, 15),
          updatedAt: DateTime(2024, 4, 15),
          metadata: const {},
        ),
      ];

      final stats = service.calculateAnomalies(expensesWithAnomaly);

      expect(stats['hasAnomalies'], isTrue);
      expect(stats['anomalousExpenses'], isA<List<ExpenseEntity>>());
      expect(stats['anomaliesCount'], equals(1));
      expect(stats['thresholdAmount'], isA<double>());
    });

    test('deve calcular estatísticas por veículo', () {
      final vehicle = VehicleEntity(
        id: 'vehicle1',
        userId: 'user1',
        name: 'Teste Car',
        brand: 'TestBrand',
        model: 'TestModel',
        year: 2020,
        color: 'Branco',
        licensePlate: 'ABC-1234',
        type: VehicleType.car,
        supportedFuels: [FuelType.gasoline],
        currentOdometer: 55000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const {},
      );

      final stats = service.calculateVehicleStats(testExpenses, vehicle);

      expect(stats['vehicle'], equals(vehicle));
      expect(stats['vehicleName'], equals('Teste Car'));
      expect(stats['currentOdometer'], equals(55000.0));
      expect(stats['costPerKm'], isA<double>());
      expect(stats['totalAmount'], equals(530.0));
    });

    test('deve comparar períodos', () {
      final period1Start = DateTime(2024, 1, 1);
      final period1End = DateTime(2024, 1, 31);
      final period2Start = DateTime(2024, 2, 1);
      final period2End = DateTime(2024, 2, 29);

      final comparison = service.comparePeriods(
        testExpenses,
        period1Start,
        period1End,
        period2Start,
        period2End,
      );

      expect(comparison['period1'], isA<Map<String, dynamic>>());
      expect(comparison['period2'], isA<Map<String, dynamic>>());
      expect(comparison['difference'], isA<double>());
      expect(comparison['percentageChange'], isA<double>());
      expect(comparison['isIncrease'], isA<bool>());
      expect(comparison['isDecrease'], isA<bool>());
      expect(comparison['isStable'], isA<bool>());
    });

    test('deve calcular média mensal corretamente', () {
      // Teste com despesas espalhadas em 3 meses
      final stats = service.calculateStats(testExpenses);
      
      // Devemos ter 3 meses de dados (Janeiro, Fevereiro, Março)
      expect(stats['monthlyAmount'], equals(530.0 / 3)); // Total / meses
    });

    test('deve formatar valores monetários', () {
      final stats = service.calculateStats(testExpenses);

      expect(stats['totalAmountFormatted'], isA<String>());
      expect(stats['averageAmountFormatted'], isA<String>());
      expect(stats['monthlyAmountFormatted'], isA<String>());
      expect(stats['byTypeFormatted'], isA<Map<String, String>>());
    });

    test('deve lidar com lista com apenas um item', () {
      final singleExpense = [testExpenses.first];
      final stats = service.calculateStats(singleExpense);

      expect(stats['totalRecords'], equals(1));
      expect(stats['totalAmount'], equals(150.0));
      expect(stats['averageAmount'], equals(150.0));
      expect(stats['monthlyAmount'], equals(0.0)); // Não pode calcular tendência
    });
  });
}