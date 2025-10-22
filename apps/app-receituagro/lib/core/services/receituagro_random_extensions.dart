import 'package:core/core.dart';

import '../data/models/fitossanitario_hive.dart';

/// App-specific extensions for RandomSelectionService
/// Provides domain-specific logic for app-receituagro
extension ReceitaAgroRandomExtensions on RandomSelectionService {
  /// Select newest defensivos based on createdAt timestamp
  ///
  /// Orders defensivos by createdAt in descending order (newest first)
  /// Falls back to random selection if no defensivos have valid createdAt
  static List<FitossanitarioHive> selectNewDefensivos(
    List<FitossanitarioHive> defensivos, {
    int count = 5,
  }) {
    return RandomSelectionService.selectNewest<FitossanitarioHive>(
      defensivos,
      timestampExtractor: (d) => d.createdAt ?? 0,
      count: count,
    );
  }

  /// Select random defensivos
  /// Convenience wrapper for domain clarity
  static List<FitossanitarioHive> selectRandomDefensivos(
    List<FitossanitarioHive> defensivos, {
    int count = 5,
  }) {
    return RandomSelectionService.selectRandom<FitossanitarioHive>(
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
