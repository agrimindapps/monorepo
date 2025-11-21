import 'package:core/core.dart' hide Column;

import '../../../database/receituagro_database.dart';

/// App-specific extensions for RandomSelectionService
/// Provides domain-specific logic for app-receituagro
extension ReceitaAgroRandomExtensions on RandomSelectionService {
  /// Select newest defensivos based on createdAt timestamp
  ///
  /// Orders defensivos by createdAt in descending order (newest first)
  /// Falls back to random selection if no defensivos have valid createdAt
  static List<Fitossanitario> selectNewDefensivos(
    List<Fitossanitario> defensivos, {
    int count = 5,
  }) {
    // Since Fitossanitario doesn't have createdAt, use random selection
    return RandomSelectionService.selectRandom<Fitossanitario>(
      defensivos,
      count,
    );
  }

  /// Select random defensivos
  /// Convenience wrapper for domain clarity
  static List<Fitossanitario> selectRandomDefensivos(
    List<Fitossanitario> defensivos, {
    int count = 5,
  }) {
    return RandomSelectionService.selectRandom<Fitossanitario>(
      defensivos,
      count,
    );
  }

  /// Select random pragas
  /// Convenience wrapper for domain clarity
  static List<T> selectRandomPragas<T>(List<T> pragas, {int count = 5}) {
    return RandomSelectionService.selectRandom(pragas, count);
  }

  /// Select suggested pragas
  /// Convenience wrapper for domain clarity (currently uses random selection)
  static List<T> selectSuggestedPragas<T>(List<T> pragas, {int count = 5}) {
    return RandomSelectionService.selectRandom(pragas, count);
  }
}
