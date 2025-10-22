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
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      final result = useCase(params);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, GameDifficulty.easy.totalCards);
          expect(cards.length, 16);
        },
      );
    });

    test('should generate correct number of cards for medium difficulty', () {
      const params = GenerateCardsParams(difficulty: GameDifficulty.medium);

      final result = useCase(params);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, GameDifficulty.medium.totalCards);
          expect(cards.length, 36);
        },
      );
    });

    test('should generate correct number of cards for hard difficulty', () {
      const params = GenerateCardsParams(difficulty: GameDifficulty.hard);

      final result = useCase(params);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          expect(cards.length, GameDifficulty.hard.totalCards);
          expect(cards.length, 64);
        },
      );
    });

    test('should generate pairs of cards with matching pairId', () {
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      final result = useCase(params);

      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final pairIds = <int, int>{};
          for (final card in cards) {
            pairIds[card.pairId] = (pairIds[card.pairId] ?? 0) + 1;
          }

          for (final count in pairIds.values) {
            expect(count, 2, reason: 'Each pair should have exactly 2 cards');
          }
        },
      );
    });

    test('should generate cards with unique IDs', () {
      const params = GenerateCardsParams(difficulty: GameDifficulty.medium);

      final result = useCase(params);

      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final ids = cards.map((c) => c.id).toSet();
          expect(
            ids.length,
            cards.length,
            reason: 'All card IDs should be unique',
          );
        },
      );
    });

    test('should assign position to all cards', () {
      const params = GenerateCardsParams(difficulty: GameDifficulty.easy);

      final result = useCase(params);

      result.fold(
        (failure) => fail('Should not return failure'),
        (cards) {
          final positions = cards.map((c) => c.position).toSet();
          expect(
            positions.length,
            cards.length,
            reason: 'All positions should be unique',
          );

          for (int i = 0; i < cards.length; i++) {
            expect(
              positions.contains(i),
              true,
              reason: 'Position $i should exist',
            );
          }
        },
      );
    });
  });
}
