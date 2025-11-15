import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_status.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// **DIP - Dependency Inversion Principle**
/// Implements dashboard repository interface
/// Single Responsibility: Handle dashboard-specific status and lifecycle
class DashboardRepositoryImpl implements DashboardRepository {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<Either<Failure, DashboardStatus>> getStatus() async {
    try {
      final isOnline = await checkOnlineStatus().then(
        (result) => result.fold(
          (failure) => false,
          (online) => online,
        ),
      );

      return Right(
        DashboardStatus(
          isOnline: isOnline,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkOnlineStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = result != ConnectivityResult.none;
      return Right(isOnline);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refresh() async {
    try {
      // TODO: Implement dashboard refresh trigger
      // This should trigger all data sources to refresh their data
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getLastUpdateTime() async {
    try {
      // TODO: Get last update time from storage/cache
      return Right(DateTime.now());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
