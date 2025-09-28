import 'package:core/core.dart' hide Failure, UseCase;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class UpdateProfile implements UseCase<UserEntity, UpdateProfileParams> {

  UpdateProfile(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams extends UseCaseParams {

  const UpdateProfileParams({
    this.displayName,
    this.photoUrl,
  });
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [displayName, photoUrl];
}