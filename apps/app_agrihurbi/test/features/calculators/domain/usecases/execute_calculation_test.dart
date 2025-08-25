import 'package:app_agrihurbi/features/calculators/domain/entities/calculation_result.dart';
import 'package:app_agrihurbi/features/calculators/domain/repositories/calculator_repository.dart';
import 'package:app_agrihurbi/features/calculators/domain/usecases/execute_calculation.dart';
import 'package:core/core.dart' as core_lib;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CalculatorRepository])
import 'execute_calculation_test.mocks.dart';

void main() {
  group('ExecuteCalculation', () {
    late ExecuteCalculation usecase;
    late MockCalculatorRepository mockRepository;

    setUp(() {
      mockRepository = MockCalculatorRepository();
      usecase = ExecuteCalculation(mockRepository);
    });

    group('call', () {
      const calculatorId = 'test_calculator';
      final parameters = {'value1': 10.0, 'value2': 20.0};

      test('should return calculation result when repository succeeds', () async {
        // Arrange
        final expectedResult = CalculationResult(
          calculatorId: calculatorId,
          calculatedAt: DateTime.now(),
          inputs: parameters,
          type: ResultType.single,
          values: const [
            CalculationResultValue(
              label: 'Sum',
              value: 30.0,
              unit: '',
            ),
          ],
        );

        when(mockRepository.executeCalculation(calculatorId, parameters))
            .thenAnswer((_) async => Right(expectedResult));

        // Act
        final result = await usecase(calculatorId, parameters);

        // Assert
        expect(result, isA<Right<core_lib.Failure, CalculationResult>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (calculationResult) {
            expect(calculationResult.calculatorId, equals(calculatorId));
            expect(calculationResult.inputs, equals(parameters));
            expect(calculationResult.values.first.value, equals(30.0));
          },
        );

        verify(mockRepository.executeCalculation(calculatorId, parameters));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const failure = core_lib.ValidationFailure('Invalid parameters');
        when(mockRepository.executeCalculation(calculatorId, parameters))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(calculatorId, parameters);

        // Assert
        expect(result, isA<Left<core_lib.Failure, CalculationResult>>());
        result.fold(
          (failure) => expect(failure.message, equals('Invalid parameters')),
          (calculationResult) => fail('Should not return calculation result'),
        );

        verify(mockRepository.executeCalculation(calculatorId, parameters));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should call repository even with empty parameters', () async {
        // Arrange
        final emptyParameters = <String, dynamic>{};
        const failure = core_lib.ValidationFailure('Empty parameters');
        
        when(mockRepository.executeCalculation(calculatorId, emptyParameters))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(calculatorId, emptyParameters);

        // Assert
        expect(result, isA<Left<core_lib.Failure, CalculationResult>>());
        verify(mockRepository.executeCalculation(calculatorId, emptyParameters));
      });

      test('should call repository even with empty calculator id', () async {
        // Arrange
        const failure = core_lib.ValidationFailure('Invalid calculator id');
        
        when(mockRepository.executeCalculation('', parameters))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase('', parameters);

        // Assert
        expect(result, isA<Left<core_lib.Failure, CalculationResult>>());
        verify(mockRepository.executeCalculation('', parameters));
      });
    });
  });
}