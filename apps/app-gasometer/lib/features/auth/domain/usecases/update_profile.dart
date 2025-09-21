import 'package:core/core.dart' hide Failure, UseCase;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class UpdateProfile implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams extends UseCaseParams {
  final String? displayName;
  final String? photoUrl;

  const UpdateProfileParams({
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}