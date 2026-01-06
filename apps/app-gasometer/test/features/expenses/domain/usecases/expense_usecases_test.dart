import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/core/interfaces/i_expenses_repository.dart';
import 'package:gasometer_drift/features/expenses/domain/entities/expense_entity.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/add_expense.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/delete_expense.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/get_all_expenses.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/update_expense.dart';
import 'package:mocktail/mocktail.dart';

class MockExpensesRepository extends Mock implements IExpensesRepository {}

class FakeExpenseEntity extends Fake implements ExpenseEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeExpenseEntity());
  });

  late MockExpensesRepository mockRepository;

  final testExpense = ExpenseEntity(
    id: 'test-id',
    vehicleId: 'vehicle-001',
    type: ExpenseType.maintenance,
    description: 'Troca de óleo',
    amount: 150.0,
    date: DateTime(2024, 1, 15),
    odometer: 15000.0,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
    userId: 'user-001',
    moduleName: 'gasometer',
  );

  setUp(() {
    mockRepository = MockExpensesRepository();
  });

  group('AddExpenseUseCase', () {
    late AddExpenseUseCase useCase;

    setUp(() {
      useCase = AddExpenseUseCase(mockRepository);
    });

    test('should add expense successfully with valid data', () async {
      // Arrange
      when(() => mockRepository.saveExpense(any()))
          .thenAnswer((_) async => testExpense);

      // Act
      final result = await useCase(testExpense);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (expense) {
          expect(expense?.id, testExpense.id);
          expect(expense?.description, testExpense.description);
        },
      );

      verify(() => mockRepository.saveExpense(any())).called(1);
    });

    test('should return ValidationFailure for empty vehicle ID', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(vehicleId: '');

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Veículo'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.saveExpense(any()));
    });

    test('should return ValidationFailure for empty description', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(description: '   ');

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Descrição'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for zero or negative amount', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(amount: 0.0);

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('positivo'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for negative odometer', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(odometer: -100.0);

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Odômetro'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for future date', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final invalidExpense = testExpense.copyWith(date: futureDate);

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('futuro'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for very old date', () async {
      // Arrange
      final oldDate = DateTime(1999, 1, 1);
      final invalidExpense = testExpense.copyWith(date: oldDate);

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('antiga'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return CacheFailure when repository returns null', () async {
      // Arrange
      when(() => mockRepository.saveExpense(any()))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase(testExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should fail'),
      );
    });
  });

  group('GetAllExpensesUseCase', () {
    late GetAllExpensesUseCase useCase;

    setUp(() {
      useCase = GetAllExpensesUseCase(mockRepository);
    });

    test('should get all expenses successfully', () async {
      // Arrange
      final expenses = [testExpense];
      when(() => mockRepository.getAllExpenses())
          .thenAnswer((_) async => expenses);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, testExpense.id);
        },
      );

      verify(() => mockRepository.getAllExpenses()).called(1);
    });

    test('should return expenses sorted by date descending', () async {
      // Arrange
      final expense1 = testExpense.copyWith(date: DateTime(2024, 1, 10));
      final expense2 = testExpense.copyWith(
        id: 'test-id-2',
        date: DateTime(2024, 1, 20),
      );
      final expense3 = testExpense.copyWith(
        id: 'test-id-3',
        date: DateTime(2024, 1, 15),
      );

      when(() => mockRepository.getAllExpenses())
          .thenAnswer((_) async => [expense1, expense2, expense3]);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list[0].date, DateTime(2024, 1, 20)); // Most recent first
          expect(list[1].date, DateTime(2024, 1, 15));
          expect(list[2].date, DateTime(2024, 1, 10)); // Oldest last
        },
      );
    });

    test('should return empty list when no expenses', () async {
      // Arrange
      when(() => mockRepository.getAllExpenses())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) => expect(list.isEmpty, true),
      );
    });

    test('should return failure when repository throws', () async {
      // Arrange
      when(() => mockRepository.getAllExpenses())
          .thenThrow(const CacheFailure('Database error'));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('UpdateExpenseUseCase', () {
    late UpdateExpenseUseCase useCase;

    setUp(() {
      useCase = UpdateExpenseUseCase(mockRepository);
    });

    test('should update expense successfully', () async {
      // Arrange
      final updatedExpense = testExpense.copyWith(description: 'Revisão completa');
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => testExpense);
      when(() => mockRepository.updateExpense(any()))
          .thenAnswer((_) async => updatedExpense);

      // Act
      final result = await useCase(updatedExpense);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (expense) => expect(expense?.description, 'Revisão completa'),
      );

      verify(() => mockRepository.getExpenseById(any())).called(1);
      verify(() => mockRepository.updateExpense(any())).called(1);
    });

    test('should return ValidationFailure for empty ID', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(id: '');

      // Act
      final result = await useCase(invalidExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('ID'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure when expense not found', () async {
      // Arrange
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase(testExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('não encontrada'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return CacheFailure when update fails', () async {
      // Arrange
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => testExpense);
      when(() => mockRepository.updateExpense(any()))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase(testExpense);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should fail'),
      );
    });
  });

  group('DeleteExpenseUseCase', () {
    late DeleteExpenseUseCase useCase;

    setUp(() {
      useCase = DeleteExpenseUseCase(mockRepository);
    });

    test('should delete expense successfully', () async {
      // Arrange
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => testExpense);
      when(() => mockRepository.deleteExpense(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (success) => expect(success, true),
      );

      verify(() => mockRepository.deleteExpense('test-id')).called(1);
    });

    test('should return ValidationFailure for empty ID', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('obrigatório'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.deleteExpense(any()));
    });

    test('should return ValidationFailure when expense not found', () async {
      // Arrange
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase('invalid-id');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('não encontrada'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.deleteExpense(any()));
    });

    test('should handle repository failure', () async {
      // Arrange
      when(() => mockRepository.getExpenseById(any()))
          .thenAnswer((_) async => testExpense);
      when(() => mockRepository.deleteExpense(any()))
          .thenThrow(const CacheFailure('Delete failed'));

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
