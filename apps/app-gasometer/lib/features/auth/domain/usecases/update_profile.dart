import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

@injectable
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

class UpdateProfileParams {

  const UpdateProfileParams({
    this.displayName,
    this.photoUrl,
  });
  final String? displayName;
  final String? photoUrl;
}