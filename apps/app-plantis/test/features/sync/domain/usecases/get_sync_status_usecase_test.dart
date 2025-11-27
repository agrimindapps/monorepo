import 'package:app_plantis/features/sync/domain/entities/sync_status.dart';
import 'package:app_plantis/features/sync/domain/repositories/i_sync_orchestration_repository.dart';
import 'package:app_plantis/features/sync/domain/usecases/get_sync_status_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncOrchestrationRepository extends Mock
    implements ISyncOrchestrationRepository {}

void main() {
  late MockSyncOrchestrationRepository mockRepository;
  late GetSyncStatusUseCase useCase;

  setUp(() {
    mockRepository = MockSyncOrchestrationRepository();
    useCase = GetSyncStatusUseCase(mockRepository);
  });

  group('GetSyncStatusUseCase', () {
    test('should get sync status successfully when idle', () async {
      // Arrange
      final syncStatus = PlantisSyncStatus(
        state: PlantisSyncState.idle,
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
        pendingCount: 0,
        failedCount: 0,
      );

      when(() => mockRepository.getCurrentSyncStatus())
          .thenAnswer((_) async => Right(syncStatus));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (status) {
          expect(status.state, PlantisSyncState.idle);
          expect(status.pendingCount, 0);
          expect(status.lastSyncAt, isNotNull);
        },
      );

      verify(() => mockRepository.getCurrentSyncStatus()).called(1);
    });

    test('should indicate when sync is in progress', () async {
      // Arrange
      final syncStatus = PlantisSyncStatus(
        state: PlantisSyncState.syncing,
        lastSyncAt: DateTime.now(),
        pendingCount: 5,
        failedCount: 0,
        progress: 0.6,
      );

      when(() => mockRepository.getCurrentSyncStatus())
          .thenAnswer((_) async => Right(syncStatus));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (status) {
          expect(status.state, PlantisSyncState.syncing);
          expect(status.progress, 0.6);
        },
      );
    });

    test('should show pending changes when offline', () async {
      // Arrange
      final syncStatus = PlantisSyncStatus(
        state: PlantisSyncState.idle,
        lastSyncAt: DateTime.now().subtract(const Duration(days: 1)),
        pendingCount: 10,
        failedCount: 0,
      );

      when(() => mockRepository.getCurrentSyncStatus())
          .thenAnswer((_) async => Right(syncStatus));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (status) {
          expect(status.pendingCount, 10);
        },
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure('Failed to get sync status');

      when(() => mockRepository.getCurrentSyncStatus())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
        },
        (_) => fail('Should return failure'),
      );
    });
  });
}
