import 'dart:math';

import '../entities/enums.dart';
import '../entities/letter_entity.dart';

/// Service responsible for hint management
///
/// Handles:
/// - Random letter selection for hints
/// - Hint availability checking
/// - Strategic hint selection
/// - Hint statistics
class HintManagerService {
  final Random _random;

  HintManagerService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Hint Availability
  // ============================================================================

  /// Checks if hints are available
  bool canUseHint({
    required int hintsUsed,
    required int maxHints,
    required int pendingLetters,
  }) {
    return hintsUsed < maxHints && pendingLetters > 0;
  }

  /// Gets remaining hints count
  int getRemainingHints({
    required int hintsUsed,
    required int maxHints,
  }) {
    return (maxHints - hintsUsed).clamp(0, maxHints);
  }

  /// Validates hint can be used
  HintValidation validateHintUsage({
    required int hintsUsed,
    required int maxHints,
    required int pendingLetters,
  }) {
    final errors = <String>[];

    if (hintsUsed >= maxHints) {
      errors.add('Sem dicas disponíveis');
    }

    if (pendingLetters == 0) {
      errors.add('Não há letras para revelar');
    }

    return HintValidation(
      canUse: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Random Hint Selection
  // ============================================================================

  /// Gets all pending (unrevealed) letter indices
  List<int> getPendingLetterIndices(List<LetterEntity> letters) {
    final pendingIndices = <int>[];

    for (int i = 0; i < letters.length; i++) {
      if (!letters[i].isRevealed) {
        pendingIndices.add(i);
      }
    }

    return pendingIndices;
  }

  /// Selects random pending letter index
  int selectRandomHintIndex(List<LetterEntity> letters) {
    final pendingIndices = getPendingLetterIndices(letters);

    if (pendingIndices.isEmpty) {
      return -1;
    }

    return pendingIndices[_random.nextInt(pendingIndices.length)];
  }

  /// Gets hint selection result
  HintSelection getHintSelection(List<LetterEntity> letters) {
    final pendingIndices = getPendingLetterIndices(letters);

    if (pendingIndices.isEmpty) {
      return const HintSelection(
        success: false,
        selectedIndex: -1,
        selectedLetter: null,
        pendingCount: 0,
      );
    }

    final selectedIndex =
        pendingIndices[_random.nextInt(pendingIndices.length)];
    final selectedLetter = letters[selectedIndex].letter;

    return HintSelection(
      success: true,
      selectedIndex: selectedIndex,
      selectedLetter: selectedLetter,
      pendingCount: pendingIndices.length,
    );
  }

  // ============================================================================
  // Strategic Hint Selection
  // ============================================================================

  /// Selects hint strategically (e.g., vowels first, common letters)
  HintSelection getStrategicHintSelection({
    required List<LetterEntity> letters,
    required String word,
  }) {
    final pendingIndices = getPendingLetterIndices(letters);

    if (pendingIndices.isEmpty) {
      return const HintSelection(
        success: false,
        selectedIndex: -1,
        selectedLetter: null,
        pendingCount: 0,
      );
    }

    // Priority: vowels first
    final vowels = {
      'A',
      'E',
      'I',
      'O',
      'U',
      'Á',
      'À',
      'Â',
      'Ã',
      'É',
      'Ê',
      'Í',
      'Ó',
      'Ô',
      'Õ',
      'Ú'
    };
    final vowelIndices = pendingIndices
        .where((i) => vowels.contains(letters[i].letter))
        .toList();

    int selectedIndex;
    if (vowelIndices.isNotEmpty) {
      selectedIndex = vowelIndices[_random.nextInt(vowelIndices.length)];
    } else {
      selectedIndex = pendingIndices[_random.nextInt(pendingIndices.length)];
    }

    return HintSelection(
      success: true,
      selectedIndex: selectedIndex,
      selectedLetter: letters[selectedIndex].letter,
      pendingCount: pendingIndices.length,
    );
  }

  /// Selects hint at specific position (if unrevealed)
  HintSelection selectHintAtPosition({
    required List<LetterEntity> letters,
    required int position,
  }) {
    if (position < 0 || position >= letters.length) {
      return const HintSelection(
        success: false,
        selectedIndex: -1,
        selectedLetter: null,
        pendingCount: 0,
      );
    }

    if (letters[position].isRevealed) {
      return HintSelection(
        success: false,
        selectedIndex: position,
        selectedLetter: letters[position].letter,
        pendingCount: getPendingLetterIndices(letters).length,
      );
    }

    return HintSelection(
      success: true,
      selectedIndex: position,
      selectedLetter: letters[position].letter,
      pendingCount: getPendingLetterIndices(letters).length,
    );
  }

  // ============================================================================
  // Hint Application
  // ============================================================================

  /// Reveals letter at selected index
  List<LetterEntity> revealHintLetter({
    required List<LetterEntity> currentLetters,
    required int hintIndex,
  }) {
    if (hintIndex < 0 || hintIndex >= currentLetters.length) {
      return currentLetters;
    }

    final updatedLetters = List<LetterEntity>.from(currentLetters);
    updatedLetters[hintIndex] = updatedLetters[hintIndex].copyWith(
      state: LetterState.revealed,
    );

    return updatedLetters;
  }

  /// Gets letter revealed by hint
  String? getRevealedLetter({
    required List<LetterEntity> letters,
    required int hintIndex,
  }) {
    if (hintIndex < 0 || hintIndex >= letters.length) {
      return null;
    }

    return letters[hintIndex].letter;
  }

  // ============================================================================
  // Hint Cost/Benefit
  // ============================================================================

  /// Calculates hint value (how much it helps)
  HintValue calculateHintValue({
    required int pendingLetters,
    required int totalLetters,
  }) {
    final progress = 1.0 - (pendingLetters / totalLetters);

    if (progress < 0.25) {
      return HintValue.veryHelpful;
    } else if (progress < 0.50) {
      return HintValue.helpful;
    } else if (progress < 0.75) {
      return HintValue.moderate;
    } else {
      return HintValue.minimal;
    }
  }

  /// Checks if should use hint (based on remaining time and mistakes)
  bool shouldUseHint({
    required int timeRemaining,
    required int totalTime,
    required int mistakes,
    required int maxMistakes,
  }) {
    final timePercentage = timeRemaining / totalTime;
    final mistakePercentage = mistakes / maxMistakes;

    // Use hint if time is low (< 30%) or mistakes are high (> 50%)
    return timePercentage < 0.3 || mistakePercentage > 0.5;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets hint statistics
  HintStatistics getStatistics({
    required int hintsUsed,
    required int maxHints,
    required int pendingLetters,
    required int totalLetters,
  }) {
    final remaining =
        getRemainingHints(hintsUsed: hintsUsed, maxHints: maxHints);
    final usagePercentage = maxHints > 0 ? (hintsUsed / maxHints) : 0.0;
    final value = calculateHintValue(
      pendingLetters: pendingLetters,
      totalLetters: totalLetters,
    );

    return HintStatistics(
      hintsUsed: hintsUsed,
      maxHints: maxHints,
      hintsRemaining: remaining,
      usagePercentage: usagePercentage,
      pendingLetters: pendingLetters,
      hintValue: value,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Hint validation result
class HintValidation {
  final bool canUse;
  final List<String> errors;

  const HintValidation({
    required this.canUse,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}

/// Hint selection result
class HintSelection {
  final bool success;
  final int selectedIndex;
  final String? selectedLetter;
  final int pendingCount;

  const HintSelection({
    required this.success,
    required this.selectedIndex,
    required this.selectedLetter,
    required this.pendingCount,
  });

  /// Gets message about selection
  String get message {
    if (!success) {
      return 'Não foi possível selecionar dica';
    }
    return 'Letra "$selectedLetter" revelada na posição ${selectedIndex + 1}';
  }
}

/// Hint value classification
enum HintValue {
  veryHelpful,
  helpful,
  moderate,
  minimal;

  String get label {
    switch (this) {
      case HintValue.veryHelpful:
        return 'Muito Útil';
      case HintValue.helpful:
        return 'Útil';
      case HintValue.moderate:
        return 'Moderado';
      case HintValue.minimal:
        return 'Mínimo';
    }
  }

  String get emoji {
    switch (this) {
      case HintValue.veryHelpful:
        return '💡';
      case HintValue.helpful:
        return '✨';
      case HintValue.moderate:
        return '⭐';
      case HintValue.minimal:
        return '💫';
    }
  }
}

/// Hint statistics
class HintStatistics {
  final int hintsUsed;
  final int maxHints;
  final int hintsRemaining;
  final double usagePercentage;
  final int pendingLetters;
  final HintValue hintValue;

  const HintStatistics({
    required this.hintsUsed,
    required this.maxHints,
    required this.hintsRemaining,
    required this.usagePercentage,
    required this.pendingLetters,
    required this.hintValue,
  });

  /// Checks if all hints used
  bool get allHintsUsed => hintsRemaining == 0;

  /// Checks if no hints used yet
  bool get noHintsUsed => hintsUsed == 0;

  /// Gets usage percentage as display value
  double get usagePercentageDisplay => usagePercentage * 100;
}
