import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/card_entity.dart';
import '../entities/enums.dart';
import '../entities/deck_configuration.dart';

/// Service responsible for generating memory game cards
class CardGeneratorService {
  final Random _random;

  CardGeneratorService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Generates a complete set of cards for given difficulty and optional deck config
  List<CardEntity> generateCards(GameDifficulty difficulty, {DeckConfiguration? deckConfig}) {
    final totalPairs = difficulty.totalPairs;
    final List<CardEntity> cards = [];

    // Generate pairs
    for (int i = 0; i < totalPairs; i++) {
      if (deckConfig != null) {
        final pair = createSpritePair(i, deckConfig);
        cards.addAll(pair);
      } else {
        final theme = selectTheme(i);
        final pair = createPair(
          pairId: i,
          color: theme.color,
          icon: theme.icon,
        );
        cards.addAll(pair);
      }
    }

    // Shuffle cards
    final shuffledCards = shuffleCards(cards);

    // Assign positions
    return assignPositions(shuffledCards);
  }

  /// Creates a pair of cards using Sprite Sheet
  List<CardEntity> createSpritePair(int pairId, DeckConfiguration config) {
    // Calculate sprite position in grid
    // If we need more pairs than available sprites, wrap around
    final spriteIndex = pairId % config.totalSprites;
    
    final col = spriteIndex % config.columns;
    final row = spriteIndex ~/ config.columns;
    
    final sourceRect = Rect.fromLTWH(
      col * config.spriteWidth.toDouble(),
      row * config.spriteHeight.toDouble(),
      config.spriteWidth.toDouble(),
      config.spriteHeight.toDouble(),
    );

    return [
      CardEntity(
        id: 'card_${pairId * 2}',
        pairId: pairId,
        color: Colors.white, // Default base color
        icon: null,
        spriteAsset: config.assetPath,
        spriteSource: sourceRect,
        position: pairId * 2,
      ),
      CardEntity(
        id: 'card_${pairId * 2 + 1}',
        pairId: pairId,
        color: Colors.white,
        icon: null,
        spriteAsset: config.assetPath,
        spriteSource: sourceRect,
        position: pairId * 2 + 1,
      ),
    ];
  }

  /// Creates a pair of matching cards (Standard Icon Mode)
  List<CardEntity> createPair({
    required int pairId,
    required Color color,
    required IconData icon,
  }) {
    return [
      CardEntity(
        id: 'card_${pairId * 2}',
        pairId: pairId,
        color: color,
        icon: icon,
        position: pairId * 2,
      ),
      CardEntity(
        id: 'card_${pairId * 2 + 1}',
        pairId: pairId,
        color: color,
        icon: icon,
        position: pairId * 2 + 1,
      ),
    ];
  }

  /// Shuffles cards using Fisher-Yates algorithm
  List<CardEntity> shuffleCards(List<CardEntity> cards) {
    final shuffled = List<CardEntity>.from(cards);
    shuffled.shuffle(_random);
    return shuffled;
  }

  /// Assigns sequential positions to cards
  List<CardEntity> assignPositions(List<CardEntity> cards) {
    return List.generate(
      cards.length,
      (index) => cards[index].copyWith(position: index),
    );
  }

  // ============================================================================
  // Theme Selection
  // ============================================================================

  /// Selects theme (color + icon) for a card pair
  CardTheme selectTheme(int pairIndex) {
    final colorIndex = pairIndex % CardThemes.cardColors.length;
    final iconIndex = pairIndex % CardThemes.cardIcons.length;

    return CardTheme(
      color: CardThemes.cardColors[colorIndex],
      icon: CardThemes.cardIcons[iconIndex],
    );
  }

