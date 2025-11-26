import 'package:core/core.dart';
import '../repositories/i_list_repository.dart';

/// Use case for checking free tier list limits
/// Implements RN-L002 (BUSINESS_RULES.md)
///
/// Free tier: Max 10 active (non-archived) lists
/// Premium: Unlimited lists
class CheckListLimitUseCase {
  final IListRepository _repository;

  CheckListLimitUseCase(this._repository);

  /// Check if user can create a new list
  /// Returns Either<Failure, bool>
  ///
  /// For free tier users:
  /// - Returns true if active lists < 10
  /// - Returns false if limit reached
  ///
  /// For premium users:
  /// - Always returns true
  Future<Either<Failure, bool>> call() async {
    return await _repository.canCreateList();
  }

  /// Get current count of active lists
  Future<Either<Failure, int>> getActiveCount() async {
    return await _repository.getActiveListsCount();
  }
}
