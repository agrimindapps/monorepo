import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../models/license_model.dart';
import '../src/shared/utils/failure.dart';
import 'license_repository.dart';

/// Local storage implementation of LicenseRepository using Hive
@Injectable(as: LicenseRepository)
class LicenseLocalStorage implements LicenseRepository {
  static const String _boxName = 'license_box';
  static const String _currentLicenseKey = 'current_license';
  static const String _licenseHistoryKey = 'license_history';

  Box<LicenseModel>? _licenseBox;
  Box<List<LicenseModel>>? _historyBox;

  /// Initialize Hive boxes
  Future<void> _initializeBoxes() async {
    _licenseBox ??= await Hive.openBox<LicenseModel>(_boxName);
    _historyBox ??= await Hive.openBox<List<LicenseModel>>('${_boxName}_history');
  }

  @override
  Future<Either<Failure, LicenseModel>> createTrialLicense({
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _initializeBoxes();

      // Check if there's already an active license
      final currentResult = await getCurrentLicense();

      return currentResult.fold(
        (failure) async {
          // No current license, create new trial
          final trialLicense = LicenseModel.createTrial(metadata: metadata);

          final saveResult = await saveLicense(trialLicense);
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(trialLicense),
          );
        },
        (existingLicense) async {
          if (existingLicense != null) {
            // License already exists
            if (existingLicense.isValid) {
              return Right(existingLicense);
            } else {
              // Expired license, create new trial
              final trialLicense = LicenseModel.createTrial(metadata: metadata);
              final saveResult = await saveLicense(trialLicense);
              return saveResult.fold(
                (failure) => Left(failure),
                (_) => Right(trialLicense),
              );
            }
          } else {
            // No license, create new trial
            final trialLicense = LicenseModel.createTrial(metadata: metadata);
            final saveResult = await saveLicense(trialLicense);
            return saveResult.fold(
              (failure) => Left(failure),
              (_) => Right(trialLicense),
            );
          }
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to create trial license: $e'));
    }
  }

  @override
  Future<Either<Failure, LicenseModel?>> getCurrentLicense() async {
    try {
      await _initializeBoxes();
      final license = _licenseBox!.get(_currentLicenseKey);
      return Right(license);
    } catch (e) {
      return Left(CacheFailure('Failed to get current license: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLicenseValid() async {
    try {
      final result = await getCurrentLicense();
      return result.fold(
        (failure) => Left(failure),
        (license) => Right(license?.isValid ?? false),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to check license validity: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRemainingDays() async {
    try {
      final result = await getCurrentLicense();
      return result.fold(
        (failure) => Left(failure),
        (license) => Right(license?.remainingDays ?? 0),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get remaining days: $e'));
    }
  }

  @override
  Future<Either<Failure, LicenseModel>> extendLicense(int days) async {
    try {
      final result = await getCurrentLicense();
      return result.fold(
        (failure) => Left(failure),
        (license) async {
          if (license == null) {
            return const Left(NotFoundFailure('No license found to extend'));
          }

          final extendedLicense = license.copyWith(
            expirationDate: license.expirationDate.add(Duration(days: days)),
            isActive: true,
          );

          final saveResult = await saveLicense(extendedLicense);
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(extendedLicense),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to extend license: $e'));
    }
  }

  @override
  Future<Either<Failure, LicenseModel>> activateLicense(String licenseId) async {
    try {
      final result = await getCurrentLicense();
      return result.fold(
        (failure) => Left(failure),
        (license) async {
          if (license == null || license.id != licenseId) {
            return const Left(NotFoundFailure('License not found'));
          }

          final activatedLicense = license.copyWith(isActive: true);
          final saveResult = await saveLicense(activatedLicense);
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(activatedLicense),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to activate license: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateLicense() async {
    try {
      final result = await getCurrentLicense();
      return result.fold(
        (failure) => Left(failure),
        (license) async {
          if (license == null) {
            return const Right(null);
          }

          final deactivatedLicense = license.copyWith(isActive: false);
          return await saveLicense(deactivatedLicense);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to deactivate license: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLicense(LicenseModel license) async {
    try {
      await _initializeBoxes();
      await _licenseBox!.put(_currentLicenseKey, license);

      // Also save to history
      await _addToHistory(license);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save license: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLicense() async {
    try {
      await _initializeBoxes();
      await _licenseBox!.delete(_currentLicenseKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete license: $e'));
    }
  }

  @override
  Future<Either<Failure, LicenseModel?>> syncLicense() async {
    // For local storage, sync is not applicable
    // This would be implemented in a network repository
    final result = await getCurrentLicense();
    return result;
  }

  @override
  Future<Either<Failure, List<LicenseModel>>> getLicenseHistory() async {
    try {
      await _initializeBoxes();
      final history = _historyBox!.get(_licenseHistoryKey) ?? <LicenseModel>[];
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Failed to get license history: $e'));
    }
  }

  /// Add license to history
  Future<void> _addToHistory(LicenseModel license) async {
    try {
      final historyResult = await getLicenseHistory();
      await historyResult.fold(
        (failure) async => null, // Ignore history errors
        (history) async {
          final updatedHistory = List<LicenseModel>.from(history);

          // Check if license already exists in history
          final existingIndex = updatedHistory.indexWhere((l) => l.id == license.id);
          if (existingIndex != -1) {
            updatedHistory[existingIndex] = license;
          } else {
            updatedHistory.add(license);
          }

          // Keep only last 10 licenses in history
          if (updatedHistory.length > 10) {
            updatedHistory.removeRange(0, updatedHistory.length - 10);
          }

          await _historyBox!.put(_licenseHistoryKey, updatedHistory);
        },
      );
    } catch (e) {
      // Ignore history errors - not critical
    }
  }

  /// Clear all license data (useful for testing)
  Future<Either<Failure, void>> clearAllData() async {
    try {
      await _initializeBoxes();
      await _licenseBox!.clear();
      await _historyBox!.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear license data: $e'));
    }
  }

  /// Close Hive boxes
  Future<void> dispose() async {
    await _licenseBox?.close();
    await _historyBox?.close();
  }
}