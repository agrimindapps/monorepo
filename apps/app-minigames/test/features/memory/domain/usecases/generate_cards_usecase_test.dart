import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/usecases/generate_cards_usecase.dart';

void main() {
  late GenerateCardsUseCase useCase;

  setUp(() {
    useCase = GenerateCardsUseCase();
  });

  group('GenerateCardsUseCase', () {
    test('should generate correct number of cards for easy difficulty', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);
      const expectedTotalCards = 16; // 4x4 grid = 16 total cards (8 pairs)

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, expectedTotalCards);
        },
      );
    });

    test('should generate correct number of cards for medium difficulty', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.medium);
      const expectedTotalCards = 36; // 6x6 grid = 36 total cards (18 pairs)

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, expectedTotalCards);
        },
      );
    });

    test('should generate correct number of cards for hard difficulty', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.hard);
      const expectedTotalCards = 64; // 8x8 grid = 64 total cards (32 pairs)

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, expectedTotalCards);
        },
      );
    });

    test('should generate cards in pairs with matching pairId', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final groupedByPairId = <int, int>{};

          for (final card in cards) {
            groupedByPairId[card.pairId] = (groupedByPairId[card.pairId] ?? 0) + 1;
          }

          // Each pairId should appear exactly twice
          for (final count in groupedByPairId.values) {
            expect(count, 2, reason: 'Each pairId should appear exactly twice');
          }
        },
      );
    });

    test('should generate cards with matching color and icon for each pair', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final groupedByPairId = <int, List<dynamic>>{};

          for (final card in cards) {
            groupedByPairId.putIfAbsent(card.pairId, () => []);
            groupedByPairId[card.pairId]!.add([card.color, card.icon]);
          }

          // Verify each pair has matching colors and icons
          for (final pair in groupedByPairId.values) {
            expect(pair.length, 2);
            expect(pair[0][0], pair[1][0], reason: 'Colors should match in pair');
            expect(pair[0][1], pair[1][1], reason: 'Icons should match in pair');
          }
        },
      );
    });

    test('should generate cards with unique IDs', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final ids = cards.map((card) => card.id).toList();
          final uniqueIds = ids.toSet();

          expect(uniqueIds.length, ids.length, reason: 'All card IDs should be unique');
        },
      );
    });

    test('should generate cards with different IDs for pairs', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final groupedByPairId = <int, List<String>>{};

          for (final card in cards) {
            groupedByPairId.putIfAbsent(card.pairId, () => []);
            groupedByPairId[card.pairId]!.add(card.id);
          }

          // Verify each pair has different IDs
          for (final pair in groupedByPairId.values) {
            expect(pair[0], isNot(equals(pair[1])), reason: 'Pair IDs should be different');
          }
        },
      );
    });

    test('should generate all cards in hidden state', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          for (final card in cards) {
            expect(card.state, CardState.hidden);
          }
        },
      );
    });

    test('should assign sequential positions after shuffling', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final positions = cards.map((card) => card.position).toList();
          final expectedPositions = List.generate(cards.length, (i) => i);

          expect(positions, equals(expectedPositions), reason: 'Positions should be 0, 1, 2, ..., n-1');
        },
      );
    });

    test('should generate different card orders on multiple calls (randomness)', () {
      // Arrange
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      // Act - Generate cards multiple times
      final result1 = useCase(params);
      final result2 = useCase(params);
      final result3 = useCase(params);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      expect(result3.isRight(), true);

      final cards1 = result1.getOrElse(() => []);
      final cards2 = result2.getOrElse(() => []);
      final cards3 = result3.getOrElse(() => []);

      // Get pairId sequences to compare
      final sequence1 = cards1.map((c) => c.pairId).toList();
      final sequence2 = cards2.map((c) => c.pairId).toList();
      final sequence3 = cards3.map((c) => c.pairId).toList();

      // At least one sequence should be different (very high probability with shuffle)
      final allSame = sequence1.toString() == sequence2.toString() &&
          sequence2.toString() == sequence3.toString();

      expect(allSame, false, reason: 'Shuffling should produce different orders');
    });
  });
}
