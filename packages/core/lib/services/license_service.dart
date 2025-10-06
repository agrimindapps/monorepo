import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../models/license_model.dart';
import '../repositories/license_repository.dart';
import '../src/shared/utils/failure.dart';

/// Service for managing license operations and business logic
@Injectable()
class LicenseService {
  final LicenseRepository _licenseRepository;

  LicenseService(this._licenseRepository);

  /// Initialize license system - creates trial if no license exists
  Future<Either<Failure, LicenseModel>> initializeLicense({
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentResult = await _licenseRepository.getCurrentLicense();

      return currentResult.fold(
        (failure) async {
          return await _licenseRepository.createTrialLicense(
            metadata: metadata,
          );
        },
        (existingLicense) async {
          if (existingLicense != null && existingLicense.isValid) {
            return Right(existingLicense);
          } else {
            return await _licenseRepository.createTrialLicense(
              metadata: metadata,
            );
          }
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to initialize license: $e'));
    }
  }

  /// Get current license status
  Future<Either<Failure, LicenseStatus>> getLicenseStatus() async {
    try {
      final result = await _licenseRepository.getCurrentLicense();

      return result.fold((failure) => Left(failure), (license) {
        if (license == null) {
          return const Right(LicenseStatus.noLicense);
        }

        if (license.isExpired) {
          return const Right(LicenseStatus.expired);
        }

        if (license.isAboutToExpire) {
          return const Right(LicenseStatus.aboutToExpire);
        }

        if (license.isValid) {
          return const Right(LicenseStatus.active);
        }

        return const Right(LicenseStatus.inactive);
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to get license status: $e'));
    }
  }

  /// Check if premium features are available
  Future<Either<Failure, bool>> isPremiumAvailable() async {
    try {
      final statusResult = await getLicenseStatus();

      return statusResult.fold((failure) => Left(failure), (status) {
        final premiumStatuses = [
          LicenseStatus.active,
          LicenseStatus.aboutToExpire,
        ];
        return Right(premiumStatuses.contains(status));
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to check premium availability: $e'));
    }
  }

  /// Get remaining trial days
  Future<Either<Failure, int>> getRemainingTrialDays() async {
    try {
      return await _licenseRepository.getRemainingDays();
    } catch (e) {
      return Left(UnknownFailure('Failed to get remaining days: $e'));
    }
  }

  /// Extend trial license (for development/testing)
  Future<Either<Failure, LicenseModel>> extendTrial(int days) async {
    try {
      if (days <= 0 || days > 90) {
        return const Left(
          ValidationFailure('Extension days must be between 1 and 90'),
        );
      }

      return await _licenseRepository.extendLicense(days);
    } catch (e) {
      return Left(UnknownFailure('Failed to extend trial: $e'));
    }
  }

  /// Activate premium license (when user subscribes)
  Future<Either<Failure, LicenseModel>> activatePremium({
    required String subscriptionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final premiumLicense = LicenseModel(
        id: 'PREM-$subscriptionId',
        startDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 365)), // 1 year
        isActive: true,
        type: LicenseType.premium,
        metadata: {'subscriptionId': subscriptionId, ...?metadata},
      );

      final saveResult = await _licenseRepository.saveLicense(premiumLicense);
      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(premiumLicense),
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to activate premium: $e'));
    }
  }

  /// Get license information for display
  Future<Either<Failure, LicenseInfo>> getLicenseInfo() async {
    try {
      final licenseResult = await _licenseRepository.getCurrentLicense();

      return licenseResult.fold((failure) => Left(failure), (license) async {
        if (license == null) {
          return const Right(LicenseInfo.noLicense());
        }

        final statusResult = await getLicenseStatus();
        return statusResult.fold(
          (failure) => Left(failure),
          (status) => Right(
            LicenseInfo(
              license: license,
              status: status,
              remainingDays: license.remainingDays,
              isTrialActive:
                  license.type == LicenseType.trial && license.isValid,
              isPremiumActive:
                  license.type == LicenseType.premium && license.isValid,
            ),
          ),
        );
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to get license info: $e'));
    }
  }

  /// Deactivate current license
  Future<Either<Failure, void>> deactivateLicense() async {
    try {
      return await _licenseRepository.deactivateLicense();
    } catch (e) {
      return Left(UnknownFailure('Failed to deactivate license: $e'));
    }
  }

  /// Reset license system (for development/testing)
  Future<Either<Failure, void>> resetLicense() async {
    try {
      return await _licenseRepository.deleteLicense();
    } catch (e) {
      return Left(UnknownFailure('Failed to reset license: $e'));
    }
  }

  /// Validate feature access
  Future<Either<Failure, bool>> canAccessFeature(PremiumFeature feature) async {
    try {
      final premiumResult = await isPremiumAvailable();

      return premiumResult.fold((failure) => Left(failure), (isPremium) {
        return Right(isPremium);
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to validate feature access: $e'));
    }
  }

  /// Get trial expiration warning message
  Future<Either<Failure, String?>> getExpirationWarning() async {
    try {
      final infoResult = await getLicenseInfo();

      return infoResult.fold((failure) => Left(failure), (info) {
        if (!info.isTrialActive) return const Right(null);

        final days = info.remainingDays;
        if (days <= 0) {
          return const Right(
            'Seu período de teste expirou. Assine o premium para continuar.',
          );
        } else if (days <= 3) {
          return Right(
            'Seu período de teste expira em $days ${days == 1 ? 'dia' : 'dias'}.',
          );
        }

        return const Right(null);
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to get expiration warning: $e'));
    }
  }
}

/// Enum for license status
enum LicenseStatus { noLicense, active, aboutToExpire, expired, inactive }

/// Extension for LicenseStatus display
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

/// Information class for license display
class LicenseInfo {
  final LicenseModel? license;
  final LicenseStatus status;
  final int remainingDays;
  final bool isTrialActive;
  final bool isPremiumActive;

  const LicenseInfo({
    required this.license,
    required this.status,
    required this.remainingDays,
    required this.isTrialActive,
    required this.isPremiumActive,
  });

  const LicenseInfo.noLicense()
    : license = null,
      status = LicenseStatus.noLicense,
      remainingDays = 0,
      isTrialActive = false,
      isPremiumActive = false;

  bool get hasValidLicense => isTrialActive || isPremiumActive;

  String get statusText => status.displayName;

  String get typeText {
    if (license == null) return 'Sem licença';
    return license!.type.displayName;
  }

  String get remainingText {
    if (remainingDays <= 0) return 'Expirado';
    return '$remainingDays ${remainingDays == 1 ? 'dia' : 'dias'} restantes';
  }
}

/// Enum for premium features
enum PremiumFeature {
  unlimitedPlants,
  customReminders,
  advancedAnalytics,
  weatherIntegration,
  plantIdentification,
  expertSupport,
}

/// Extension for PremiumFeature display
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
