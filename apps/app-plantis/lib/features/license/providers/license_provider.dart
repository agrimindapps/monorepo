import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

/// Provider for managing license state and operations
class LicenseProvider extends ChangeNotifier {
  final LicenseService _licenseService;

  LicenseProvider(this._licenseService);

  // Current license info
  LicenseInfo _licenseInfo = const LicenseInfo.noLicense();
  LicenseInfo get licenseInfo => _licenseInfo;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Computed properties
  bool get hasValidLicense => _licenseInfo.hasValidLicense;
  bool get isTrialActive => _licenseInfo.isTrialActive;
  bool get isPremiumActive => _licenseInfo.isPremiumActive;
  int get remainingDays => _licenseInfo.remainingDays;
  String get statusText => _licenseInfo.statusText;
  String get typeText => _licenseInfo.typeText;
  String get remainingText => _licenseInfo.remainingText;

  // Timer for periodic checks
  Timer? _periodicTimer;

  /// Initialize the license system
  Future<void> initialize() async {
    await _setLoading(true);

    try {
      // Initialize license (creates trial if needed)
      final result = await _licenseService.initializeLicense();

      result.fold(
        (failure) => _setError(failure.toString()),
        (license) => _refreshLicenseInfo(),
      );

      // Start periodic checks for expiration
      _startPeriodicCheck();
    } catch (e) {
      _setError('Erro ao inicializar licença: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Refresh license information
  Future<void> refreshLicenseInfo() async {
    await _refreshLicenseInfo();
  }

  /// Internal method to refresh license info
  Future<void> _refreshLicenseInfo() async {
    try {
      final result = await _licenseService.getLicenseInfo();

      result.fold(
        (failure) => _setError(failure.toString()),
        (info) {
          _licenseInfo = info;
          _error = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro ao obter informações da licença: $e');
    }
  }

  /// Check if a premium feature can be accessed
  Future<bool> canAccessFeature(PremiumFeature feature) async {
    try {
      final result = await _licenseService.canAccessFeature(feature);
      return result.fold(
        (failure) => false,
        (canAccess) => canAccess,
      );
    } catch (e) {
      return false;
    }
  }

  /// Extend trial license (for development/testing)
  Future<bool> extendTrial(int days) async {
    await _setLoading(true);

    try {
      final result = await _licenseService.extendTrial(days);

      return result.fold(
        (failure) {
          _setError('Erro ao estender trial: ${failure.toString()}');
          return false;
        },
        (license) {
          _refreshLicenseInfo();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao estender trial: $e');
      return false;
    } finally {
      await _setLoading(false);
    }
  }

  /// Activate premium subscription
  Future<bool> activatePremium(String subscriptionId) async {
    await _setLoading(true);

    try {
      final result = await _licenseService.activatePremium(
        subscriptionId: subscriptionId,
      );

      return result.fold(
        (failure) {
          _setError('Erro ao ativar premium: ${failure.toString()}');
          return false;
        },
        (license) {
          _refreshLicenseInfo();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao ativar premium: $e');
      return false;
    } finally {
      await _setLoading(false);
    }
  }

  /// Deactivate current license
  Future<bool> deactivateLicense() async {
    await _setLoading(true);

    try {
      final result = await _licenseService.deactivateLicense();

      return result.fold(
        (failure) {
          _setError('Erro ao desativar licença: ${failure.toString()}');
          return false;
        },
        (_) {
          _refreshLicenseInfo();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao desativar licença: $e');
      return false;
    } finally {
      await _setLoading(false);
    }
  }

  /// Reset license system (for development/testing)
  Future<bool> resetLicense() async {
    await _setLoading(true);

    try {
      final result = await _licenseService.resetLicense();

      return result.fold(
        (failure) {
          _setError('Erro ao resetar licença: ${failure.toString()}');
          return false;
        },
        (_) {
          _licenseInfo = const LicenseInfo.noLicense();
          _error = null;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao resetar licença: $e');
      return false;
    } finally {
      await _setLoading(false);
    }
  }

  /// Get expiration warning message
  Future<String?> getExpirationWarning() async {
    try {
      final result = await _licenseService.getExpirationWarning();
      return result.fold(
        (failure) => null,
        (warning) => warning,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if license should show warning
  bool get shouldShowExpirationWarning {
    return isTrialActive && remainingDays <= 7;
  }

  /// Get warning color based on remaining days
  String get warningLevel {
    if (!isTrialActive) return 'none';
    if (remainingDays <= 1) return 'critical';
    if (remainingDays <= 3) return 'high';
    if (remainingDays <= 7) return 'medium';
    return 'low';
  }

  /// Start periodic license checks
  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15), // Check every 15 minutes
      (_) => _refreshLicenseInfo(),
    );
  }

  /// Set loading state
  Future<void> _setLoading(bool loading) async {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('[LicenseProvider] Error: $errorMessage');
    }
  }

  /// Clear error state
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}

/// Extension for feature access validation
extension LicenseProviderFeatures on LicenseProvider {
  /// Check if unlimited plants feature is available
  Future<bool> get canAddUnlimitedPlants async =>
      await canAccessFeature(PremiumFeature.unlimitedPlants);

  /// Check if custom reminders feature is available
  Future<bool> get canUseCustomReminders async =>
      await canAccessFeature(PremiumFeature.customReminders);

  /// Check if advanced analytics feature is available
  Future<bool> get canUseAdvancedAnalytics async =>
      await canAccessFeature(PremiumFeature.advancedAnalytics);

  /// Check if weather integration feature is available
  Future<bool> get canUseWeatherIntegration async =>
      await canAccessFeature(PremiumFeature.weatherIntegration);

  /// Check if plant identification feature is available
  Future<bool> get canUsePlantIdentification async =>
      await canAccessFeature(PremiumFeature.plantIdentification);

  /// Check if expert support feature is available
  Future<bool> get canUseExpertSupport async =>
      await canAccessFeature(PremiumFeature.expertSupport);
}