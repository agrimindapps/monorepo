import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'license_provider.freezed.dart';
part 'license_provider.g.dart';

@freezed
class LicenseState with _$LicenseState {
  const factory LicenseState({
    @Default(LicenseInfo.noLicense()) LicenseInfo licenseInfo,
    @Default(false) bool isLoading,
    String? error,
  }) = _LicenseState;

  const LicenseState._();

  bool get hasValidLicense => licenseInfo.hasValidLicense;
  bool get isTrialActive => licenseInfo.isTrialActive;
  bool get isPremiumActive => licenseInfo.isPremiumActive;
  int get remainingDays => licenseInfo.remainingDays;
  String get statusText => licenseInfo.statusText;
  String get typeText => licenseInfo.typeText;
  String get remainingText => licenseInfo.remainingText;

  bool get shouldShowExpirationWarning {
    return isTrialActive && remainingDays <= 7;
  }

  String get warningLevel {
    if (!isTrialActive) return 'none';
    if (remainingDays <= 1) return 'critical';
    if (remainingDays <= 3) return 'high';
    if (remainingDays <= 7) return 'medium';
    return 'low';
  }
}

@riverpod
class LicenseNotifier extends _$LicenseNotifier {
  late final LicenseService _licenseService;
  Timer? _periodicTimer;

  @override
  LicenseState build(LicenseService licenseService) {
    _licenseService = licenseService;

    ref.onDispose(() {
      _periodicTimer?.cancel();
    });

    return const LicenseState();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _licenseService.initializeLicense();

      result.fold(
        (failure) => state = state.copyWith(
          error: failure.toString(),
          isLoading: false,
        ),
        (license) {
          _refreshLicenseInfo();
          state = state.copyWith(isLoading: false);
        },
      );

      _startPeriodicCheck();
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inicializar licença: $e',
        isLoading: false,
      );
    }
  }

  Future<void> refreshLicenseInfo() async {
    await _refreshLicenseInfo();
  }

  Future<void> _refreshLicenseInfo() async {
    try {
      final result = await _licenseService.getLicenseInfo();

      result.fold(
        (failure) => state = state.copyWith(error: failure.toString()),
        (info) => state = state.copyWith(licenseInfo: info, error: null),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao obter informações da licença: $e',
      );
    }
  }

  Future<bool> canAccessFeature(PremiumFeature feature) async {
    try {
      final result = await _licenseService.canAccessFeature(feature);
      return result.fold((failure) => false, (canAccess) => canAccess);
    } catch (e) {
      return false;
    }
  }

  Future<bool> extendTrial(int days) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _licenseService.extendTrial(days);

      return result.fold(
        (failure) {
          state = state.copyWith(
            error: 'Erro ao estender trial: ${failure.toString()}',
            isLoading: false,
          );
          return false;
        },
        (license) {
          _refreshLicenseInfo();
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao estender trial: $e',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> activatePremium(String subscriptionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _licenseService.activatePremium(
        subscriptionId: subscriptionId,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            error: 'Erro ao ativar premium: ${failure.toString()}',
            isLoading: false,
          );
          return false;
        },
        (license) {
          _refreshLicenseInfo();
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao ativar premium: $e',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> deactivateLicense() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _licenseService.deactivateLicense();

      return result.fold(
        (failure) {
          state = state.copyWith(
            error: 'Erro ao desativar licença: ${failure.toString()}',
            isLoading: false,
          );
          return false;
        },
        (_) {
          _refreshLicenseInfo();
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao desativar licença: $e',
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> resetLicense() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _licenseService.resetLicense();

      return result.fold(
        (failure) {
          state = state.copyWith(
            error: 'Erro ao resetar licença: ${failure.toString()}',
            isLoading: false,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            licenseInfo: const LicenseInfo.noLicense(),
            error: null,
            isLoading: false,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao resetar licença: $e',
        isLoading: false,
      );
      return false;
    }
  }

  Future<String?> getExpirationWarning() async {
    try {
      final result = await _licenseService.getExpirationWarning();
      return result.fold((failure) => null, (warning) => warning);
    } catch (e) {
      return null;
    }
  }

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _refreshLicenseInfo(),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

extension LicenseNotifierFeatures on LicenseNotifier {
  Future<bool> get canAddUnlimitedPlants async =>
      await canAccessFeature(PremiumFeature.unlimitedPlants);

  Future<bool> get canUseCustomReminders async =>
      await canAccessFeature(PremiumFeature.customReminders);

  Future<bool> get canUseAdvancedAnalytics async =>
      await canAccessFeature(PremiumFeature.advancedAnalytics);

  Future<bool> get canUseWeatherIntegration async =>
      await canAccessFeature(PremiumFeature.weatherIntegration);

  Future<bool> get canUsePlantIdentification async =>
      await canAccessFeature(PremiumFeature.plantIdentification);

  Future<bool> get canUseExpertSupport async =>
      await canAccessFeature(PremiumFeature.expertSupport);
}
