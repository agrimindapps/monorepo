import 'package:core/core.dart' hide UserEntity, Column;

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'auth_repository.dart';
import 'user_entity.dart';

class UpdateProfile extends UseCaseWithParams<void, UpdateProfileParams> {
  const UpdateProfile(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<void> call(UpdateProfileParams params) async {
    return _repository.updateProfile(params.user);
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.user,
  });

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}
