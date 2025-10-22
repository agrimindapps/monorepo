import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/card_entity.dart';
import '../entities/enums.dart';

class GenerateCardsParams {
  final GameDifficulty difficulty;

  const GenerateCardsParams({required this.difficulty});
}

class GenerateCardsUseCase {
  Either<Failure, List<CardEntity>> call(GenerateCardsParams params) {
    try {
      final difficulty = params.difficulty;
      final totalPairs = difficulty.totalPairs;
      final List<CardEntity> cards = [];

      for (int i = 0; i < totalPairs; i++) {
        final color = CardThemes.cardColors[i % CardThemes.cardColors.length];
        final icon = CardThemes.cardIcons[i % CardThemes.cardIcons.length];

        cards.add(
          CardEntity(
            id: 'card_${i * 2}',
            pairId: i,
            color: color,
            icon: icon,
            position: i * 2,
          ),
        );

        cards.add(
          CardEntity(
            id: 'card_${i * 2 + 1}',
            pairId: i,
            color: color,
            icon: icon,
            position: i * 2 + 1,
          ),
        );
      }

      cards.shuffle(Random());

      for (int i = 0; i < cards.length; i++) {
        cards[i] = cards[i].copyWith(position: i);
      }

      return Right(cards);
    } catch (e) {
      return Left(CacheFailure('Failed to generate cards: $e'));
    }
  }
}
