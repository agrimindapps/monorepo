import 'package:dartz/dartz.dart';

import '../src/shared/utils/failure.dart';

/// Abstract repository interface for license management
/// NOTE: LicenseModel was removed - this interface is now a stub
/// Implement with actual license data model
abstract class LicenseRepository {
  /// Create a new trial license
  Future<Either<Failure, dynamic>> createTrialLicense({
    Map<String, dynamic>? metadata,
  });

  /// Get the current active license
  Future<Either<Failure, dynamic>> getCurrentLicense();

  /// Check if current license is valid
  Future<Either<Failure, bool>> isLicenseValid();

  /// Get remaining days for current license
  Future<Either<Failure, int>> getRemainingDays();

  /// Extend current license by specified days
  Future<Either<Failure, dynamic>> extendLicense(int days);

  /// Activate a license by ID
  Future<Either<Failure, dynamic>> activateLicense(String licenseId);

  /// Deactivate current license
  Future<Either<Failure, void>> deactivateLicense();

  /// Save license to storage
  Future<Either<Failure, void>> saveLicense(dynamic license);

  /// Delete license from storage
  Future<Either<Failure, void>> deleteLicense();

  /// Sync license with remote server (if applicable)
  Future<Either<Failure, dynamic>> syncLicense();

  /// Get license history
  Future<Either<Failure, List<dynamic>>> getLicenseHistory();
}
