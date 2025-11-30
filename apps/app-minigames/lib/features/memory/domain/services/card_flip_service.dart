import '../entities/card_entity.dart';
import '../entities/enums.dart';

/// Service responsible for card flipping validation and state management
///
/// Handles:
/// - Flip validation rules
/// - Card state transitions
/// - Flip constraints
/// - Game state validation
class CardFlipService {
  // ============================================================================
  // Constants
  // ============================================================================

  /// Maximum number of cards that can be flipped simultaneously
  static const int maxFlippedCards = 2;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Validates if a card can be flipped
  ///
  /// Returns validation result with detailed error if invalid
  FlipValidation canFlipCard({
    required CardEntity card,
    required List<CardEntity> currentFlippedCards,
    required GameStatus gameStatus,
  }) {
    // Check game status
    if (!gameStatus.canInteract) {
      return const FlipValidation(
        canFlip: false,
        reason: FlipDeniedReason.gameNotPlaying,
        errorMessage: 'Cannot flip card when game is not playing',
      );
    }

    // Check if already at max flipped cards
    if (currentFlippedCards.length >= maxFlippedCards) {
      return const FlipValidation(
        canFlip: false,
        reason: FlipDeniedReason.tooManyFlipped,
        errorMessage: 'Maximum $maxFlippedCards cards can be flipped at once',
      );
    }

    // Check if card is already flipped
    if (card.isFlipped) {
      return const FlipValidation(
        canFlip: false,
        reason: FlipDeniedReason.alreadyFlipped,
        errorMessage: 'Card is already flipped',
      );
    }

    // Check if card is already matched
    if (card.isMatched) {
      return const FlipValidation(
        canFlip: false,
        reason: FlipDeniedReason.alreadyMatched,
        errorMessage: 'Card is already matched',
      );
    }

    // Check if card is already in flipped list
    if (currentFlippedCards.any((c) => c.id == card.id)) {
      return const FlipValidation(
        canFlip: false,
        reason: FlipDeniedReason.duplicateInFlippedList,
        errorMessage: 'Card is already in flipped list',
      );
    }

    // All checks passed
    return const FlipValidation(canFlip: true);
  }

  /// Validates card ID before attempting flip
  CardIdValidation validateCardId(String cardId) {
    if (cardId.trim().isEmpty) {
      return const CardIdValidation(
        isValid: false,
        errorMessage: 'Card ID cannot be empty',
      );
    }

    // Check if ID follows expected format (optional but helpful)
    if (!cardId.startsWith('card_')) {
      return CardIdValidation(
        isValid: false,
        errorMessage: 'Invalid card ID format: $cardId',
      );
    }

    return const CardIdValidation(isValid: true);
  }

  /// Flips a card by updating its state
  CardEntity flipCard(CardEntity card) {
    return card.copyWith(state: CardState.revealed);
  }

  /// Unflips a card by returning it to hidden state
  CardEntity unflipCard(CardEntity card) {
    return card.copyWith(state: CardState.hidden);
  }

  // ============================================================================
  // Batch Operations
  // ============================================================================

  /// Updates card in list after flip
  List<CardEntity> updateCardAfterFlip({
    required List<CardEntity> allCards,
    required CardEntity flippedCard,
  }) {
    return allCards.map((card) {
      return card.id == flippedCard.id ? flippedCard : card;
    }).toList();
  }

  /// Unflips all specified cards
  List<CardEntity> unflipCards({
    required List<CardEntity> allCards,
    required List<CardEntity> cardsToUnflip,
  }) {
    final idsToUnflip = cardsToUnflip.map((c) => c.id).toSet();

    return allCards.map((card) {
      if (idsToUnflip.contains(card.id) && card.state == CardState.revealed) {
        return card.copyWith(state: CardState.hidden);
      }
      return card;
    }).toList();
  }

  /// Resets all revealed (but not matched) cards to hidden
  List<CardEntity> resetRevealedCards(List<CardEntity> cards) {
    return cards.map((card) {
      if (card.state == CardState.revealed) {
        return card.copyWith(state: CardState.hidden);
      }
      return card;
    }).toList();
  }

  // ============================================================================
  // Query Methods
  // ============================================================================

  /// Gets all currently flipped (revealed) cards
  List<CardEntity> getFlippedCards(List<CardEntity> cards) {
    return cards.where((card) => card.state == CardState.revealed).toList();
  }

  /// Gets all hidden cards
  List<CardEntity> getHiddenCards(List<CardEntity> cards) {
    return cards.where((card) => card.state == CardState.hidden).toList();
  }

  /// Checks if any cards are currently flipped
  bool hasFlippedCards(List<CardEntity> cards) {
    return cards.any((card) => card.state == CardState.revealed);
  }

  /// Checks if maximum cards are flipped
  bool hasMaxFlippedCards(List<CardEntity> flippedCards) {
    return flippedCards.length >= maxFlippedCards;
  }

