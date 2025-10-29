import 'dart:convert';

import 'package:core/core.dart';

import '../models/models.dart';

/// Local data source for onboarding persistence
/// Handles CRUD operations with persistent storage (Hive/LocalStorage)
class OnboardingLocalDataSource {
  final ILocalStorageRepository _localStorage;

  // Storage keys
  static const String _progressKey = 'receituagro_onboarding_progress';
  static const String _tooltipsKey = 'receituagro_shown_tooltips';

  OnboardingLocalDataSource(this._localStorage);

  // ==================== Progress CRUD ====================

  /// Load user's onboarding progress from storage
  /// Returns null if no progress found
  Future<OnboardingProgressModel?> getProgress() async {
    final result = await _localStorage.get<String>(
      key: _progressKey,
    );

    return result.fold(
      // If loading failed or key not found, return null
      (failure) => null,
      // If successful, deserialize JSON
      (data) {
        if (data == null) return null;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          return OnboardingProgressModel.fromJson(json);
        } catch (e) {
          // Return null if deserialization fails
          return null;
        }
      },
    );
  }

  /// Save user's onboarding progress to storage
  Future<void> saveProgress(OnboardingProgressModel progress) async {
    final json = progress.toJson();
    final data = jsonEncode(json);

    await _localStorage.save<String>(
      key: _progressKey,
      data: data,
    );
  }

  /// Delete onboarding progress from storage
  Future<void> deleteProgress() async {
    await _localStorage.remove(key: _progressKey);
  }

  // ==================== Tooltip State CRUD ====================

  /// Load set of shown tooltips from storage
  /// Returns empty set if none found
  Future<Set<String>> getShownTooltips() async {
    final result = await _localStorage.get<String>(
      key: _tooltipsKey,
    );

    return result.fold(
      // If loading failed or key not found, return empty set
      (failure) => <String>{},
      // If successful, deserialize JSON list
      (data) {
        if (data == null) return <String>{};
        try {
          final list = jsonDecode(data) as List<dynamic>;
          return list.cast<String>().toSet();
        } catch (e) {
          // Return empty set if deserialization fails
          return <String>{};
        }
      },
    );
  }

  /// Add tooltip ID to shown tooltips set and persist
  Future<void> markTooltipShown(String tooltipId) async {
    final shownTooltips = await getShownTooltips();
    shownTooltips.add(tooltipId);

    final data = jsonEncode(shownTooltips.toList());
    await _localStorage.save<String>(
      key: _tooltipsKey,
      data: data,
    );
  }

  /// Clear all shown tooltips from storage
  Future<void> clearShownTooltips() async {
    await _localStorage.remove(key: _tooltipsKey);
  }
}
