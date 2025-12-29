import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import 'get_recent_params.dart';

/// Use case for fetching recent expenses for a specific vehicle
class GetRecentExpenses implements UseCase<List<ExpenseEntity>, GetRecentParams> {
  const GetRecentExpenses(this.repository);

  final IExpensesRepository repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(
    GetRecentParams params,
  ) async {
    try {
      if (params.vehicleId.trim().isEmpty) {
        return const Left(ValidationFailure('Vehicle ID is required'));
      }

      final expenses = await repository.getRecentExpenses(
        params.vehicleId,
        limit: params.limit,
      );

      return Right(expenses);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Error fetching recent expenses: ${e.toString()}'),
      );
    }
  }
}
