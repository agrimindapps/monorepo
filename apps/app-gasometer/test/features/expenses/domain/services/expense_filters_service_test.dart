import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/features/expenses/domain/entities/expense_entity.dart';
import 'package:gasometer/features/expenses/domain/services/expense_filters_service.dart';

void main() {
  group('ExpenseFiltersService', () {
    late ExpenseFiltersService service;
    late List<ExpenseEntity> testExpenses;

    setUp(() {
      service = ExpenseFiltersService();
      testExpenses = [
        ExpenseEntity(
          id: '1',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          description: 'Abastecimento completo',
          amount: 150.0,
          date: DateTime(2024, 1, 15),
          odometer: 50000,
          location: 'Posto Shell',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          metadata: const {},
        ),
        ExpenseEntity(
          id: '2',
          userId: 'user1',
          vehicleId: 'vehicle2',
          type: ExpenseType.maintenance,
          description: 'Manutenção preventiva',
          amount: 200.0,
          date: DateTime(2024, 2, 15),
          odometer: 52000,
          location: 'Oficina do João',
          createdAt: DateTime(2024, 2, 15),
          updatedAt: DateTime(2024, 2, 15),
          metadata: const {},
        ),
        ExpenseEntity(
          id: '3',
          userId: 'user1',
          vehicleId: 'vehicle1',
          type: ExpenseType.insurance,
          description: 'Renovação do seguro',
          amount: 1200.0,
          date: DateTime(2024, 3, 15),
          odometer: 54000,
          createdAt: DateTime(2024, 3, 15),
          updatedAt: DateTime(2024, 3, 15),
          metadata: const {},
        ),
      ];
    });

    group('ExpenseFiltersConfig', () {
      test('deve criar configuração padrão', () {
        const config = ExpenseFiltersConfig();
        
        expect(config.vehicleId, isNull);
        expect(config.type, isNull);
        expect(config.startDate, isNull);
        expect(config.endDate, isNull);
        expect(config.searchQuery, equals(''));
        expect(config.sortBy, equals('date'));
        expect(config.sortAscending, isFalse);
        expect(config.hasActiveFilters, isFalse);
      });

      test('deve criar cópia com valores atualizados', () {
        const config = ExpenseFiltersConfig();
        final updated = config.copyWith(
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          searchQuery: 'combustível',
        );

        expect(updated.vehicleId, equals('vehicle1'));
        expect(updated.type, equals(ExpenseType.fuel));
        expect(updated.searchQuery, equals('combustível'));
        expect(updated.sortBy, equals('date')); // Mantido
        expect(updated.hasActiveFilters, isTrue);
      });

      test('deve limpar filtros específicos', () {
        final config = const ExpenseFiltersConfig().copyWith(
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
        );
        
        final cleared = config.copyWith(
          clearVehicleId: true,
          clearType: true,
        );

        expect(cleared.vehicleId, isNull);
        expect(cleared.type, isNull);
        expect(cleared.hasActiveFilters, isFalse);
      });

      test('deve limpar todos os filtros', () {
        final config = const ExpenseFiltersConfig().copyWith(
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          searchQuery: 'test',
        );
        
        final cleared = config.cleared();

        expect(cleared.vehicleId, isNull);
        expect(cleared.type, isNull);
        expect(cleared.searchQuery, equals(''));
        expect(cleared.hasActiveFilters, isFalse);
      });
    });

    group('Filtros', () {
      test('deve filtrar por veículo', () {
        const config = ExpenseFiltersConfig(vehicleId: 'vehicle1');
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.length, equals(2));
        expect(filtered.every((e) => e.vehicleId == 'vehicle1'), isTrue);
      });

      test('deve filtrar por tipo', () {
        const config = ExpenseFiltersConfig(type: ExpenseType.fuel);
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.length, equals(1));
        expect(filtered.first.type, equals(ExpenseType.fuel));
      });

      test('deve filtrar por período', () {
        final config = ExpenseFiltersConfig(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 28),
        );
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.length, equals(2)); // Janeiro e Fevereiro
      });

      test('deve filtrar por texto', () {
        const config = ExpenseFiltersConfig(searchQuery: 'shell');
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.length, equals(1));
        expect(filtered.first.title.toLowerCase(), contains('shell'));
      });

      test('deve aplicar múltiplos filtros', () {
        final config = ExpenseFiltersConfig(
          vehicleId: 'vehicle1',
          type: ExpenseType.fuel,
          searchQuery: 'combustível',
        );
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.length, equals(1));
        expect(filtered.first.vehicleId, equals('vehicle1'));
        expect(filtered.first.type, equals(ExpenseType.fuel));
      });

      test('deve retornar lista vazia quando não há correspondências', () {
        const config = ExpenseFiltersConfig(
          vehicleId: 'vehicle999',
        );
        final filtered = service.applyFilters(testExpenses, config);

        expect(filtered.isEmpty, isTrue);
      });
    });

    group('Ordenação', () {
      test('deve ordenar por data crescente', () {
        const config = ExpenseFiltersConfig(
          sortBy: 'date',
          sortAscending: true,
        );
        final sorted = service.applyFilters(testExpenses, config);

        expect(sorted.first.date.isBefore(sorted.last.date), isTrue);
      });

      test('deve ordenar por data decrescente (padrão)', () {
        const config = ExpenseFiltersConfig();
        final sorted = service.applyFilters(testExpenses, config);

        expect(sorted.first.date.isAfter(sorted.last.date), isTrue);
      });

      test('deve ordenar por valor', () {
        const config = ExpenseFiltersConfig(
          sortBy: 'amount',
          sortAscending: true,
        );
        final sorted = service.applyFilters(testExpenses, config);

        expect(sorted.first.amount, equals(150.0));
        expect(sorted.last.amount, equals(1200.0));
      });

      test('deve ordenar por tipo', () {
        const config = ExpenseFiltersConfig(
          sortBy: 'type',
          sortAscending: true,
        );
        final sorted = service.applyFilters(testExpenses, config);

        // Ordem alfabética: Combustível, Manutenção, Seguro
        expect(sorted.map((e) => e.type.displayName).toList(), 
               equals(['Combustível', 'Manutenção', 'Seguro']));
      });
    });

    group('Métodos de conveniência', () {
      test('deve obter despesas de alto valor', () {
        final highValue = service.getHighValueExpenses(
          testExpenses,
          threshold: 500.0,
        );

        expect(highValue.length, equals(1));
        expect(highValue.first.amount, equals(1200.0));
      });

      test('deve obter despesas recorrentes', () {
        // Adicionar despesa similar para teste
        final expensesWithRecurring = [
          ...testExpenses,
          ExpenseEntity(
            id: '4',
            userId: 'user1',
            vehicleId: 'vehicle1',
            type: ExpenseType.fuel,
            description: 'Outro abastecimento',
            amount: 155.0, // Similar ao primeiro (150.0)
            date: DateTime(2024, 4, 15),
            odometer: 56000,
            createdAt: DateTime(2024, 4, 15),
            updatedAt: DateTime(2024, 4, 15),
            metadata: const {},
          ),
        ];

        final recurring = service.getRecurringExpenses(
          expensesWithRecurring,
          amountTolerance: 0.1, // 10% de tolerância
        );

        expect(recurring.length, equals(2)); // As duas despesas de combustível
      });

      test('deve agrupar por faixa de valores', () {
        final grouped = service.groupByValueRange(testExpenses);

        expect(grouped['Até R\$ 100'], isEmpty);
        expect(grouped['R\$ 100 - R\$ 500']?.length, equals(2));
        expect(grouped['R\$ 1.000 - R\$ 5.000']?.length, equals(1));
      });

      test('deve agrupar por mês', () {
        final grouped = service.groupByMonth(testExpenses);

        expect(grouped['2024-01']?.length, equals(1));
        expect(grouped['2024-02']?.length, equals(1));
        expect(grouped['2024-03']?.length, equals(1));
      });

      test('deve agrupar por tipo', () {
        final grouped = service.groupByType(testExpenses);

        expect(grouped[ExpenseType.fuel]?.length, equals(1));
        expect(grouped[ExpenseType.maintenance]?.length, equals(1));
        expect(grouped[ExpenseType.insurance]?.length, equals(1));
      });
    });

    group('Busca por texto', () {
      test('deve buscar em múltiplos campos', () {
        final results1 = service.searchByText(testExpenses, 'shell');
        final results2 = service.searchByText(testExpenses, 'óleo');
        final results3 = service.searchByText(testExpenses, 'posto');

        expect(results1.length, equals(1)); // Título
        expect(results2.length, equals(1)); // Título
        expect(results3.length, equals(1)); // Nome do estabelecimento
      });

      test('deve ser case-insensitive', () {
        final results = service.searchByText(testExpenses, 'SHELL');
        expect(results.length, equals(1));
      });

      test('deve retornar todas quando busca vazia', () {
        final results = service.searchByText(testExpenses, '');
        expect(results.length, equals(testExpenses.length));
      });
    });
  });
}