  /// Finds card by ID
  CardEntity? findCardById(List<CardEntity> cards, String cardId) {
    try {
      return cards.firstWhere((card) => card.id == cardId);
    } catch (_) {
      return null;
    }
  }

  // ============================================================================
  // State Validation
  // ============================================================================

  /// Validates overall game state for flipping
  GameStateValidation validateGameState({
    required List<CardEntity> cards,
    required List<CardEntity> flippedCards,
    required GameStatus status,
  }) {
    final errors = <String>[];

    // Check game status
    if (!status.canInteract) {
      errors.add('Game status does not allow interaction: $status');
    }

    // Check flipped cards count
    if (flippedCards.length > maxFlippedCards) {
      errors.add(
          'Too many flipped cards: ${flippedCards.length} (max: $maxFlippedCards)');
    }

    // Check flipped cards exist in main card list
    final cardIds = cards.map((c) => c.id).toSet();
    for (final flipped in flippedCards) {
      if (!cardIds.contains(flipped.id)) {
        errors.add('Flipped card ${flipped.id} not found in main card list');
      }
    }

    // Check for duplicate flipped cards
    final flippedIds = flippedCards.map((c) => c.id).toList();
    if (flippedIds.length != flippedIds.toSet().length) {
      errors.add('Duplicate cards in flipped list');
    }

    return GameStateValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates card state consistency
  CardStateConsistency validateCardStateConsistency(List<CardEntity> cards) {
    final issues = <String>[];
    final stateCount = <CardState, int>{};

    // Count states
    for (final card in cards) {
      stateCount[card.state] = (stateCount[card.state] ?? 0) + 1;
    }

    // Check for too many revealed
    final revealedCount = stateCount[CardState.revealed] ?? 0;
    if (revealedCount > maxFlippedCards) {
      issues.add(
          'Too many revealed cards: $revealedCount (max: $maxFlippedCards)');
    }

    return CardStateConsistency(
      isConsistent: issues.isEmpty,
      stateCount: stateCount,
      issues: issues,
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets flip statistics
  FlipStatistics getStatistics(List<CardEntity> cards) {
    final hiddenCount = cards.where((c) => c.state == CardState.hidden).length;
    final revealedCount =
        cards.where((c) => c.state == CardState.revealed).length;
    final matchedCount =
        cards.where((c) => c.state == CardState.matched).length;

    return FlipStatistics(
      totalCards: cards.length,
      hiddenCards: hiddenCount,
      revealedCards: revealedCount,
      matchedCards: matchedCount,
      flippableCards: hiddenCount,
      revealedPercentage: (revealedCount / cards.length * 100),
      matchedPercentage: (matchedCount / cards.length * 100),
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if card can be interacted with
  bool isCardInteractable(CardEntity card) {
    return !card.isFlipped && !card.isMatched;
  }

  /// Gets count of interactable cards
  int getInteractableCardCount(List<CardEntity> cards) {
    return cards.where((card) => isCardInteractable(card)).length;
  }

  /// Checks if flip limit is reached
  bool isFlipLimitReached(List<CardEntity> flippedCards) {
    return flippedCards.length >= maxFlippedCards;
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Validation result for flip attempt
class FlipValidation {
  final bool canFlip;
  final FlipDeniedReason? reason;
  final String? errorMessage;

  const FlipValidation({
    required this.canFlip,
    this.reason,
    this.errorMessage,
  });
}

/// Reasons why a flip might be denied
enum FlipDeniedReason {
  gameNotPlaying,
  tooManyFlipped,
  alreadyFlipped,
  alreadyMatched,
  duplicateInFlippedList,
  invalidCardId,
}

/// Validation result for card ID
class CardIdValidation {
  final bool isValid;
  final String? errorMessage;

  const CardIdValidation({
    required this.isValid,
    this.errorMessage,
  });
}

/// Validation result for overall game state
class GameStateValidation {
  final bool isValid;
  final List<String> errors;

  const GameStateValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Validation result for card state consistency
class CardStateConsistency {
  final bool isConsistent;
  final Map<CardState, int> stateCount;
  final List<String> issues;

  const CardStateConsistency({
    required this.isConsistent,
    required this.stateCount,
    required this.issues,
  });

  String? get issueMessage => issues.isEmpty ? null : issues.join('; ');
}

/// Statistics about card flipping
class FlipStatistics {
  final int totalCards;
  final int hiddenCards;
  final int revealedCards;
  final int matchedCards;
  final int flippableCards;
  final double revealedPercentage;
  final double matchedPercentage;

  const FlipStatistics({
    required this.totalCards,
    required this.hiddenCards,
    required this.revealedCards,
    required this.matchedCards,
    required this.flippableCards,
    required this.revealedPercentage,
    required this.matchedPercentage,
  });

  /// Gets hidden percentage
  double get hiddenPercentage => (hiddenCards / totalCards * 100);

  /// Checks if game is just starting
  bool get isEarlyGame => matchedPercentage < 25;

  /// Checks if game is near end
  bool get isLateGame => matchedPercentage > 75;
}