  /// Selects random theme from available themes
  CardTheme selectRandomTheme() {
    final colorIndex = _random.nextInt(CardThemes.cardColors.length);
    final iconIndex = _random.nextInt(CardThemes.cardIcons.length);

    return CardTheme(
      color: CardThemes.cardColors[colorIndex],
      icon: CardThemes.cardIcons[iconIndex],
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates card generation configuration
  GenerationValidation validateGeneration(GameDifficulty difficulty) {
    final totalPairs = difficulty.totalPairs;
    final availableColors = CardThemes.cardColors.length;
    final availableIcons = CardThemes.cardIcons.length;

    final hasEnoughThemes =
        totalPairs <= availableColors && totalPairs <= availableIcons;

    return GenerationValidation(
      isValid: hasEnoughThemes,
      requiredPairs: totalPairs,
      availableColors: availableColors,
      availableIcons: availableIcons,
      errorMessage: hasEnoughThemes
          ? null
          : 'Not enough themes: need $totalPairs pairs, have $availableColors colors and $availableIcons icons',
    );
  }

  /// Validates that generated cards form valid pairs
  PairValidation validatePairs(List<CardEntity> cards) {
    final pairMap = <int, List<CardEntity>>{};

    // Group cards by pairId
    for (final card in cards) {
      pairMap.putIfAbsent(card.pairId, () => []).add(card);
    }

    // Check each pair
    final invalidPairs = <int>[];
    for (final entry in pairMap.entries) {
      if (entry.value.length != 2) {
        invalidPairs.add(entry.key);
      } else {
        final card1 = entry.value[0];
        final card2 = entry.value[1];
        if (card1.color != card2.color || card1.icon != card2.icon) {
          invalidPairs.add(entry.key);
        }
      }
    }

    return PairValidation(
      isValid: invalidPairs.isEmpty,
      totalPairs: pairMap.length,
      invalidPairs: invalidPairs,
      errorMessage: invalidPairs.isEmpty
          ? null
          : 'Invalid pairs found: ${invalidPairs.join(', ')}',
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets generation statistics
  GenerationStatistics getStatistics(List<CardEntity> cards) {
    final uniquePairIds = cards.map((c) => c.pairId).toSet();
    final uniqueColors = cards.map((c) => c.color).toSet();
    final uniqueIcons = cards.map((c) => c.icon).toSet();

    return GenerationStatistics(
      totalCards: cards.length,
      totalPairs: uniquePairIds.length,
      uniqueColors: uniqueColors.length,
      uniqueIcons: uniqueIcons.length,
      averageCardsPerPair: cards.length / uniquePairIds.length,
    );
  }

  /// Gets theme usage statistics
  ThemeUsageStats getThemeUsage(List<CardEntity> cards) {
    final colorUsage = <Color, int>{};
    final iconUsage = <IconData, int>{};

    for (final card in cards) {
      colorUsage[card.color] = (colorUsage[card.color] ?? 0) + 1;
      iconUsage[card.icon] = (iconUsage[card.icon] ?? 0) + 1;
    }

    return ThemeUsageStats(
      colorUsage: colorUsage,
      iconUsage: iconUsage,
      mostUsedColor: _findMostUsed(colorUsage),
      mostUsedIcon: _findMostUsed(iconUsage),
    );
  }

  T _findMostUsed<T>(Map<T, int> usage) {
    return usage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if difficulty is supported
  bool isSupportedDifficulty(GameDifficulty difficulty) {
    final totalPairs = difficulty.totalPairs;
    return totalPairs <= CardThemes.cardColors.length &&
        totalPairs <= CardThemes.cardIcons.length;
  }

  /// Gets maximum supported difficulty
  GameDifficulty getMaxSupportedDifficulty() {
    final maxPairs = min(
      CardThemes.cardColors.length,
      CardThemes.cardIcons.length,
    );

    // Calculate grid size from maxPairs (totalCards = maxPairs * 2)
    final totalCards = maxPairs * 2;
    final gridSize = sqrt(totalCards).floor();

    // Return highest difficulty that fits
    for (final difficulty in GameDifficulty.values.reversed) {
      if (difficulty.gridSize <= gridSize) {
        return difficulty;
      }
    }

    return GameDifficulty.easy;
  }

  // ============================================================================
  // Testing Utilities
  // ============================================================================

  /// Creates cards with specific configuration for testing
  List<CardEntity> generateWithConfig(GenerationConfig config) {
    final cards = <CardEntity>[];

    for (int i = 0; i < config.pairCount; i++) {
      final theme =
          config.forcedThemes != null && i < config.forcedThemes!.length
              ? config.forcedThemes![i]
              : selectTheme(i);

      cards.addAll(createPair(
        pairId: i,
        color: theme.color,
        icon: theme.icon,
      ));
    }

    if (!config.skipShuffle) {
      return assignPositions(shuffleCards(cards));
    }

    return assignPositions(cards);
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Theme configuration for a card pair
class CardTheme {
  final Color color;
  final IconData icon;

  const CardTheme({
    required this.color,
    required this.icon,
  });
}

/// Validation result for card generation
class GenerationValidation {
  final bool isValid;
  final int requiredPairs;
  final int availableColors;
  final int availableIcons;
  final String? errorMessage;

  const GenerationValidation({
    required this.isValid,
    required this.requiredPairs,
    required this.availableColors,
    required this.availableIcons,
    this.errorMessage,
  });
}

/// Validation result for card pairs
class PairValidation {
  final bool isValid;
  final int totalPairs;
  final List<int> invalidPairs;
  final String? errorMessage;

  const PairValidation({
    required this.isValid,
    required this.totalPairs,
    required this.invalidPairs,
    this.errorMessage,
  });
}

/// Statistics about generated cards
class GenerationStatistics {
  final int totalCards;
  final int totalPairs;
  final int uniqueColors;
  final int uniqueIcons;
  final double averageCardsPerPair;

  const GenerationStatistics({
    required this.totalCards,
    required this.totalPairs,
    required this.uniqueColors,
    required this.uniqueIcons,
    required this.averageCardsPerPair,
  });
}

/// Statistics about theme usage
class ThemeUsageStats {
  final Map<Color, int> colorUsage;
  final Map<IconData, int> iconUsage;
  final Color mostUsedColor;
  final IconData mostUsedIcon;

  const ThemeUsageStats({
    required this.colorUsage,
    required this.iconUsage,
    required this.mostUsedColor,
    required this.mostUsedIcon,
  });
}

/// Configuration for deterministic card generation (testing)
class GenerationConfig {
  final int pairCount;
  final List<CardTheme>? forcedThemes;
  final bool skipShuffle;

  const GenerationConfig({
    required this.pairCount,
    this.forcedThemes,
    this.skipShuffle = false,
  });
}
