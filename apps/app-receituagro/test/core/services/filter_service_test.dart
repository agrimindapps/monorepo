import 'package:app_receituagro/core/services/filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ===== TEST DATA MODELS =====

/// Simple test model for filtering tests
class TestItem {
  final String id;
  final String name;
  final String type;
  final String userId;
  final DateTime createdAt;
  final bool isDeleted;

  TestItem({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
    required this.createdAt,
    required this.isDeleted,
  });
}

void main() {
  // ===== GROUP 1: SEARCH FILTERING =====

  group('FilterService - Search Term Filtering', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Apple',
          type: 'Fruit',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Apricot',
          type: 'Fruit',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: false,
        ),
        TestItem(
          id: '3',
          name: 'Banana',
          type: 'Fruit',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: false,
        ),
      ];
    });

    test('should filter items by exact name match', () {
      // Act
      final result = FilterService.filterBySearchTerm<TestItem>(
        items,
        'Apple',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('should filter items by partial name match', () {
      // Act
      final result = FilterService.filterBySearchTerm<TestItem>(
        items,
        'ap',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 2);
      expect(result.map((i) => i.name).toList(), ['Apple', 'Apricot']);
    });

    test('should be case-insensitive', () {
      // Act
      final result = FilterService.filterBySearchTerm<TestItem>(
        items,
        'APPLE',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('should return all items when search term is empty', () {
      // Act
      final result = FilterService.filterBySearchTerm<TestItem>(
        items,
        '',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 3);
    });

    test('should return empty list when no match found', () {
      // Act
      final result = FilterService.filterBySearchTerm<TestItem>(
        items,
        'xyz',
        (item) => item.name,
      );

      // Assert
      expect(result.isEmpty, true);
    });
  });

  // ===== GROUP 2: TYPE FILTERING =====

  group('FilterService - Type Filtering', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Apple',
          type: 'Fruit',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Carrot',
          type: 'Vegetable',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: false,
        ),
        TestItem(
          id: '3',
          name: 'Broccoli',
          type: 'Vegetable',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: false,
        ),
      ];
    });

    test('should filter by single type', () {
      // Act
      final result = FilterService.filterByType<TestItem>(
        items,
        'Fruit',
        (item) => item.type,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.type, 'Fruit');
    });

    test('should filter by multiple types', () {
      // Act
      final result = FilterService.filterByTypes<TestItem>(
        items,
        ['Fruit', 'Vegetable'],
        (item) => item.type,
      );

      // Assert
      expect(result.length, 3);
    });

    test('should return empty list when type not found', () {
      // Act
      final result = FilterService.filterByType<TestItem>(
        items,
        'Meat',
        (item) => item.type,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should handle case-sensitive type matching', () {
      // Act
      final result = FilterService.filterByType<TestItem>(
        items,
        'fruit',
        (item) => item.type,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should filter by multiple types with partial list', () {
      // Act
      final result = FilterService.filterByTypes<TestItem>(
        items,
        ['Fruit'],
        (item) => item.type,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.type, 'Fruit');
    });
  });

  // ===== GROUP 3: USER ID FILTERING =====

  group('FilterService - User ID Filtering', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Item1',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Item2',
          type: 'Type2',
          userId: 'user-2',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: false,
        ),
        TestItem(
          id: '3',
          name: 'Item3',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: false,
        ),
      ];
    });

    test('should filter by user ID', () {
      // Act
      final result = FilterService.filterByUserId<TestItem>(
        items,
        'user-1',
        (item) => item.userId,
      );

      // Assert
      expect(result.length, 2);
      expect(result.every((item) => item.userId == 'user-1'), true);
    });

    test('should return empty list when user ID is empty', () {
      // Act
      final result = FilterService.filterByUserId<TestItem>(
        items,
        '',
        (item) => item.userId,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should return empty list when user ID not found', () {
      // Act
      final result = FilterService.filterByUserId<TestItem>(
        items,
        'user-999',
        (item) => item.userId,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should filter by user ID and type combined', () {
      // Act
      final result = FilterService.filterByUserIdAndType<TestItem>(
        items,
        'user-1',
        'Type1',
        (item) => item.userId,
        (item) => item.type,
      );

      // Assert
      expect(result.length, 2);
      expect(result.every((item) => item.userId == 'user-1'), true);
      expect(result.every((item) => item.type == 'Type1'), true);
    });

    test('should handle empty user ID in combined filter', () {
      // Act
      final result = FilterService.filterByUserIdAndType<TestItem>(
        items,
        '',
        'Type1',
        (item) => item.userId,
        (item) => item.type,
      );

      // Assert
      expect(result.isEmpty, true);
    });
  });

  // ===== GROUP 4: ACTIVE/DELETED FILTERING =====

  group('FilterService - Active/Deleted Filtering', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Active1',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Deleted1',
          type: 'Type2',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: true,
        ),
        TestItem(
          id: '3',
          name: 'Active2',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: false,
        ),
      ];
    });

    test('should filter active items only', () {
      // Act
      final result = FilterService.filterActiveOnly<TestItem>(
        items,
        (item) => item.isDeleted,
      );

      // Assert
      expect(result.length, 2);
      expect(result.every((item) => !item.isDeleted), true);
    });

    test('should return empty list when all items are deleted', () {
      // Arrange
      final allDeleted = items.map((item) {
        return TestItem(
          id: item.id,
          name: item.name,
          type: item.type,
          userId: item.userId,
          createdAt: item.createdAt,
          isDeleted: true,
        );
      }).toList();

      // Act
      final result = FilterService.filterActiveOnly<TestItem>(
        allDeleted,
        (item) => item.isDeleted,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should return all items when none are deleted', () {
      // Arrange
      final noneDeleted = items.map((item) {
        return TestItem(
          id: item.id,
          name: item.name,
          type: item.type,
          userId: item.userId,
          createdAt: item.createdAt,
          isDeleted: false,
        );
      }).toList();

      // Act
      final result = FilterService.filterActiveOnly<TestItem>(
        noneDeleted,
        (item) => item.isDeleted,
      );

      // Assert
      expect(result.length, 3);
    });
  });

  // ===== GROUP 5: COMBINED FILTERS =====

  group('FilterService - Combined Filters', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Apple',
          type: 'Fruit',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Carrot',
          type: 'Vegetable',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: false,
        ),
        TestItem(
          id: '3',
          name: 'Broccoli',
          type: 'Vegetable',
          userId: 'user-2',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: true,
        ),
      ];
    });

    test('should apply multiple filter predicates', () {
      // Act
      final result = FilterService.combineFilters<TestItem>(
        items,
        [
          (item) => item.userId == 'user-1',
          (item) => !item.isDeleted,
          (item) => item.type == 'Vegetable',
        ],
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.name, 'Carrot');
    });

    test('should return empty list when one predicate matches nothing', () {
      // Act
      final result = FilterService.combineFilters<TestItem>(
        items,
        [
          (item) => item.userId == 'user-1',
          (item) => !item.isDeleted,
          (item) => item.type == 'Meat', // No meat items
        ],
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should handle single predicate in combine', () {
      // Act
      final result = FilterService.combineFilters<TestItem>(
        items,
        [(item) => item.userId == 'user-1'],
      );

      // Assert
      expect(result.length, 2);
    });

    test('should handle empty predicate list', () {
      // Act
      final result = FilterService.combineFilters<TestItem>(
        items,
        [],
      );

      // Assert
      expect(result.length, 3);
    });
  });

  // ===== GROUP 6: SORTING =====

  group('FilterService - Sorting', () {
    late List<TestItem> items;

    setUp(() {
      items = [
        TestItem(
          id: '1',
          name: 'Item1',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 3),
          isDeleted: false,
        ),
        TestItem(
          id: '2',
          name: 'Item2',
          type: 'Type2',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
        TestItem(
          id: '3',
          name: 'Item3',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 2),
          isDeleted: false,
        ),
      ];
    });

    test('should sort by creation date descending', () {
      // Act
      final result = FilterService.sortByCreatedAtDesc<TestItem>(
        items,
        (item) => item.createdAt,
      );

      // Assert
      expect(result[0].id, '1');
      expect(result[1].id, '3');
      expect(result[2].id, '2');
    });

    test('should sort by creation date ascending', () {
      // Act
      final result = FilterService.sortByCreatedAtAsc<TestItem>(
        items,
        (item) => item.createdAt,
      );

      // Assert
      expect(result[0].id, '2');
      expect(result[1].id, '3');
      expect(result[2].id, '1');
    });

    test('should not modify original list in sort', () {
      // Arrange
      final originalOrder = [items[0].id, items[1].id, items[2].id];

      // Act
      FilterService.sortByCreatedAtDesc<TestItem>(
        items,
        (item) => item.createdAt,
      );

      // Assert
      expect(
        [items[0].id, items[1].id, items[2].id],
        equals(originalOrder),
      );
    });
  });

  // ===== GROUP 7: PAGINATION =====

  group('FilterService - Pagination', () {
    late List<TestItem> items;

    setUp(() {
      items = List.generate(
        10,
        (index) => TestItem(
          id: '$index',
          name: 'Item$index',
          type: 'Type${index % 3}',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, index + 1),
          isDeleted: false,
        ),
      );
    });

    test('should paginate correctly - first page', () {
      // Act
      final result = FilterService.paginate<TestItem>(
        items,
        page: 0,
        pageSize: 3,
      );

      // Assert
      expect(result.length, 3);
      expect(result[0].name, 'Item0');
      expect(result[1].name, 'Item1');
      expect(result[2].name, 'Item2');
    });

    test('should paginate correctly - second page', () {
      // Act
      final result = FilterService.paginate<TestItem>(
        items,
        page: 1,
        pageSize: 3,
      );

      // Assert
      expect(result.length, 3);
      expect(result[0].name, 'Item3');
      expect(result[1].name, 'Item4');
      expect(result[2].name, 'Item5');
    });

    test('should paginate last page with partial results', () {
      // Act
      final result = FilterService.paginate<TestItem>(
        items,
        page: 3,
        pageSize: 3,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].name, 'Item9');
    });

    test('should return empty list for out of bounds page', () {
      // Act
      final result = FilterService.paginate<TestItem>(
        items,
        page: 10,
        pageSize: 3,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should handle page size larger than list', () {
      // Act
      final result = FilterService.paginate<TestItem>(
        items,
        page: 0,
        pageSize: 100,
      );

      // Assert
      expect(result.length, 10);
    });
  });

  // ===== GROUP 8: EDGE CASES & PERFORMANCE =====

  group('FilterService - Edge Cases & Performance', () {
    test('should handle empty list filtering', () {
      // Arrange
      final emptyList = <TestItem>[];

      // Act & Assert
      expect(
        FilterService.filterBySearchTerm(emptyList, 'test', (item) => item.name),
        isEmpty,
      );
      expect(
        FilterService.filterByType(emptyList, 'test', (item) => item.type),
        isEmpty,
      );
      expect(
        FilterService.filterActiveOnly(emptyList, (item) => item.isDeleted),
        isEmpty,
      );
    });

    test('should handle single item list', () {
      // Arrange
      final singleItem = [
        TestItem(
          id: '1',
          name: 'Single',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
      ];

      // Act
      final result = FilterService.filterBySearchTerm(
        singleItem,
        'Single',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 1);
    });

    test('should handle large list efficiently', () {
      // Arrange
      final largeList = List.generate(
        1000,
        (index) => TestItem(
          id: '$index',
          name: 'Item$index',
          type: 'Type${index % 10}',
          userId: 'user-${index % 5}',
          createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
          isDeleted: index % 10 == 0,
        ),
      );

      // Act
      final result = FilterService.filterBySearchTerm(
        largeList,
        'Item',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 1000);
    });

    test('should handle special characters in search', () {
      // Arrange
      final items = [
        TestItem(
          id: '1',
          name: 'Test@Item#1',
          type: 'Type1',
          userId: 'user-1',
          createdAt: DateTime(2024, 1, 1),
          isDeleted: false,
        ),
      ];

      // Act
      final result = FilterService.filterBySearchTerm(
        items,
        '@',
        (item) => item.name,
      );

      // Assert
      expect(result.length, 1);
    });
  });
}
