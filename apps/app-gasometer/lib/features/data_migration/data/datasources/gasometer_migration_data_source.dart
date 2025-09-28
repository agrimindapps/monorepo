import 'package:core/core.dart';

import '../../domain/entities/gasometer_account_data.dart';
import '../../domain/entities/gasometer_anonymous_data.dart';

/// Data source interface for gasometer data migration operations
/// 
/// This interface defines the contract for accessing and managing
/// gasometer-specific data during migration operations.
abstract class GasometerMigrationDataSource {
  /// Get anonymous user data for the gasometer app
  Future<Either<Failure, GasometerAnonymousData>> getAnonymousData(String anonymousUserId);

  /// Get account user data for the gasometer app
  Future<Either<Failure, GasometerAccountData>> getAccountData(String accountUserId);

  /// Clean anonymous user data from local storage
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanAnonymousLocalData(String anonymousUserId);

  /// Clean anonymous user data from remote storage
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanAnonymousRemoteData(String anonymousUserId);

  /// Delete anonymous Firebase account
  Future<Either<Failure, void>> deleteAnonymousAccount(String anonymousUserId);

  /// Check network connectivity
  Future<bool> checkNetworkConnectivity();

  /// Validate anonymous user exists and is valid
  Future<bool> validateAnonymousUser(String anonymousUserId);

  /// Validate account user exists and is valid
  Future<bool> validateAccountUser(String accountUserId);

  /// Cancel any ongoing operations
  Future<void> cancelOngoingOperations();
}