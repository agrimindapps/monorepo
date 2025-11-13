import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../src/shared/utils/failure.dart';

/// Service for managing license operations and business logic
/// NOTE: LicenseModel and LicenseRepository were removed
/// This service is now a facade for license status management
@Injectable()
class LicenseService {
  // NOTE: LicenseRepository dependency removed - use external implementation

  LicenseService();

  // TODO: Methods below require LicenseModel and LicenseRepository
  // which were removed during refactoring.
  // Implement these with actual repository implementations.

  /// Get current license status (stub)
  Future<Either<Failure, LicenseStatus>> getLicenseStatus() async {
    // Placeholder: Return no license for now
    return const Right(LicenseStatus.noLicense);
  }

  /// Check if premium features are available (stub)
  Future<Either<Failure, bool>> isPremiumAvailable() async {
    // Placeholder: Return false for now
    return const Right(false);
  }

  /// Get remaining trial days (stub)
  Future<Either<Failure, int>> getRemainingTrialDays() async {
    return const Right(0);
  }

  /// Validate feature access (stub)
  Future<Either<Failure, bool>> canAccessFeature(PremiumFeature feature) async {
    // Placeholder: Return false for now
    return const Right(false);
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

// NOTE: LicenseInfo class was removed - it depended on LicenseModel
// Consider implementing a replacement with actual license data model

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
