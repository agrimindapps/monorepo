import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../models/license_model.dart';
import '../src/shared/utils/failure.dart';
import 'license_repository.dart';

/// A concrete implementation of [LicenseRepository] that uses [Hive] for local storage.
///
/// This class manages the lifecycle of a [LicenseModel], including creation,
/// validation, and history tracking.
@Injectable(as: LicenseRepository)
class LicenseLocalStorage implements LicenseRepository {
  static const String _boxName = 'license_box';
  static const String _currentLicenseKey = 'current_license';
  static const String _licenseHistoryKey = 'license_history';

  Box<LicenseModel>? _licenseBox;
  Box<List<dynamic>>? _historyBox;

  /// Initializes the Hive boxes required for license storage.
  ///
  /// This method ensures that the license and history boxes are open before
  /// any operations are performed.
  Future<void> _initializeBoxes() async {
    _licenseBox ??= await Hive.openBox<LicenseModel>(_boxName);
    _historyBox ??= await Hive.openBox<List<dynamic>>('${_boxName}_history');
  }

  @override
  Future<Either<Failure, LicenseModel>> createTrialLicense({
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _initializeBoxes();
      final currentLicenseResult = await getCurrentLicense();

      return currentLicenseResult.fold(
        (failure) => Left(failure),
        (existingLicense) {
          if (existingLicense != null && existingLicense.isValid) {
            return Right(existingLicense);
          }

          final trialLicense = LicenseModel.createTrial(metadata: metadata);
          return saveLicense(trialLicense).then((saveResult) {
            return saveResult.fold(
              (failure) => Left(failure),
              (_) => Right(trialLicense),
            );
          });
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
    final result = await getCurrentLicense();
    return result.map((license) => license?.isValid ?? false);
  }

  @override
  Future<Either<Failure, int>> getRemainingDays() async {
    final result = await getCurrentLicense();
    return result.map((license) => license?.remainingDays ?? 0);
  }

  @override
  Future<Either<Failure, LicenseModel>> extendLicense(int days) async {
    final currentLicenseResult = await getCurrentLicense();

    return currentLicenseResult.fold(
      (failure) => Left(failure),
      (license) {
        if (license == null) {
          return const Left(NotFoundFailure('No license found to extend.'));
        }

        final extendedLicense = license.copyWith(
          expirationDate: license.expirationDate.add(Duration(days: days)),
          isActive: true,
        );

        return saveLicense(extendedLicense).then((saveResult) {
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(extendedLicense),
          );
        });
      },
    );
  }

  @override
  Future<Either<Failure, LicenseModel>> activateLicense(String licenseId) async {
    final currentLicenseResult = await getCurrentLicense();

    return currentLicenseResult.fold(
      (failure) => Left(failure),
      (license) {
        if (license == null || license.id != licenseId) {
          return const Left(NotFoundFailure('License not found.'));
        }

        final activatedLicense = license.copyWith(isActive: true);
        return saveLicense(activatedLicense).then((saveResult) {
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(activatedLicense),
          );
        });
      },
    );
  }

  @override
  Future<Either<Failure, void>> deactivateLicense() async {
    final currentLicenseResult = await getCurrentLicense();

    return currentLicenseResult.fold(
      (failure) => Left(failure),
      (license) async {
        if (license == null) {
          return const Right(null);
        }

        final deactivatedLicense = license.copyWith(isActive: false);
        return saveLicense(deactivatedLicense);
      },
    );
  }

  @override
  Future<Either<Failure, void>> saveLicense(LicenseModel license) async {
    try {
      await _initializeBoxes();
      await _licenseBox!.put(_currentLicenseKey, license);
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
  Future<Either<Failure, LicenseModel?>> syncLicense() {
    return getCurrentLicense();
  }

  @override
  Future<Either<Failure, List<LicenseModel>>> getLicenseHistory() async {
    try {
      await _initializeBoxes();
      final history = _historyBox!.get(_licenseHistoryKey, defaultValue: [])?.cast<LicenseModel>() ?? [];
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Failed to get license history: $e'));
    }
  }

  /// Adds a license to the history, ensuring the history does not exceed 10 entries.
  Future<void> _addToHistory(LicenseModel license) async {
    final historyResult = await getLicenseHistory();
    historyResult.fold(
      (_) => null, // Ignore history errors
      (history) async {
        final updatedHistory = history.where((l) => l.id != license.id).toList();
        updatedHistory.add(license);

        if (updatedHistory.length > 10) {
          updatedHistory.removeAt(0);
        }

        await _historyBox!.put(_licenseHistoryKey, updatedHistory);
      },
    );
  }

  /// Clears all license data from storage. Useful for testing.
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

  /// Closes the Hive boxes.
  Future<void> dispose() async {
    await _licenseBox?.close();
    await _historyBox?.close();
  }
}