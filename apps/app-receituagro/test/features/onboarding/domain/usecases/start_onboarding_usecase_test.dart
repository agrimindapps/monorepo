import 'package:app_receituagro/features/onboarding/domain/domain.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIOnboardingRepository extends Mock
    implements IOnboardingRepository {}

class MockIAnalyticsRepository extends Mock implements IAnalyticsRepository {}

void main() {
  late StartOnboardingUseCase useCase;
  late MockIOnboardingRepository mockRepository;
  late MockIAnalyticsRepository mockAnalytics;

  setUp(() {
    mockRepository = MockIOnboardingRepository();
    mockAnalytics = MockIAnalyticsRepository();
    useCase = StartOnboardingUseCase(mockRepository, mockAnalytics);
  });

  group('StartOnboardingUseCase', () {
    final testSteps = [
      const OnboardingStep(
        id: 'welcome',
        title: 'Welcome',
        description: 'Welcome step',
        isRequired: true,
      ),
      const OnboardingStep(
        id: 'explore',
        title: 'Explore',
        description: 'Explore step',
        isRequired: true,
      ),
    ];

    test('should start onboarding successfully', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.startedAt, isNotNull);
          expect(progress.currentStep, 'welcome');
          expect(progress.completedSteps, isEmpty);
          expect(progress.isCompleted, false);
        },
      );
    });

    test('should save progress to storage', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      await useCase.call(const NoParams());

      // Assert
      verify(() => mockRepository.saveProgress(any())).called(1);
    });

    test('should log analytics event', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      await useCase.call(const NoParams());

      // Assert
      verify(() => mockAnalytics.logEvent(
            'onboarding_started',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should fail if no steps configured', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps()).thenReturn(const Right([]));

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (progress) => fail('Should fail'),
      );
    });

    test('should propagate repository failure when getting steps', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(const Left(UnexpectedFailure('Config error')));

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result.isLeft(), true);
    });

    test('should propagate failure when saving progress fails', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Storage error')));

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (progress) => fail('Should fail'),
      );
    });

    test('should handle unexpected exception', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (progress) => fail('Should fail'),
      );
    });
  });
}
