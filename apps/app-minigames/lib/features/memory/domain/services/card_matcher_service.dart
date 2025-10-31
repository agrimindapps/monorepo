import 'package:injectable/injectable.dart';

import '../entities/card_entity.dart';
import '../entities/enums.dart';

/// Service responsible for matching logic in memory game
///
/// Handles:
/// - Card pair matching verification
/// - Match state updates
/// - Victory condition checking
/// - Match statistics
@lazySingleton
class CardMatcherService {
  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Checks if two cards form a matching pair
  ///
  /// Cards match if:
  /// - They have the same pairId
  /// - They have different ids (not the same card)
  bool isMatch(CardEntity card1, CardEntity card2) {
    return card1.pairId == card2.pairId && card1.id != card2.id;
  }

  /// Updates cards based on match result
  ///
  /// If match: sets both cards to matched state
  /// If no match: sets both cards to hidden state
  List<CardEntity> updateCardsAfterMatch({
    required List<CardEntity> allCards,
    required CardEntity card1,
    required CardEntity card2,
    required bool matched,
  }) {
    final targetState = matched ? CardState.matched : CardState.hidden;
    final targetIds = {card1.id, card2.id};

    return allCards.map((card) {
      if (targetIds.contains(card.id)) {
        return card.copyWith(state: targetState);
      }
      return card;
    }).toList();
  }

  /// Processes match attempt and returns result
  MatchResult processMatch({
    required CardEntity card1,
    required CardEntity card2,
    required List<CardEntity> allCards,
  }) {
    final matched = isMatch(card1, card2);
    final updatedCards = updateCardsAfterMatch(
      allCards: allCards,
      card1: card1,
      card2: card2,
      matched: matched,
    );

    return MatchResult(
      matched: matched,
      updatedCards: updatedCards,
      matchedPairId: matched ? card1.pairId : null,
    );
  }

  // ============================================================================
  // Victory Checking
  // ============================================================================

  /// Checks if player has won (all pairs matched)
  bool hasWon({
    required int currentMatches,
    required int totalPairs,
  }) {
    return currentMatches >= totalPairs;
  }

  /// Checks if game is complete based on cards state
  bool isGameComplete(List<CardEntity> cards) {
    return cards.every((card) => card.isMatched);
  }

  /// Gets count of matched pairs from cards
  int countMatchedPairs(List<CardEntity> cards) {
    final matchedPairIds = cards
        .where((card) => card.isMatched)
        .map((card) => card.pairId)
        .toSet();

    return matchedPairIds.length;
  }

  // ============================================================================
  // Card State Queries
  // ============================================================================

  /// Gets all matched cards
  List<CardEntity> getMatchedCards(List<CardEntity> cards) {
    return cards.where((card) => card.isMatched).toList();
  }

  /// Gets all unmatched cards
  List<CardEntity> getUnmatchedCards(List<CardEntity> cards) {
    return cards.where((card) => !card.isMatched).toList();
  }

  /// Gets cards by pair ID
  List<CardEntity> getCardsByPairId(List<CardEntity> cards, int pairId) {
    return cards.where((card) => card.pairId == pairId).toList();
  }

