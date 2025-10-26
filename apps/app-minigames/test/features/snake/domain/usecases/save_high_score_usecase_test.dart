import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/snake/domain/usecases/save_high_score_usecase.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late SaveHighScoreUseCase useCase;
  late MockSnakeRepository mockRepository;

  setUp(() {
    mockRepository = MockSnakeRepository();
    useCase = SaveHighScoreUseCase(mockRepository);
  });

  group('SaveHighScoreUseCase - Snake', () {
    test('should save high score successfully with valid score', () async {
      // Arrange
      const score = 150;

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(score)).called(1);
    });

    test('should return ValidationFailure when score is negative', () async {
      // Arrange
      const score = -10;

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Score cannot be negative');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.saveHighScore(any()));
    });

    test('should accept zero score as valid', () async {
      // Arrange
      const score = 0;

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(score)).called(1);
    });

    test('should save high score with large value', () async {
      // Arrange
      const score = 99999;

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveHighScore(score)).called(1);
    });

    test('should propagate repository failure when save fails', () async {
      // Arrange
      const score = 100;
      const failure = CacheFailure('Failed to save to local storage');

      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Failed to save to local storage');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.saveHighScore(score)).called(1);
    });

    test('should validate before calling repository', () async {
      // Arrange
      const score = -50;

      // Act
      final result = await useCase(score: score);

      // Assert
      expect(result.isLeft(), true);
      verifyNever(() => mockRepository.saveHighScore(any()));
    });

    test('should save multiple different scores successfully', () async {
      // Arrange
      when(() => mockRepository.saveHighScore(any()))
          .thenAnswer((_) async => const Right(null));

      // Act & Assert
      final result1 = await useCase(score: 10);
      expect(result1.isRight(), true);
      verify(() => mockRepository.saveHighScore(10)).called(1);

      final result2 = await useCase(score: 50);
      expect(result2.isRight(), true);
      verify(() => mockRepository.saveHighScore(50)).called(1);

      final result3 = await useCase(score: 100);
      expect(result3.isRight(), true);
      verify(() => mockRepository.saveHighScore(100)).called(1);
    });
  });
}
