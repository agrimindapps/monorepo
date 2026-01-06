import 'package:core/core.dart';

class UpdateProfileUseCase {
  final IAuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    String? displayName,
    String? photoUrl,
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
