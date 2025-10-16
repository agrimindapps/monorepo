import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receituagro_web/core/error/failures.dart';
import 'package:receituagro_web/features/defensivos/domain/entities/defensivo.dart';
import 'package:receituagro_web/features/defensivos/domain/repositories/defensivos_repository.dart';
import 'package:receituagro_web/features/defensivos/domain/usecases/search_defensivos_usecase.dart';

// Mock classes
class MockDefensivosRepository extends Mock implements DefensivosRepository {}

class FakeDefensivo extends Fake implements Defensivo {}

void main() {
  late SearchDefensivosUseCase useCase;
  late MockDefensivosRepository mockRepository;

  // Test data
  final tDefensivos = [
    Defensivo(
      id: '1',
      nomeComum: 'Defensivo Alpha',
      fabricante: 'Fabricante A',
      ingredienteAtivo: 'Ativo A',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Defensivo(
      id: '2',
      nomeComum: 'Zebra Defensivo',
      fabricante: 'Fabricante Z',
      ingredienteAtivo: 'Ativo Z',
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
    Defensivo(
      id: '3',
      nomeComum: 'Beta Defensivo',
      fabricante: 'Fabricante B',
      ingredienteAtivo: 'Ativo B',
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeDefensivo());
  });

  setUp(() {
    mockRepository = MockDefensivosRepository();
    useCase = SearchDefensivosUseCase(mockRepository);
  });

  group('SearchDefensivosUseCase', () {
    test('should search defensivos successfully with valid query', () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'defensivo');
      when(() => mockRepository.searchDefensivos(any()))
          .thenAnswer((_) async => Right(tDefensivos));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (defensivos) {
          expect(defensivos, isA<List<Defensivo>>());
          expect(defensivos.length, 3);
        },
      );
      verify(() => mockRepository.searchDefensivos('defensivo')).called(1);
    });

    test('should return sorted results by name (A-Z)', () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'defensivo');
      when(() => mockRepository.searchDefensivos(any()))
          .thenAnswer((_) async => Right(tDefensivos));

      // Act
      final result = await useCase(params);

      // Assert
      result.fold(
        (_) => fail('Should not return failure'),
        (defensivos) {
          expect(defensivos[0].nomeComum, 'Beta Defensivo');
          expect(defensivos[1].nomeComum, 'Defensivo Alpha');
          expect(defensivos[2].nomeComum, 'Zebra Defensivo');
        },
      );
    });

    test('should return ValidationFailure when query is too short', () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'ab');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('pelo menos 3 caracteres'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.searchDefensivos(any()));
    });

    test('should return ValidationFailure when query is empty', () async {
      // Arrange
      const params = SearchDefensivosParams(query: '');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('obrigatório'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.searchDefensivos(any()));
    });

    test('should return ValidationFailure when query is only whitespace',
        () async {
      // Arrange
      const params = SearchDefensivosParams(query: '   ');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('obrigatório'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.searchDefensivos(any()));
    });

    test('should propagate repository ServerFailure', () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'defensivo');
      when(() => mockRepository.searchDefensivos(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Erro no servidor')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Erro no servidor');
        },
        (_) => fail('Should not succeed'),
      );
      verify(() => mockRepository.searchDefensivos('defensivo')).called(1);
    });

    test('should return empty list when no defensivos found', () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'nonexistent');
      when(() => mockRepository.searchDefensivos(any()))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (defensivos) {
          expect(defensivos, isEmpty);
        },
      );
    });

    test('should handle repository exception and return UnexpectedFailure',
        () async {
      // Arrange
      const params = SearchDefensivosParams(query: 'defensivo');
      when(() => mockRepository.searchDefensivos(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnexpectedFailure>());
          expect(failure.message, contains('Unexpected error'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('should trim whitespace from query before validation', () async {
      // Arrange
      const params = SearchDefensivosParams(query: '  teste  ');
      when(() => mockRepository.searchDefensivos(any()))
          .thenAnswer((_) async => Right(tDefensivos));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.searchDefensivos('  teste  ')).called(1);
    });
  });
}
