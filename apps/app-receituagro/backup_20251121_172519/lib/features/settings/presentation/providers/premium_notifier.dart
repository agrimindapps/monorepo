import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/premium_settings_entity.dart';

part 'premium_notifier.g.dart';

/// State class for premium settings
class PremiumState {
  final PremiumSettingsEntity settings;
  final bool isLoading;
  final String? error;

  const PremiumState({
    required this.settings,
    required this.isLoading,
    this.error,
  });

  factory PremiumState.initial() {
    return PremiumState(
      settings: PremiumSettingsEntity.defaults(),
      isLoading: false,
      error: null,
    );
  }

  PremiumState copyWith({
    PremiumSettingsEntity? settings,
    bool? isLoading,
    String? error,
  }) {
    return PremiumState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  PremiumState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier for managing premium and feature-related user settings
/// Handles premium status, development mode, and analytics preferences
///
/// Responsibilities:
/// - Track premium subscription status
/// - Manage development/debug mode
/// - Control analytics consent
/// - Check feature access
/// - Get available features list
/// - Load/save premium settings
/// - Validate premium configuration
/// - Persist to storage
///
/// State: PremiumState
/// - settings: Current PremiumSettingsEntity
/// - isLoading: Whether operations are in progress
/// - error: Error message if any
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  @override
  PremiumState build() => PremiumState.initial();

  /// Enables or disables development mode
  ///
  /// Development mode provides:
  /// - Debug panel access
  /// - Feature flags control
  /// - Performance monitoring
  /// - Data inspector
  ///
  /// Important: Should NEVER be enabled in production
  Future<void> setDevelopmentMode(bool enabled) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(isDevelopmentMode: enabled);

      // TODO: Persist to storage
      // await _persistPremiumSettings(updated);

      // Log development mode changes
      if (enabled) {
        debugPrint('⚠️  Development Mode ENABLED');
      } else {
        debugPrint('✅ Development Mode DISABLED');
      }

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error setting development mode: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao alternar modo desenvolvimento',
      );
    }
  }

  /// Toggles analytics consent
  ///
  /// When enabled:
  /// - Analytics events are sent
  /// - Usage data collected
  /// - Performance metrics tracked
  ///
  /// When disabled:
  /// - No analytics sent
  /// - Privacy maintained
  /// - Complies with privacy preferences
  Future<void> toggleAnalytics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(
        analyticsEnabled: !state.settings.analyticsEnabled,
      );

      // TODO: Persist to storage and notify analytics service
      // await _persistPremiumSettings(updated);
      // await _analyticsService.updateConsent(updated.analyticsEnabled);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling analytics: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao alternar analytics',
      );
    }
  }

  /// Updates premium subscription status
  ///
  /// Typically called when:
  /// - User purchases subscription
  /// - Subscription expires
  /// - Subscription is renewed
  /// - Subscription is cancelled
  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(hasPremiumFeatures: isPremium);

      // TODO: Persist to storage
      // await _persistPremiumSettings(updated);

      if (isPremium) {
        debugPrint('🎉 Premium Status ACTIVATED');
      } else {
        debugPrint('⏸️  Premium Status DEACTIVATED');
      }

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error updating premium status: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao atualizar status premium',
      );
    }
  }

  /// Loads premium settings from storage or backend
  /// Useful for app initialization
  Future<void> loadPremiumSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Load from storage or check subscription status
      // final result = await _subscriptionRepository.getPremiumStatus();
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   ),
      //   (isPremium) => state = state.copyWith(
      //     settings: state.settings.copyWith(hasPremiumFeatures: isPremium),
      //     isLoading: false,
      //   ),
      // );

      // For now, use defaults
      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      debugPrint('Error loading premium settings: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações premium',
      );
    }
  }

  /// Checks if user has access to a specific feature
  ///
  /// Returns true if:
  /// - Feature is basic/free AND user is logged in
  /// - Feature is premium AND user has active subscription
  /// - User is in development mode
  Future<bool> checkFeatureAccess(String featureKey) async {
    return state.settings.hasFeatureAccess(featureKey);
  }

  /// Resets premium settings to defaults
  /// Warning: This will disable all premium features
  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final defaults = PremiumSettingsEntity.defaults();

      // TODO: Persist to storage
      // await _persistPremiumSettings(defaults);

      state = state.copyWith(settings: defaults, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error resetting to defaults: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao redefinir padrões',
      );
    }
  }

  // Getters for easy access

  /// Get current premium settings
  PremiumSettingsEntity get currentSettings => state.settings;

  /// Check if user has premium features
  bool get hasPremium => state.settings.hasPremiumFeatures;

  /// Check if development mode is enabled
  bool get isDevelopmentMode => state.settings.isDevelopmentMode;

  /// Check if analytics is enabled
  bool get analyticsEnabled => state.settings.analyticsEnabled;

  /// Get feature tier
  FeatureTier get featureTier => state.settings.featureTier;

  /// Get status description for display
  String get statusDescription => state.settings.statusDescription;

  /// Get list of available features
  List<String> get availableFeatures => state.settings.availableFeatures;

  /// Check if should show premium upsell
  bool get shouldShowUpsell => state.settings.shouldShowUpsell;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.error != null;

  /// Get error message if any
  String? get errorMessage => state.error;
}