  /// Checks if specific pair is matched
  bool isPairMatched(List<CardEntity> cards, int pairId) {
    final pairCards = getCardsByPairId(cards, pairId);
    return pairCards.every((card) => card.isMatched);
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates match attempt
  MatchValidation validateMatchAttempt({
    required List<CardEntity> flippedCards,
    required List<CardEntity> allCards,
  }) {
    // Must have exactly 2 flipped cards
    if (flippedCards.length != 2) {
      return MatchValidation(
        isValid: false,
        errorMessage:
            'Must have exactly 2 flipped cards, got ${flippedCards.length}',
      );
    }

    final card1 = flippedCards[0];
    final card2 = flippedCards[1];

    // Cards must be different
    if (card1.id == card2.id) {
      return const MatchValidation(
        isValid: false,
        errorMessage: 'Cannot match card with itself',
      );
    }

    // Cards must not be already matched
    if (card1.isMatched || card2.isMatched) {
      return const MatchValidation(
        isValid: false,
        errorMessage: 'Cannot match already matched cards',
      );
    }

    return const MatchValidation(isValid: true);
  }

  /// Validates card pair integrity
  PairIntegrity validatePairIntegrity(List<CardEntity> cards) {
    final pairMap = <int, List<CardEntity>>{};

    // Group by pairId
    for (final card in cards) {
      pairMap.putIfAbsent(card.pairId, () => []).add(card);
    }

    // Check each pair
    final invalidPairs = <int>[];
    final incompletePairs = <int>[];

    for (final entry in pairMap.entries) {
      final pairCards = entry.value;

      if (pairCards.length != 2) {
        incompletePairs.add(entry.key);
      } else {
        final card1 = pairCards[0];
        final card2 = pairCards[1];

        // Verify they can match
        if (!isMatch(card1, card2)) {
          invalidPairs.add(entry.key);
        }
      }
    }

    return PairIntegrity(
      isValid: invalidPairs.isEmpty && incompletePairs.isEmpty,
      totalPairs: pairMap.length,
      invalidPairs: invalidPairs,
      incompletePairs: incompletePairs,
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets match statistics
  MatchStatistics getStatistics({
    required List<CardEntity> cards,
    required int totalMoves,
  }) {
    final matchedPairs = countMatchedPairs(cards);
    final totalPairs = cards.length ~/ 2;
    final remainingPairs = totalPairs - matchedPairs;
    final matchRate = totalMoves > 0 ? matchedPairs / totalMoves : 0.0;

    return MatchStatistics(
      matchedPairs: matchedPairs,
      totalPairs: totalPairs,
      remainingPairs: remainingPairs,
      totalMoves: totalMoves,
      matchRate: matchRate,
      perfectMatchRate: matchedPairs == totalMoves,
      completionPercentage: (matchedPairs / totalPairs * 100),
    );
  }

  /// Gets pair-by-pair status
  Map<int, PairStatus> getPairStatuses(List<CardEntity> cards) {
    final pairMap = <int, List<CardEntity>>{};

    // Group by pairId
    for (final card in cards) {
      pairMap.putIfAbsent(card.pairId, () => []).add(card);
    }

    // Build status map
    return pairMap.map((pairId, pairCards) {
      final matched = pairCards.every((card) => card.isMatched);
      final revealed =
          pairCards.any((card) => card.isFlipped && !card.isMatched);

      return MapEntry(
        pairId,
        PairStatus(
          pairId: pairId,
          matched: matched,
          revealed: revealed,
          cardCount: pairCards.length,
        ),
      );
    });
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Finds matching pair for a given card
  CardEntity? findMatchingCard(List<CardEntity> cards, CardEntity card) {
    try {
      return cards.firstWhere(
        (c) => c.pairId == card.pairId && c.id != card.id,
      );
    } catch (_) {
      return null;
    }
  }

  /// Checks if two cards can potentially match
  bool canPotentiallyMatch(CardEntity card1, CardEntity card2) {
    return card1.pairId == card2.pairId &&
        card1.id != card2.id &&
        !card1.isMatched &&
        !card2.isMatched;
  }

  /// Gets next unmatched pair ID
  int? getNextUnmatchedPairId(List<CardEntity> cards) {
    final unmatchedCards = getUnmatchedCards(cards);
    return unmatchedCards.isNotEmpty ? unmatchedCards.first.pairId : null;
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of a match attempt
class MatchResult {
  final bool matched;
  final List<CardEntity> updatedCards;
  final int? matchedPairId;

  const MatchResult({
    required this.matched,
    required this.updatedCards,
    this.matchedPairId,
  });
}

/// Validation result for match attempt
class MatchValidation {
  final bool isValid;
  final String? errorMessage;

  const MatchValidation({
    required this.isValid,
    this.errorMessage,
  });
}

/// Validation result for pair integrity
class PairIntegrity {
  final bool isValid;
  final int totalPairs;
  final List<int> invalidPairs;
  final List<int> incompletePairs;

  const PairIntegrity({
    required this.isValid,
    required this.totalPairs,
    required this.invalidPairs,
    required this.incompletePairs,
  });

  String? get errorMessage {
    if (isValid) return null;

    final errors = <String>[];
    if (invalidPairs.isNotEmpty) {
      errors.add('Invalid pairs: ${invalidPairs.join(', ')}');
    }
    if (incompletePairs.isNotEmpty) {
      errors.add('Incomplete pairs: ${incompletePairs.join(', ')}');
    }
    return errors.join('; ');
  }
}

/// Statistics about matches
class MatchStatistics {
  final int matchedPairs;
  final int totalPairs;
  final int remainingPairs;
  final int totalMoves;
  final double matchRate;
  final bool perfectMatchRate;
  final double completionPercentage;

  const MatchStatistics({
    required this.matchedPairs,
    required this.totalPairs,
    required this.remainingPairs,
    required this.totalMoves,
    required this.matchRate,
    required this.perfectMatchRate,
    required this.completionPercentage,
  });

  /// Gets efficiency rating (0-100)
  double get efficiency {
    if (totalMoves == 0) return 0.0;
    final idealMoves = totalPairs;
    return (idealMoves / totalMoves * 100).clamp(0.0, 100.0);
  }
}

/// Status of a specific pair
class PairStatus {
  final int pairId;
  final bool matched;
  final bool revealed;
  final int cardCount;

  const PairStatus({
    required this.pairId,
    required this.matched,
    required this.revealed,
    required this.cardCount,
  });

  bool get isComplete => cardCount == 2;
  bool get isHidden => !matched && !revealed;
}
