import 'package:app_plantis/features/sync/domain/entities/sync_result.dart';
import 'package:app_plantis/features/sync/domain/repositories/i_sync_orchestration_repository.dart';
import 'package:app_plantis/features/sync/domain/usecases/trigger_manual_sync_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncOrchestrationRepository extends Mock
    implements ISyncOrchestrationRepository {}

void main() {
  late MockSyncOrchestrationRepository mockRepository;
  late TriggerManualSyncUseCase useCase;

  setUp(() {
    mockRepository = MockSyncOrchestrationRepository();
    useCase = TriggerManualSyncUseCase(mockRepository);
  });

  group('TriggerManualSyncUseCase', () {
    test('should trigger manual sync successfully', () async {
      // Arrange
      final syncResult = PlantisSyncResult(
        timestamp: DateTime.now(),
        itemsProcessed: 5,
        itemsWithConflicts: const [],
        errorCount: 0,
      );

      when(
        () => mockRepository.sync(),
      ).thenAnswer((_) async => Right(syncResult));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (response) {
        expect(response.itemsProcessed, 5);
        expect(response.errorCount, 0);
        expect(response.hasConflicts, false);
      });

      verify(() => mockRepository.sync()).called(1);
    });

    test('should return failure when sync fails', () async {
      // Arrange
      const failure = ServerFailure('Sync failed due to network error');

      when(
        () => mockRepository.sync(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, contains('network error'));
      }, (_) => fail('Should return failure'));
    });

    test('should handle sync with conflicts', () async {
      // Arrange
      final syncResult = PlantisSyncResult(
        timestamp: DateTime.now(),
        itemsProcessed: 4,
        itemsWithConflicts: const ['item-1'],
        errorCount: 0,
      );

      when(
        () => mockRepository.sync(),
      ).thenAnswer((_) async => Right(syncResult));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (response) {
        expect(response.hasConflicts, true);
        expect(response.itemsWithConflicts, isNotEmpty);
      });
    });

    test('should call repository only once per invocation', () async {
      // Arrange
      final syncResult = PlantisSyncResult(
        timestamp: DateTime.now(),
        itemsProcessed: 1,
        itemsWithConflicts: const [],
        errorCount: 0,
      );

      when(
        () => mockRepository.sync(),
      ).thenAnswer((_) async => Right(syncResult));

      // Act
      await useCase(const NoParams());

      // Assert
      verify(() => mockRepository.sync()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
