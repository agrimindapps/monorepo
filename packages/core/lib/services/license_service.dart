import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../models/license_model.dart';
import '../repositories/license_repository.dart';
import '../src/shared/utils/failure.dart';

/// A service that provides business logic for license management.
///
/// It uses a [LicenseRepository] to interact with the underlying data source
/// and exposes high-level methods for license initialization, status checks,
/// and feature access control.
@Injectable()
class LicenseService {
  final LicenseRepository _licenseRepository;

  LicenseService(this._licenseRepository);

  /// Initializes the license system.
  ///
  /// If a valid license already exists, it is returned. Otherwise, a new
  /// trial license is created and returned.
  Future<Either<Failure, LicenseModel>> initializeLicense({
    Map<String, dynamic>? metadata,
  }) async {
    final currentResult = await _licenseRepository.getCurrentLicense();

    return currentResult.fold(
      (failure) => _licenseRepository.createTrialLicense(metadata: metadata),
      (existingLicense) {
        if (existingLicense != null && existingLicense.isValid) {
          return Right(existingLicense);
        }
        return _licenseRepository.createTrialLicense(metadata: metadata);
      },
    );
  }

  /// Retrieves the current status of the license.
  Future<Either<Failure, LicenseStatus>> getLicenseStatus() async {
    final result = await _licenseRepository.getCurrentLicense();

    return result.map((license) {
      if (license == null) return LicenseStatus.noLicense;
      if (license.isExpired) return LicenseStatus.expired;
      if (license.isAboutToExpire) return LicenseStatus.aboutToExpire;
      if (license.isValid) return LicenseStatus.active;
      return LicenseStatus.inactive;
    });
  }

  /// Checks if premium features are currently available.
  ///
  /// Premium features are available if the license is active or about to expire.
  Future<Either<Failure, bool>> isPremiumAvailable() async {
    final statusResult = await getLicenseStatus();
    return statusResult.map((status) =>
        status == LicenseStatus.active || status == LicenseStatus.aboutToExpire);
  }

  /// Gets the number of remaining days for the current trial license.
  Future<Either<Failure, int>> getRemainingTrialDays() {
    return _licenseRepository.getRemainingDays();
  }

  /// Extends the current license by a specified number of days.
  ///
  /// The number of days must be between 1 and 90.
  Future<Either<Failure, LicenseModel>> extendTrial(int days) async {
    if (days <= 0 || days > 90) {
      return const Left(
        ValidationFailure('Extension days must be between 1 and 90.'),
      );
    }
    return _licenseRepository.extendLicense(days);
  }

  /// Activates a new premium license.
  Future<Either<Failure, LicenseModel>> activatePremium({
    required String subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    final premiumLicense = LicenseModel(
      id: 'PREM-$subscriptionId',
      startDate: DateTime.now(),
      expirationDate: DateTime.now().add(const Duration(days: 365)), // 1 year
      isActive: true,
      type: LicenseType.premium,
      metadata: {'subscriptionId': subscriptionId, ...?metadata},
    );

    final saveResult = await _licenseRepository.saveLicense(premiumLicense);
    return saveResult.map((_) => premiumLicense);
  }

  /// Gathers comprehensive information about the current license for display.
  Future<Either<Failure, LicenseInfo>> getLicenseInfo() async {
    final licenseResult = await _licenseRepository.getCurrentLicense();

    return licenseResult.fold(
      (failure) => Left(failure),
      (license) async {
        if (license == null) {
          return const Right(LicenseInfo.noLicense());
        }

        final statusResult = await getLicenseStatus();
        return statusResult.map((status) => LicenseInfo(
              license: license,
              status: status,
            ));
      },
    );
  }

  /// Deactivates the current license.
  Future<Either<Failure, void>> deactivateLicense() {
    return _licenseRepository.deactivateLicense();
  }

  /// Resets the license system by deleting the current license.
  ///
  /// This is intended for development and testing purposes.
  Future<Either<Failure, void>> resetLicense() {
    return _licenseRepository.deleteLicense();
  }

  /// Validates if a specific premium feature can be accessed.
  ///
  /// NOTE: This implementation currently grants access to all premium features
  /// if a premium license is available, regardless of the specific [feature].
  Future<Either<Failure, bool>> canAccessFeature(PremiumFeature feature) {
    return isPremiumAvailable();
  }

  /// Returns a warning message if the trial license is expiring soon or has expired.
  ///
  /// Returns `null` if no warning is needed.
  Future<Either<Failure, String?>> getExpirationWarning() async {
    final infoResult = await getLicenseInfo();

    return infoResult.map((info) {
      if (!info.isTrialActive) return null;

      final days = info.remainingDays;
      if (days <= 0) {
        return 'Seu período de teste expirou. Assine o premium para continuar.';
      }
      if (days <= 3) {
        final dayString = days == 1 ? 'dia' : 'dias';
        return 'Seu período de teste expira em $days $dayString.';
      }
      return null;
    });
  }
}

/// An enum representing the various states of a license.
enum LicenseStatus { noLicense, active, aboutToExpire, expired, inactive }

/// An extension on [LicenseStatus] to provide user-friendly display names and descriptions.
extension LicenseStatusExtension on LicenseStatus {
  String get displayName {
    switch (this) {
      case LicenseStatus.noLicense:
        return 'Sem licença';
      case LicenseStatus.active:
        return 'Ativa';
      case LicenseStatus.aboutToExpire:
        return 'Prestes a expirar';
      case LicenseStatus.expired:
        return 'Expirada';
      case LicenseStatus.inactive:
        return 'Inativa';
    }
  }

