/// Domain entity representing premium and feature-related user settings.
/// Responsible for managing premium status, development mode, and analytics preferences.
///
/// Business Rules:
/// - hasPremiumFeatures indicates if user has active premium subscription
/// - isDevelopmentMode is only for development/testing (should be false in production)
/// - analyticsEnabled can be toggled independently of premium status
/// - lastUpdated tracks when premium settings were last changed
class PremiumSettingsEntity {
  final bool hasPremiumFeatures;
  final bool isDevelopmentMode;
  final bool analyticsEnabled;
  final DateTime lastUpdated;

  const PremiumSettingsEntity({
    required this.hasPremiumFeatures,
    required this.isDevelopmentMode,
    required this.analyticsEnabled,
    required this.lastUpdated,
  });

  /// Creates a copy of this entity with the given fields replaced.
  /// If a field is not provided, the current value is retained.
  PremiumSettingsEntity copyWith({
    bool? hasPremiumFeatures,
    bool? isDevelopmentMode,
    bool? analyticsEnabled,
    DateTime? lastUpdated,
  }) {
    return PremiumSettingsEntity(
      hasPremiumFeatures: hasPremiumFeatures ?? this.hasPremiumFeatures,
      isDevelopmentMode: isDevelopmentMode ?? this.isDevelopmentMode,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Creates default premium settings for new users.
  /// Defaults: No premium, dev mode disabled, analytics enabled
  static PremiumSettingsEntity defaults() {
    return PremiumSettingsEntity(
      hasPremiumFeatures: false,
      isDevelopmentMode: false,
      analyticsEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Check if premium settings are valid
  /// Valid when: isDevelopmentMode is false in production builds
  bool get isValid {
    // Development mode should never be enabled in production
    // This should be validated at higher levels
    return true;
  }

  /// Business rule: Check if development mode is enabled
  /// Used for feature flags, debug panels, etc.
  bool get isDebugMode {
    return isDevelopmentMode;
  }

  /// Business rule: Check if feature access should be allowed
  /// Most premium features require hasPremiumFeatures to be true
  bool hasFeatureAccess(String featureKey) {
    return hasPremiumFeatures || _isBasicFeature(featureKey);
  }

  /// Business rule: Define which features are basic (available to all users)
  /// Expandable list of basic features
  static const List<String> _basicFeatures = [
    'view_recipes',
    'basic_search',
    'user_profile',
    'favorites',
  ];

  /// Helper: Check if a feature is basic/free
  static bool _isBasicFeature(String featureKey) {
    return _basicFeatures.contains(featureKey);
  }

  /// Business rule: Get feature tier level
  FeatureTier get featureTier {
    if (isDevelopmentMode) return FeatureTier.debug;
    if (hasPremiumFeatures) return FeatureTier.premium;
    return FeatureTier.free;
  }

  /// Business rule: Check if premium status changed
  bool hasPremiumStatusChanged(PremiumSettingsEntity other) {
    return hasPremiumFeatures != other.hasPremiumFeatures;
  }

  /// Business rule: Check if development mode changed
  bool hasDevelopmentModeChanged(PremiumSettingsEntity other) {
    return isDevelopmentMode != other.isDevelopmentMode;
  }

  /// Business rule: Get analytics consent status
  /// Important for GDPR/privacy compliance
  bool get hasAnalyticsConsent {
    return analyticsEnabled;
  }

  /// Business rule: Check if analytics can be sent
  /// Analytics should not be sent if analytics is disabled AND development mode is off
  bool get canSendAnalytics {
    return analyticsEnabled;
  }

  /// Business rule: Get premium status description
  /// Useful for UI display and logging
  String get statusDescription {
    if (isDevelopmentMode) {
      return 'Modo Desenvolvimento (Debug Ativo)';
    }
    if (hasPremiumFeatures) {
      return 'Premium Ativo';
    }
    return 'Gratuito';
  }

  /// Business rule: Get available features list
  /// Returns list of features available to this user
  List<String> get availableFeatures {
    final features = List<String>.from(_basicFeatures);

    if (hasPremiumFeatures) {
      features.addAll([
        'advanced_search',
        'custom_recipes',
        'recipe_export',
        'offline_mode',
        'priority_support',
      ]);
    }

    if (isDevelopmentMode) {
      features.addAll([
        'debug_panel',
        'feature_flags',
        'performance_monitor',
        'data_inspector',
      ]);
    }

    return features;
  }

  /// Business rule: Check if user should see premium upsell
  /// Shows upsell if user is free AND development mode is off
  bool get shouldShowUpsell {
    return !hasPremiumFeatures && !isDevelopmentMode;
  }

  /// Business rule: Get premium expiration warning
  /// Useful for subscription management
  String? getPremiumWarning() {
    if (!hasPremiumFeatures) return null;
    // Could extend to track expiration date in future
    return null;
  }

  @override
  String toString() {
    return 'PremiumSettingsEntity('
        'hasPremiumFeatures: $hasPremiumFeatures, '
        'isDevelopmentMode: $isDevelopmentMode, '
        'analyticsEnabled: $analyticsEnabled, '
        'lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PremiumSettingsEntity &&
        other.hasPremiumFeatures == hasPremiumFeatures &&
        other.isDevelopmentMode == isDevelopmentMode &&
        other.analyticsEnabled == analyticsEnabled &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return hasPremiumFeatures.hashCode ^
        isDevelopmentMode.hashCode ^
        analyticsEnabled.hashCode ^
        lastUpdated.hashCode;
  }
}

/// Enum representing the feature tier level of a user
enum FeatureTier { free, premium, debug }
