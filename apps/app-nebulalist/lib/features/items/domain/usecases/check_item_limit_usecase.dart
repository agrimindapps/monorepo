import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../repositories/i_item_master_repository.dart';

/// Use case for checking if user can create more ItemMasters
/// Implements business rules from RN-I005 (BUSINESS_RULES.md)
@injectable
class CheckItemLimitUseCase {
  final IItemMasterRepository _repository;

  CheckItemLimitUseCase(this._repository);

  /// Check if user can create ItemMasters
  /// Free tier: max 200 ItemMasters
  /// Premium: unlimited
  Future<Either<Failure, bool>> call() async {
    return await _repository.canCreateItemMaster();
  }
}
