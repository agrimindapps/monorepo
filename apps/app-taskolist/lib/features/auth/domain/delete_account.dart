import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'auth_repository.dart';

@lazySingleton
class DeleteAccount extends UseCaseWithoutParams<void> {
  const DeleteAccount(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<void> call() async {
    return _repository.deleteAccount();
  }
}
