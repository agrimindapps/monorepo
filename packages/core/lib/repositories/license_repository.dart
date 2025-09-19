import 'package:dartz/dartz.dart';
import '../models/license_model.dart';
import '../src/shared/utils/failure.dart';

/// Abstract repository interface for license management
abstract class LicenseRepository {
  /// Create a new trial license
  Future<Either<Failure, LicenseModel>> createTrialLicense({
    Map<String, dynamic>? metadata,
  });

  /// Get the current active license
  Future<Either<Failure, LicenseModel?>> getCurrentLicense();

  /// Check if current license is valid
  Future<Either<Failure, bool>> isLicenseValid();

  /// Get remaining days for current license
  Future<Either<Failure, int>> getRemainingDays();

  /// Extend current license by specified days
  Future<Either<Failure, LicenseModel>> extendLicense(int days);

  /// Activate a license by ID
  Future<Either<Failure, LicenseModel>> activateLicense(String licenseId);

  /// Deactivate current license
  Future<Either<Failure, void>> deactivateLicense();

  /// Save license to storage
  Future<Either<Failure, void>> saveLicense(LicenseModel license);

  /// Delete license from storage
  Future<Either<Failure, void>> deleteLicense();

  /// Sync license with remote server (if applicable)
  Future<Either<Failure, LicenseModel?>> syncLicense();

  /// Get license history
  Future<Either<Failure, List<LicenseModel>>> getLicenseHistory();
}