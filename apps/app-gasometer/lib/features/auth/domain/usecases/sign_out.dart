import 'package:core/core.dart';
import '../repositories/auth_repository.dart';


class SignOut implements NoParamsUseCase<Unit> {

  SignOut(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}