  String get description {
    switch (this) {
      case LicenseStatus.noLicense:
        return 'Nenhuma licença encontrada';
      case LicenseStatus.active:
        return 'Licença ativa e funcionando';
      case LicenseStatus.aboutToExpire:
        return 'Licença expira em breve';
      case LicenseStatus.expired:
        return 'Licença expirou, renove para continuar';
      case LicenseStatus.inactive:
        return 'Licença desativada';
    }
  }
}

/// A data class holding comprehensive information about a license for display purposes.
class LicenseInfo {
  final LicenseModel? license;
  final LicenseStatus status;

  const LicenseInfo({
    required this.license,
    required this.status,
  });

  const LicenseInfo.noLicense()
      : license = null,
        status = LicenseStatus.noLicense;

  int get remainingDays => license?.remainingDays ?? 0;
  bool get isTrialActive =>
      license?.type == LicenseType.trial && (license?.isValid ?? false);
  bool get isPremiumActive =>
      license?.type == LicenseType.premium && (license?.isValid ?? false);
  bool get hasValidLicense => isTrialActive || isPremiumActive;
  String get statusText => status.displayName;
  String get typeText => license?.type.displayName ?? 'Sem licença';

  String get remainingText {
    if (remainingDays <= 0) return 'Expirado';
    return '$remainingDays ${remainingDays == 1 ? 'dia' : 'dias'} restantes';
  }
}

/// An enum representing the different premium features available.
enum PremiumFeature {
  unlimitedPlants,
  customReminders,
  advancedAnalytics,
  weatherIntegration,
  plantIdentification,
  expertSupport,
}

/// An extension on [PremiumFeature] to provide user-friendly display names and descriptions.
extension PremiumFeatureExtension on PremiumFeature {
  String get displayName {
    switch (this) {
      case PremiumFeature.unlimitedPlants:
        return 'Plantas ilimitadas';
      case PremiumFeature.customReminders:
        return 'Lembretes personalizados';
      case PremiumFeature.advancedAnalytics:
        return 'Análises avançadas';
      case PremiumFeature.weatherIntegration:
        return 'Integração meteorológica';
      case PremiumFeature.plantIdentification:
        return 'Identificação de plantas';
      case PremiumFeature.expertSupport:
        return 'Suporte especializado';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.unlimitedPlants:
        return 'Adicione quantas plantas quiser';
      case PremiumFeature.customReminders:
        return 'Crie lembretes personalizados';
      case PremiumFeature.advancedAnalytics:
        return 'Relatórios e estatísticas detalhadas';
      case PremiumFeature.weatherIntegration:
        return 'Cuidados baseados no clima';
      case PremiumFeature.plantIdentification:
        return 'Identifique plantas por foto';
      case PremiumFeature.expertSupport:
        return 'Suporte de especialistas em plantas';
    }
  }
}