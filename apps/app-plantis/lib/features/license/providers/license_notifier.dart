import 'dart:async';

import 'package:core/core.dart' hide Column, getIt;
import 'package:flutter/foundation.dart';

part 'license_notifier.g.dart';

/// State for license management
class LicenseState {
  final LicenseInfo licenseInfo;
  final bool isLoading;
  final String? error;

  const LicenseState({
    required this.licenseInfo,
    this.isLoading = false,
    this.error,
  });

  LicenseState copyWith({
    LicenseInfo? licenseInfo,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LicenseState(
      licenseInfo: licenseInfo ?? this.licenseInfo,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasValidLicense => licenseInfo.hasValidLicense;
  bool get isTrialActive => licenseInfo.isTrialActive;
  bool get isPremiumActive => licenseInfo.isPremiumActive;
  int get remainingDays => licenseInfo.remainingDays;
  String get statusText => licenseInfo.statusText;
  String get typeText => licenseInfo.typeText;
  String get remainingText => licenseInfo.remainingText;

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
}

/// Notifier for managing license state and operations
@riverpod
class LicenseNotifier extends _$LicenseNotifier {
  late final LicenseService _licenseService;
  Timer? _periodicTimer;

  @override
  Future<LicenseState> build() async {
    _licenseService = ref.read(licenseServiceProvider);
    ref.onDispose(() {
      _periodicTimer?.cancel();
    });

    try {
      final result = await _licenseService.initializeLicense();

      final licenseInfo = await result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('[LicenseNotifier] Initialization error: $failure');
          }
          final infoResult = await _licenseService.getLicenseInfo();
          return infoResult.fold(
            (_) => LicenseInfo.noLicense(),
            (info) => info,
          );
        },
        (_) async {
          final infoResult = await _licenseService.getLicenseInfo();
          return infoResult.fold(
            (_) => LicenseInfo.noLicense(),
            (info) => info,
          );
        },
      );
      _startPeriodicCheck();

      return LicenseState(licenseInfo: licenseInfo);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LicenseNotifier] Build error: $e');
      }
      return LicenseState(
        licenseInfo: LicenseInfo.noLicense(),
        error: 'Erro ao inicializar licença',
      );
    }
  }

  /// Refresh license information
  Future<void> refreshLicenseInfo() async {
    try {
      final result = await _licenseService.getLicenseInfo();

      result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              error: failure.toString(),
            ),
          );
        },
        (info) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              licenseInfo: info,
              clearError: true,
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? _defaultState()).copyWith(
          error: 'Erro ao obter informações da licença: $e',
        ),
      );
    }
  }

  /// Check if a premium feature can be accessed
  Future<bool> canAccessFeature(PremiumFeature feature) async {
    try {
      final result = await _licenseService.canAccessFeature(feature);
      return result.fold((failure) => false, (canAccess) => canAccess);
    } catch (e) {
      return false;
    }
  }

  /// Extend trial license (for development/testing)
  Future<bool> extendTrial(int days) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? _defaultState()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await _licenseService.extendTrial(days);

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              isLoading: false,
              error: 'Erro ao estender trial: ${failure.toString()}',
            ),
          );
          return false;
        },
        (license) async {
          await refreshLicenseInfo();
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(isLoading: false),
          );
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? _defaultState()).copyWith(
          isLoading: false,
          error: 'Erro ao estender trial: $e',
        ),
      );
      return false;
    }
  }

  /// Activate premium subscription
  Future<bool> activatePremium(String subscriptionId) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? _defaultState()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await _licenseService.activatePremium(
        subscriptionId: subscriptionId,
      );

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              isLoading: false,
              error: 'Erro ao ativar premium: ${failure.toString()}',
            ),
          );
          return false;
        },
        (license) async {
          await refreshLicenseInfo();
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(isLoading: false),
          );
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? _defaultState()).copyWith(
          isLoading: false,
          error: 'Erro ao ativar premium: $e',
        ),
      );
      return false;
    }
  }

  /// Deactivate current license
  Future<bool> deactivateLicense() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? _defaultState()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await _licenseService.deactivateLicense();

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              isLoading: false,
              error: 'Erro ao desativar licença: ${failure.toString()}',
            ),
          );
          return false;
        },
        (_) async {
          await refreshLicenseInfo();
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(isLoading: false),
          );
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? _defaultState()).copyWith(
          isLoading: false,
          error: 'Erro ao desativar licença: $e',
        ),
      );
      return false;
    }
  }

  /// Reset license system (for development/testing)
  Future<bool> resetLicense() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? _defaultState()).copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await _licenseService.resetLicense();

      return result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? _defaultState()).copyWith(
              isLoading: false,
              error: 'Erro ao resetar licença: ${failure.toString()}',
            ),
          );
          return false;
        },
        (_) {
          state = AsyncValue.data(
            LicenseState(licenseInfo: LicenseInfo.noLicense()),
          );
          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? _defaultState()).copyWith(
          isLoading: false,
          error: 'Erro ao resetar licença: $e',
        ),
      );
      return false;
    }
  }

  /// Get expiration warning message
  Future<String?> getExpirationWarning() async {
    try {
      final result = await _licenseService.getExpirationWarning();
      return result.fold((failure) => null, (warning) => warning);
    } catch (e) {
      return null;
    }
  }

  /// Start periodic license checks
  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15), // Check every 15 minutes
      (_) => refreshLicenseInfo(),
    );
  }

  /// Clear error state
  void clearError() {
    state = AsyncValue.data(
      (state.valueOrNull ?? _defaultState()).copyWith(clearError: true),
    );
  }

  LicenseState _defaultState() {
    return LicenseState(licenseInfo: LicenseInfo.noLicense());
  }
}

@riverpod
LicenseService licenseService(Ref ref) {
  return GetIt.instance<LicenseService>();
}

@riverpod
Future<bool> canAddUnlimitedPlants(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.unlimitedPlants);
}

@riverpod
Future<bool> canUseCustomReminders(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.customReminders);
}

@riverpod
Future<bool> canUseAdvancedAnalytics(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.advancedAnalytics);
}

@riverpod
Future<bool> canUseWeatherIntegration(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.weatherIntegration);
}

@riverpod
Future<bool> canUsePlantIdentification(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.plantIdentification);
}

@riverpod
Future<bool> canUseExpertSupport(Ref ref) async {
  return ref
      .read(licenseNotifierProvider.notifier)
      .canAccessFeature(PremiumFeature.expertSupport);
}
