import 'package:app_receituagro/features/onboarding/domain/domain.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockIOnboardingRepository extends Mock
    implements IOnboardingRepository {}

class MockIAnalyticsRepository extends Mock implements IAnalyticsRepository {}

void main() {
  late CompleteStepUseCase useCase;
  late MockIOnboardingRepository mockRepository;
  late MockIAnalyticsRepository mockAnalytics;

  setUp(() {
    mockRepository = MockIOnboardingRepository();
    mockAnalytics = MockIAnalyticsRepository();
    useCase = CompleteStepUseCase(mockRepository, mockAnalytics);
  });

  group('CompleteStepUseCase', () {
    // ==================== Test Data ====================

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
      const OnboardingStep(
        id: 'premium',
        title: 'Premium',
        description: 'Premium step',
        isRequired: false,
      ),
    ];

    final testProgress = OnboardingProgress(
      completedSteps: {'welcome': true},
      startedAt: DateTime.now(),
      completedAt: null,
      currentStep: 'explore',
      isCompleted: false,
    );

    // ==================== Success Tests ====================

    test('should complete a step successfully', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'explore',
          currentProgress: testProgress,
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.completedSteps['explore'], true);
          expect(progress.currentStep, 'premium');
          expect(progress.isCompleted, false); // Not all required steps done
        },
      );

      // Verify analytics was called
      verify(() => mockAnalytics.logEvent(
            'onboarding_step_completed',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should mark onboarding as completed when all required steps done',
        () async {
      // Arrange
      final progressWithBothRequired = testProgress.copyWith(
        completedSteps: {
          'welcome': true,
          'explore': false,
        },
      );

      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'explore',
          currentProgress: progressWithBothRequired,
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.isCompleted, true);
          expect(progress.completedAt, isNotNull);
        },
      );

      // Verify completion event was logged
      verify(() => mockAnalytics.logEvent(
            'onboarding_completed',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should move to next step automatically', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'welcome',
          currentProgress: testProgress.copyWith(
            completedSteps: {},
            currentStep: 'welcome',
          ),
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.currentStep, 'explore');
        },
      );
    });

    test('should reach end when completing last step', () async {
      // Arrange
      final lastStepProgress = testProgress.copyWith(
        completedSteps: {
          'welcome': true,
          'explore': true,
        },
        currentStep: 'premium',
      );

      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));
      when(() => mockRepository.saveProgress(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockAnalytics.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'premium',
          currentProgress: lastStepProgress,
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.currentStep, ''); // No more steps
        },
      );
    });

    // ==================== Validation Tests ====================

    test('should fail when step not found', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(testSteps));

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'nonexistent',
          currentProgress: testProgress,
        ),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (progress) => fail('Should fail'),
      );
    });

    test('should fail when dependency not completed', () async {
      // Arrange
      final stepsWithDependency = [
        const OnboardingStep(
          id: 'step1',
          title: 'Step 1',
          description: 'First step',
          isRequired: true,
        ),
        const OnboardingStep(
          id: 'step2',
          title: 'Step 2',
          description: 'Second step',
          isRequired: true,
          dependencies: ['step1'],
        ),
      ];

      final progressWithoutDep = OnboardingProgress(
        completedSteps: {},
        startedAt: DateTime.now(),
        completedAt: null,
        currentStep: 'step1',
        isCompleted: false,
      );

      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(Right(stepsWithDependency));

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'step2',
          currentProgress: progressWithoutDep,
        ),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (progress) => fail('Should fail'),
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
      await useCase.call(
        CompleteStepParams(
          stepId: 'explore',
          currentProgress: testProgress,
        ),
      );

      // Assert
      verify(() => mockRepository.saveProgress(any())).called(1);
    });

    test('should propagate repository failure', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenReturn(const Left(CacheFailure('Storage error')));

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'explore',
          currentProgress: testProgress,
        ),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (progress) => fail('Should fail'),
      );
    });

    test('should handle exception and return UnexpectedFailure', () async {
      // Arrange
      when(() => mockRepository.getOnboardingSteps())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call(
        CompleteStepParams(
          stepId: 'explore',
          currentProgress: testProgress,
        ),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (progress) => fail('Should fail'),
      );
    });
  });
}
