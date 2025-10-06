import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/data_cleaner_service.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/gasometer_account_data.dart';
import '../../domain/entities/gasometer_anonymous_data.dart';
import 'gasometer_migration_data_source.dart';

/// Implementation of gasometer migration data source
///
/// This class provides concrete implementation for accessing and managing
/// gasometer-specific data during migration operations.
@LazySingleton(as: GasometerMigrationDataSource)
class GasometerMigrationDataSourceImpl implements GasometerMigrationDataSource {
  GasometerMigrationDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    required VehicleRepository vehicleRepository,
    required FuelRepository fuelRepository,
    required DataCleanerService dataCleanerService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _vehicleRepository = vehicleRepository,
       _fuelRepository = fuelRepository,
       _dataCleanerService = dataCleanerService;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final VehicleRepository _vehicleRepository;
  final FuelRepository _fuelRepository;
  final DataCleanerService _dataCleanerService;

  @override
  Future<Either<Failure, GasometerAnonymousData>> getAnonymousData(
    String anonymousUserId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Getting anonymous data for user: $anonymousUserId');
      }
      final userResult = await _getUserEntity(anonymousUserId);
      if (userResult.isLeft()) {
        return userResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      final userEntity = userResult.getOrElse(
        () => throw Exception('No user entity'),
      );
      final vehiclesResult = await _vehicleRepository.getAllVehicles();
      final vehicleCount = vehiclesResult.fold(
        (failure) => 0,
        (vehicles) => vehicles.where((v) => v.userId == anonymousUserId).length,
      );
      final fuelResult = await _fuelRepository.getAllFuelRecords();
      final Map<String, dynamic> fuelData = fuelResult.fold(
        (failure) => {'count': 0, 'totalCost': 0.0, 'totalDistance': 0.0},
        (supplies) {
          final userSupplies = supplies.where(
            (s) => s.userId == anonymousUserId,
          );
          return {
            'count': userSupplies.length,
            'totalCost': userSupplies.fold<double>(
              0.0,
              (sum, s) => sum + s.totalPrice,
            ),
            'totalDistance': userSupplies.fold<double>(
              0.0,
              (sum, s) => sum + s.odometer,
            ),
          };
        },
      );
      final anonymousData = GasometerAnonymousData(
        userId: anonymousUserId,
        userInfo: userEntity,
        recordCount: vehicleCount + (fuelData['count'] as int),
        lastModified: DateTime.now(), // TODO: Get actual last modified date
        vehicleCount: vehicleCount,
        fuelRecordCount: fuelData['count'] as int,
        maintenanceRecordCount:
            0, // TODO: Add maintenance records when implemented
        totalDistance: fuelData['totalDistance'] as double,
        totalFuelCost: fuelData['totalCost'] as double,
      );

      if (kDebugMode) {
        debugPrint('✅ Anonymous data retrieved: ${anonymousData.summary}');
      }

      return Right(anonymousData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting anonymous data: $e');
      }
      return Left(UnknownFailure('Erro ao obter dados anônimos: $e'));
    }
  }

  @override
  Future<Either<Failure, GasometerAccountData>> getAccountData(
    String accountUserId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Getting account data for user: $accountUserId');
      }
      final userResult = await _getUserEntity(accountUserId);
      if (userResult.isLeft()) {
        return userResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected result'),
        );
      }

      final userEntity = userResult.getOrElse(
        () => throw Exception('No user entity'),
      );
      final user = await _getUserFromFirestore(accountUserId);
      final accountAge =
          user != null && user.data() != null
              ? DateTime.now().difference(
                (user.data()!['created_at'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              )
              : null;
      final vehicleCount = await _getFirestoreRecordCount(
        'vehicles',
        accountUserId,
      );
      final fuelRecordCount = await _getFirestoreRecordCount(
        'fuel_supplies',
        accountUserId,
      );
      final fuelTotals = await _getFirestoreFuelTotals(accountUserId);

      final accountData = GasometerAccountData(
        userId: accountUserId,
        userInfo: userEntity,
        recordCount: vehicleCount + fuelRecordCount,
        lastModified: DateTime.now(), // TODO: Get actual last modified date
        vehicleCount: vehicleCount,
        fuelRecordCount: fuelRecordCount,
        maintenanceRecordCount:
            0, // TODO: Add maintenance records when implemented
        totalDistance: fuelTotals['totalDistance'] as double,
        totalFuelCost: fuelTotals['totalCost'] as double,
        accountAge: accountAge,
      );

      if (kDebugMode) {
        debugPrint('✅ Account data retrieved: ${accountData.summary}');
      }

      return Right(accountData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting account data: $e');
      }
      return Left(UnknownFailure('Erro ao obter dados da conta: $e'));
    }
  }

  @override
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanAnonymousLocalData(
    String anonymousUserId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🧹 Cleaning anonymous local data for user: $anonymousUserId',
        );
      }

      final result = await _dataCleanerService.clearAllData();

      return Right(
        AnonymousDataCleanupResult(
          success: result['success'] as bool,
          cleanupType: CleanupType.localOnly,
          message: 'Dados locais anônimos removidos',
          clearedCounts: {
            'hive_boxes': result['totalClearedBoxes'] as int? ?? 0,
            'shared_preferences':
                result['totalClearedPreferences'] as int? ?? 0,
          },
          errors: (result['errors'] as List?)?.cast<String>() ?? [],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning anonymous local data: $e');
      }
      return Left(UnknownFailure('Erro ao limpar dados locais anônimos: $e'));
    }
  }

  @override
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanAnonymousRemoteData(
    String anonymousUserId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🧹 Cleaning anonymous remote data for user: $anonymousUserId',
        );
      }

      int deletedVehicles = 0;
      int deletedFuelRecords = 0;
      final vehiclesQuery =
          await _firestore
              .collection('vehicles')
              .where('user_id', isEqualTo: anonymousUserId)
              .get();

      for (final doc in vehiclesQuery.docs) {
        await doc.reference.delete();
        deletedVehicles++;
      }
      final fuelQuery =
          await _firestore
              .collection('fuel_supplies')
              .where('user_id', isEqualTo: anonymousUserId)
              .get();

      for (final doc in fuelQuery.docs) {
        await doc.reference.delete();
        deletedFuelRecords++;
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Remote cleanup complete: $deletedVehicles vehicles, $deletedFuelRecords fuel records',
        );
      }

      return Right(
        AnonymousDataCleanupResult(
          success: true,
          cleanupType: CleanupType.remoteOnly,
          message: 'Dados remotos anônimos removidos',
          clearedCounts: {
            'vehicles': deletedVehicles,
            'fuel_records': deletedFuelRecords,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning anonymous remote data: $e');
      }
      return Left(UnknownFailure('Erro ao limpar dados remotos anônimos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnonymousAccount(
    String anonymousUserId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Deleting anonymous account: $anonymousUserId');
      }
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || currentUser.uid != anonymousUserId) {
        return const Left(AuthFailure('Usuário anônimo não está autenticado'));
      }

      if (!currentUser.isAnonymous) {
        return const Left(AuthFailure('Usuário não é anônimo'));
      }
      await currentUser.delete();

      if (kDebugMode) {
        debugPrint('✅ Anonymous account deleted successfully');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting anonymous account: $e');
      }
      return Left(UnknownFailure('Erro ao deletar conta anônima: $e'));
    }
  }

  @override
  Future<bool> checkNetworkConnectivity() async {
    try {
      await _firestore.collection('_connection_test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> validateAnonymousUser(String anonymousUserId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      return currentUser != null &&
          currentUser.uid == anonymousUserId &&
          currentUser.isAnonymous;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> validateAccountUser(String accountUserId) async {
    try {
      final userDoc = await _getUserFromFirestore(accountUserId);
      return userDoc != null && userDoc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> cancelOngoingOperations() async {
    if (kDebugMode) {
      debugPrint('🛑 Canceling ongoing migration operations');
    }
  }

  Future<Either<Failure, UserEntity>> _getUserEntity(String userId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        return Right(
          UserEntity(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName ?? 'Usuário',
            photoUrl: currentUser.photoURL,
            isEmailVerified: currentUser.emailVerified,
            lastLoginAt: currentUser.metadata.lastSignInTime,
            provider:
                currentUser.isAnonymous
                    ? AuthProvider.anonymous
                    : AuthProvider.email,
            createdAt: currentUser.metadata.creationTime,
            updatedAt: DateTime.now(),
          ),
        );
      }
      final userDoc = await _getUserFromFirestore(userId);
      if (userDoc != null && userDoc.exists) {
        final data = userDoc.data()!;
        return Right(
          UserEntity(
            id: userId,
            email: data['email'] as String? ?? '',
            displayName: data['display_name'] as String? ?? 'Usuário',
            photoUrl: data['photo_url'] as String?,
            isEmailVerified: data['email_verified'] as bool? ?? false,
            lastLoginAt: (data['last_login_at'] as Timestamp?)?.toDate(),
            provider: _parseAuthProvider(data['provider'] as String?),
            createdAt: (data['created_at'] as Timestamp?)?.toDate(),
            updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
          ),
        );
      }

      return const Left(NotFoundFailure('Usuário não encontrado'));
    } catch (e) {
      return Left(UnknownFailure('Erro ao obter dados do usuário: $e'));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUserFromFirestore(
    String userId,
  ) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      return null;
    }
  }

  Future<int> _getFirestoreRecordCount(String collection, String userId) async {
    try {
      final query =
          await _firestore
              .collection(collection)
              .where('user_id', isEqualTo: userId)
              .count()
              .get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> _getFirestoreFuelTotals(String userId) async {
    try {
      final query =
          await _firestore
              .collection('fuel_supplies')
              .where('user_id', isEqualTo: userId)
              .get();

      double totalCost = 0.0;
      double maxOdometer = 0.0;

      for (final doc in query.docs) {
        final data = doc.data();
        totalCost += (data['total_price'] as num?)?.toDouble() ?? 0.0;
        final odometer = (data['odometer'] as num?)?.toDouble() ?? 0.0;
        if (odometer > maxOdometer) maxOdometer = odometer;
      }

      return {'totalCost': totalCost, 'totalDistance': maxOdometer};
    } catch (e) {
      return {'totalCost': 0.0, 'totalDistance': 0.0};
    }
  }

  AuthProvider _parseAuthProvider(String? provider) {
    switch (provider) {
      case 'google.com':
        return AuthProvider.google;
      case 'apple.com':
        return AuthProvider.apple;
      case 'facebook.com':
        return AuthProvider.facebook;
      case 'anonymous':
        return AuthProvider.anonymous;
      default:
        return AuthProvider.email;
    }
  }
}
