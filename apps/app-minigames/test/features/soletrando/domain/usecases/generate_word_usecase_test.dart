import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:app_minigames/features/soletrando/domain/entities/enums.dart';
import 'package:app_minigames/features/soletrando/domain/entities/word_entity.dart';
import 'package:app_minigames/features/soletrando/domain/repositories/soletrando_repository.dart';
import 'package:app_minigames/features/soletrando/domain/usecases/generate_word_usecase.dart';

class MockSoletrandoRepository extends Mock implements SoletrandoRepository {}

void main() {
  late GenerateWordUseCase useCase;
  late MockSoletrandoRepository mockRepository;

  setUp(() {
    mockRepository = MockSoletrandoRepository();
    useCase = GenerateWordUseCase(mockRepository);
  });

  group('GenerateWordUseCase', () {
    test('should return word for easy difficulty', () async {
      // Arrange
      final word = WordEntity.fromString(
        'UVA',
        category: WordCategory.fruits,
        difficulty: GameDifficulty.easy,
      );

      when(() => mockRepository.getRandomWord(
            difficulty: GameDifficulty.easy,
            category: WordCategory.fruits,
          )).thenAnswer((_) async => Right(word));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.easy,
        category: WordCategory.fruits,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (generatedWord) {
          expect(generatedWord.word, 'UVA');
          expect(generatedWord.length, 3);
          expect(generatedWord.difficulty, GameDifficulty.easy);
        },
      );

      verify(() => mockRepository.getRandomWord(
            difficulty: GameDifficulty.easy,
            category: WordCategory.fruits,
          )).called(1);
    });

    test('should return word for medium difficulty', () async {
      // Arrange
      final word = WordEntity.fromString(
        'BANANA',
        category: WordCategory.fruits,
        difficulty: GameDifficulty.medium,
      );

      when(() => mockRepository.getRandomWord(
            difficulty: GameDifficulty.medium,
            category: WordCategory.fruits,
          )).thenAnswer((_) async => Right(word));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.medium,
        category: WordCategory.fruits,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (generatedWord) {
          expect(generatedWord.word, 'BANANA');
          expect(generatedWord.difficulty, GameDifficulty.medium);
        },
      );
    });

    test('should return word for hard difficulty', () async {
      // Arrange
      final word = WordEntity.fromString(
        'ENGENHEIRO',
        category: WordCategory.professions,
        difficulty: GameDifficulty.hard,
      );

      when(() => mockRepository.getRandomWord(
            difficulty: GameDifficulty.hard,
            category: WordCategory.professions,
          )).thenAnswer((_) async => Right(word));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.hard,
        category: WordCategory.professions,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (generatedWord) {
          expect(generatedWord.word, 'ENGENHEIRO');
          expect(generatedWord.length, greaterThanOrEqualTo(8));
        },
      );
    });

    test('should return ValidationFailure when word is empty', () async {
      // Arrange
      final emptyWord = WordEntity.fromString(
        '',
        category: WordCategory.fruits,
        difficulty: GameDifficulty.easy,
      );

      when(() => mockRepository.getRandomWord(
            difficulty: any(named: 'difficulty'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => Right(emptyWord));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.easy,
        category: WordCategory.fruits,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Palavra gerada está vazia');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when word is too short', () async {
      // Arrange
      final shortWord = WordEntity.fromString(
        'A',
        category: WordCategory.fruits,
        difficulty: GameDifficulty.easy,
      );

      when(() => mockRepository.getRandomWord(
            difficulty: any(named: 'difficulty'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => Right(shortWord));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.easy,
        category: WordCategory.fruits,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Palavra deve ter pelo menos 2 letras');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should propagate repository failure', () async {
      // Arrange
      const failure = CacheFailure('Repository error');

      when(() => mockRepository.getRandomWord(
            difficulty: any(named: 'difficulty'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => const Left(failure));

      const params = GenerateWordParams(
        difficulty: GameDifficulty.medium,
        category: WordCategory.animals,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Repository error');
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
