import 'package:app_receituagro/core/services/stats_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ===== TEST DATA MODEL =====

/// Simple test model for statistics tests
class StatItem {
  final String id;
  final String category;
  final String key;
  final int value;

  StatItem({
    required this.id,
    required this.category,
    required this.key,
    required this.value,
  });
}

void main() {
  // ===== GROUP 1: COUNTING =====

  group('StatsService - Counting', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
      ];
    });

    test('should count total items', () {
      // Act
      final count = StatsService.countTotal<StatItem>(items);

      // Assert
      expect(count, 3);
    });

    test('should count items matching condition', () {
      // Act
      final count = StatsService.countWhere<StatItem>(
        items,
        (item) => item.category == 'A',
      );

      // Assert
      expect(count, 2);
    });

    test('should count by category', () {
      // Act
      final counts = StatsService.countByCategory<StatItem>(
        items,
        (item) => item.category,
      );

      // Assert
      expect(counts['A'], 2);
      expect(counts['B'], 1);
      expect(counts.length, 2);
    });

    test('should return 0 for count with no matches', () {
      // Act
      final count = StatsService.countWhere<StatItem>(
        items,
        (item) => item.category == 'Z',
      );

      // Assert
      expect(count, 0);
    });

    test('should handle empty list in count', () {
      // Act
      final count = StatsService.countTotal<StatItem>([]);

      // Assert
      expect(count, 0);
    });

    test('should count by category with empty list', () {
      // Act
      final counts = StatsService.countByCategory<StatItem>(
        [],
        (item) => item.category,
      );

      // Assert
      expect(counts.isEmpty, true);
    });
  });

  // ===== GROUP 2: PERCENTAGES =====

  group('StatsService - Percentages', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
        StatItem(id: '4', category: 'A', key: 'k4', value: 40),
      ];
    });

    test('should calculate percentage correctly', () {
      // Act
      final percentage = StatsService.percentageWhere<StatItem>(
        items,
        (item) => item.category == 'A',
      );

      // Assert
      expect(percentage, 75.0);
    });

    test('should handle 100% match', () {
      // Act
      final percentage = StatsService.percentageWhere<StatItem>(
        items,
        (item) => item.value > 0,
      );

      // Assert
      expect(percentage, 100.0);
    });

    test('should handle 0% match', () {
      // Act
      final percentage = StatsService.percentageWhere<StatItem>(
        items,
        (item) => item.category == 'Z',
      );

      // Assert
      expect(percentage, 0.0);
    });

    test('should return 0.0 for empty list', () {
      // Act
      final percentage = StatsService.percentageWhere<StatItem>(
        [],
        (item) => item.value > 0,
      );

      // Assert
      expect(percentage, 0.0);
    });

    test('should calculate percentage with decimal places', () {
      // Arrange
      final items = List.generate(3, (i) {
        return StatItem(
          id: '$i',
          category: i == 0 ? 'A' : 'B',
          key: 'k$i',
          value: i,
        );
      });

      // Act
      final percentage = StatsService.percentageWhere<StatItem>(
        items,
        (item) => item.category == 'A',
      );

      // Assert
      expect(percentage, closeTo(33.33, 0.1));
    });
  });

  // ===== GROUP 3: GROUPING =====

  group('StatsService - Grouping', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
        StatItem(id: '4', category: 'B', key: 'k4', value: 40),
      ];
    });

    test('should group items by category', () {
      // Act
      final groups = StatsService.groupBy<StatItem>(
        items,
        (item) => item.category,
      );

      // Assert
      expect(groups.length, 2);
      expect(groups['A']?.length, 2);
      expect(groups['B']?.length, 2);
    });

    test('should group items maintaining order within groups', () {
      // Act
      final groups = StatsService.groupBy<StatItem>(
        items,
        (item) => item.category,
      );

      // Assert
      expect(groups['A']?[0].id, '1');
      expect(groups['A']?[1].id, '3');
    });

    test('should handle grouping empty list', () {
      // Act
      final groups = StatsService.groupBy<StatItem>(
        [],
        (item) => item.category,
      );

      // Assert
      expect(groups.isEmpty, true);
    });

    test('should handle single group', () {
      // Arrange
      final singleGroup = items.where((item) => item.category == 'A').toList();

      // Act
      final groups = StatsService.groupBy<StatItem>(
        singleGroup,
        (item) => item.category,
      );

      // Assert
      expect(groups.length, 1);
      expect(groups['A']?.length, 2);
    });
  });

  // ===== GROUP 4: UNIQUE VALUES =====

  group('StatsService - Unique Values', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
        StatItem(id: '4', category: 'B', key: 'k4', value: 40),
      ];
    });

    test('should get unique categories', () {
      // Act
      final unique = StatsService.uniqueValues<StatItem>(
        items,
        (item) => item.category,
      );

      // Assert
      expect(unique.length, 2);
      expect(unique.contains('A'), true);
      expect(unique.contains('B'), true);
    });

    test('should handle all unique values', () {
      // Act
      final unique = StatsService.uniqueValues<StatItem>(
        items,
        (item) => item.id,
      );

      // Assert
      expect(unique.length, 4);
    });

    test('should handle no unique values', () {
      // Arrange
      final allSame = items
          .map((item) =>
              StatItem(id: item.id, category: 'X', key: 'k', value: 1))
          .toList();

      // Act
      final unique = StatsService.uniqueValues<StatItem>(
        allSame,
        (item) => item.category,
      );

      // Assert
      expect(unique.length, 1);
    });

    test('should return empty set for empty list', () {
      // Act
      final unique = StatsService.uniqueValues<StatItem>(
        [],
        (item) => item.category,
      );

      // Assert
      expect(unique.isEmpty, true);
    });
  });

  // ===== GROUP 5: AGGREGATIONS (SUM, AVERAGE, MIN, MAX) =====

  group('StatsService - Aggregations', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
      ];
    });

    test('should calculate sum', () {
      // Act
      final sum = StatsService.sum<StatItem>(
        items,
        (item) => item.value,
      );

      // Assert
      expect(sum, 60);
    });

    test('should calculate average', () {
      // Act
      final avg = StatsService.average<StatItem>(
        items,
        (item) => item.value,
      );

      // Assert
      expect(avg, 20);
    });

    test('should find min value', () {
      // Act
      final min = StatsService.minValue<StatItem>(
        items,
        (item) => item.value,
      );

      // Assert
      expect(min, 10);
    });

    test('should find max value', () {
      // Act
      final max = StatsService.maxValue<StatItem>(
        items,
        (item) => item.value,
      );

      // Assert
      expect(max, 30);
    });

    test('should return 0.0 for average of empty list', () {
      // Act
      final avg = StatsService.average<StatItem>(
        [],
        (item) => item.value,
      );

      // Assert
      expect(avg, 0.0);
    });

    test('should return null for min of empty list', () {
      // Act
      final min = StatsService.minValue<StatItem>(
        [],
        (item) => item.value,
      );

      // Assert
      expect(min, null);
    });

    test('should return null for max of empty list', () {
      // Act
      final max = StatsService.maxValue<StatItem>(
        [],
        (item) => item.value,
      );

      // Assert
      expect(max, null);
    });

    test('should return 0 for sum of empty list', () {
      // Act
      final sum = StatsService.sum<StatItem>(
        [],
        (item) => item.value,
      );

      // Assert
      expect(sum, 0);
    });
  });

  // ===== GROUP 6: SUMMARY STATISTICS =====

  group('StatsService - Summary Statistics', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
      ];
    });

    test('should generate summary statistics', () {
      // Act
      final summary = StatsService.summaryStats<StatItem>(
        items,
        (item) => item.value,
      );

      // Assert
      expect(summary['count'], 3);
      expect(summary['sum'], 60);
      expect(summary['average'], 20);
      expect(summary['min'], 10);
      expect(summary['max'], 30);
    });

    test('should generate summary for empty list', () {
      // Act
      final summary = StatsService.summaryStats<StatItem>(
        [],
        (item) => item.value,
      );

      // Assert
      expect(summary['count'], 0);
      expect(summary['sum'], 0);
      expect(summary['average'], 0.0);
      expect(summary['min'], null);
      expect(summary['max'], null);
    });

    test('should handle single item summary', () {
      // Arrange
      final single = [items.first];

      // Act
      final summary = StatsService.summaryStats<StatItem>(
        single,
        (item) => item.value,
      );

      // Assert
      expect(summary['count'], 1);
      expect(summary['sum'], 10);
      expect(summary['average'], 10);
      expect(summary['min'], 10);
      expect(summary['max'], 10);
    });
  });

  // ===== GROUP 7: BOOLEAN OPERATIONS =====

  group('StatsService - Boolean Operations', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
      ];
    });

    test('should check if all items match condition', () {
      // Act
      final all = StatsService.all<StatItem>(
        items,
        (item) => item.value > 0,
      );

      // Assert
      expect(all, true);
    });

    test('should return false when not all items match', () {
      // Act
      final all = StatsService.all<StatItem>(
        items,
        (item) => item.category == 'A',
      );

      // Assert
      expect(all, false);
    });

    test('should check if any item matches condition', () {
      // Act
      final any = StatsService.any<StatItem>(
        items,
        (item) => item.category == 'B',
      );

      // Assert
      expect(any, true);
    });

    test('should return false when no items match', () {
      // Act
      final any = StatsService.any<StatItem>(
        items,
        (item) => item.category == 'Z',
      );

      // Assert
      expect(any, false);
    });

    test('should handle empty list in all check', () {
      // Act
      final all = StatsService.all<StatItem>(
        [],
        (item) => item.value > 0,
      );

      // Assert
      expect(all, true); // Vacuous truth
    });

    test('should handle empty list in any check', () {
      // Act
      final any = StatsService.any<StatItem>(
        [],
        (item) => item.value > 0,
      );

      // Assert
      expect(any, false);
    });
  });

  // ===== GROUP 8: DISTINCT & TOP/BOTTOM N =====

  group('StatsService - Distinct & Top/Bottom N', () {
    late List<StatItem> items;

    setUp(() {
      items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: 30),
        StatItem(id: '4', category: 'C', key: 'k4', value: 40),
        StatItem(id: '5', category: 'A', key: 'k5', value: 50),
      ];
    });

    test('should get distinct items by key', () {
      // Act
      final distinct = StatsService.distinct<StatItem>(
        items,
        (item) => item.category,
      );

      // Assert
      expect(distinct.length, 3);
    });

    test('should get top N items by value', () {
      // Act
      final top = StatsService.topN<StatItem>(
        items,
        3,
        (item) => item.value,
      );

      // Assert
      expect(top.length, 3);
      expect(top[0].value, 50);
      expect(top[1].value, 40);
      expect(top[2].value, 30);
    });

    test('should get bottom N items by value', () {
      // Act
      final bottom = StatsService.bottomN<StatItem>(
        items,
        2,
        (item) => item.value,
      );

      // Assert
      expect(bottom.length, 2);
      expect(bottom[0].value, 10);
      expect(bottom[1].value, 20);
    });

    test('should handle top N larger than list', () {
      // Act
      final top = StatsService.topN<StatItem>(
        items,
        100,
        (item) => item.value,
      );

      // Assert
      expect(top.length, 5);
    });

    test('should handle top N of zero', () {
      // Act
      final top = StatsService.topN<StatItem>(
        items,
        0,
        (item) => item.value,
      );

      // Assert
      expect(top.isEmpty, true);
    });

    test('should handle distinct with all unique keys', () {
      // Act
      final distinct = StatsService.distinct<StatItem>(
        items,
        (item) => item.id,
      );

      // Assert
      expect(distinct.length, 5);
    });
  });

  // ===== GROUP 9: EDGE CASES & PERFORMANCE =====

  group('StatsService - Edge Cases & Performance', () {
    test('should handle empty list operations', () {
      // Act & Assert
      expect(StatsService.countTotal<StatItem>([]), 0);
      expect(StatsService.average<StatItem>([], (item) => item.value), 0.0);
      expect(StatsService.sum<StatItem>([], (item) => item.value), 0);
      expect(StatsService.all<StatItem>([], (item) => true), true);
      expect(StatsService.any<StatItem>([], (item) => true), false);
    });

    test('should handle single item operations', () {
      // Arrange
      final single = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 42),
      ];

      // Act & Assert
      expect(StatsService.countTotal<StatItem>(single), 1);
      expect(StatsService.average<StatItem>(single, (item) => item.value), 42);
      expect(StatsService.minValue<StatItem>(single, (item) => item.value), 42);
      expect(StatsService.maxValue<StatItem>(single, (item) => item.value), 42);
    });

    test('should handle large list operations efficiently', () {
      // Arrange - Generate large list
      final largeList = List.generate(
        10000,
        (i) => StatItem(
          id: '$i',
          category: 'Cat${i % 10}',
          key: 'k$i',
          value: i % 1000,
        ),
      );

      // Act
      final count = StatsService.countTotal<StatItem>(largeList);
      final sum = StatsService.sum<StatItem>(largeList, (item) => item.value);
      final groups = StatsService.groupBy<StatItem>(
        largeList,
        (item) => item.category,
      );

      // Assert
      expect(count, 10000);
      expect(sum, isNotNull);
      expect(groups.length, 10);
    });

    test('should handle negative values in calculations', () {
      // Arrange
      final items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: -10),
        StatItem(id: '2', category: 'B', key: 'k2', value: 20),
        StatItem(id: '3', category: 'A', key: 'k3', value: -5),
      ];

      // Act
      final sum = StatsService.sum<StatItem>(items, (item) => item.value);
      final avg = StatsService.average<StatItem>(items, (item) => item.value);
      final min = StatsService.minValue<StatItem>(items, (item) => item.value);
      final max = StatsService.maxValue<StatItem>(items, (item) => item.value);

      // Assert
      expect(sum, 5);
      expect(avg, closeTo(1.67, 0.1));
      expect(min, -10);
      expect(max, 20);
    });

    test('should handle zero values in aggregations', () {
      // Arrange
      final items = [
        StatItem(id: '1', category: 'A', key: 'k1', value: 0),
        StatItem(id: '2', category: 'B', key: 'k2', value: 0),
        StatItem(id: '3', category: 'A', key: 'k3', value: 0),
      ];

      // Act
      final sum = StatsService.sum<StatItem>(items, (item) => item.value);
      final avg = StatsService.average<StatItem>(items, (item) => item.value);

      // Assert
      expect(sum, 0);
      expect(avg, 0);
    });
  });
}
