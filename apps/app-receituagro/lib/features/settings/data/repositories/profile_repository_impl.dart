import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide Column;

import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../../domain/repositories/profile_repository.dart';

/// Conversão de Result<T> para Either<Failure, T>
/// Bridge function to convert core package Result to Either
// ignore: deprecated_member_use
Either<Failure, T> _resultToEither<T>(Result<T> result) {
  if (result.isError) {
    return Left(ServerFailure(result.error!.message));
  }
  return Right(result.data as T);
}

/// Conversão de Result<void> para Either<Failure, Unit>
/// Bridge function to convert core package Result to Either
// ignore: deprecated_member_use
Either<Failure, Unit> _resultToEitherUnit(Result<void> result) {
  if (result.isError) {
    return Left(ServerFailure(result.error!.message));
  }
  return const Right(unit);
}

/// Conversão async de Result<T> para Either<Failure, T>
/// Bridge function to convert core package Result to Either
Future<Either<Failure, T>> _resultToEitherAsync<T>(
  // ignore: deprecated_member_use
  Future<Result<T>> futureResult,
) async {
  final result = await futureResult;
  return _resultToEither(result);
}

/// Conversão async de Result<void> para Either<Failure, Unit>
/// Bridge function to convert core package Result to Either
Future<Either<Failure, Unit>> _resultToEitherUnitAsync(
  // ignore: deprecated_member_use
  Future<Result<void>> futureResult,
) async {
  final result = await futureResult;
  return _resultToEitherUnit(result);
}

/// Implementação do ProfileRepository para ReceitaAgro
/// Utiliza o ProfileImageService do core package
/// NOTE: Cannot use @injectable due to function type dependency
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileImageService _profileImageService;
  final ReceitaAgroAuthState? Function() _getAuthState;

  ProfileRepositoryImpl({
    required ProfileImageService profileImageService,
    required ReceitaAgroAuthState? Function() getAuthState,
  }) : _profileImageService = profileImageService,
       _getAuthState = getAuthState;

  @override
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    File imageFile, {
    void Function(double)? onProgress,
  }) async {
    return _resultToEitherAsync(
      _profileImageService.uploadProfileImage(
        imageFile,
        onProgress: onProgress,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteProfileImage() async {
    return _resultToEitherUnitAsync(
      _profileImageService.deleteProfileImage(),
    );
  }

  @override
  Future<Either<Failure, File>> pickImageFromGallery() async {
    return _resultToEitherAsync(
      _profileImageService.pickImageFromGallery(),
    );
  }

  @override
  Future<Either<Failure, File>> pickImageFromCamera() async {
    return _resultToEitherAsync(
      _profileImageService.pickImageFromCamera(),
    );
  }

  @override
  String? getCurrentProfileImageUrl() {
    return _profileImageService.getCurrentProfileImageUrl();
  }

  @override
  bool hasProfileImage() {
    return _profileImageService.hasProfileImage();
  }

  @override
  String getUserInitials() {
    final authState = _getAuthState();
    final user = authState?.currentUser;
    return _profileImageService.getUserInitials(
      user?.displayName ?? user?.email,
    );
  }

  @override
  Either<Failure, Unit> validateProfileImage(File imageFile) {
    return _resultToEitherUnit(
      _profileImageService.validateProfileImage(imageFile),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateAuthPhotoUrl(String photoUrl) async {
    return _resultToEitherUnitAsync(
      _profileImageService.updateAuthPhotoUrl(photoUrl),
    );
  }

  @override
  ProfileImageConfig get config => _profileImageService.config;

  @override
  UserEntity? get currentUser {
    final authState = _getAuthState();
    return authState?.currentUser;
  }

  @override
  bool get isAuthenticated {
    final authState = _getAuthState();
    return authState?.isAuthenticated ?? false;
  }
}
