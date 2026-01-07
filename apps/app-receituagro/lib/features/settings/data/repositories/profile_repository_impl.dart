import 'package:core/core.dart' hide Column;

import '../../../../core/providers/auth_state.dart' as local;
import '../../domain/repositories/profile_repository.dart';

/// Implementação do ProfileRepository para ReceitaAgro
/// Cross-platform: funciona em Web, Mobile e Desktop
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileImageService _profileImageService;
  final local.AuthState? Function() _getAuthState;

  ProfileRepositoryImpl({
    required ProfileImageService profileImageService,
    required local.AuthState? Function() getAuthState,
  }) : _profileImageService = profileImageService,
       _getAuthState = getAuthState;

  @override
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    PickedImage image, {
    void Function(double)? onProgress,
  }) async {
    return _profileImageService.uploadProfileImage(
      image,
      onProgress: onProgress,
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteProfileImage() async {
    return _profileImageService.deleteProfileImage();
  }

  @override
  Future<Either<Failure, PickedImage>> pickImageFromGallery() async {
    return _profileImageService.pickImageFromGallery();
  }

  @override
  Future<Either<Failure, PickedImage>> pickImageFromCamera() async {
    return _profileImageService.pickImageFromCamera();
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
  Either<Failure, Unit> validateProfileImage(PickedImage image) {
    return _profileImageService.validateProfileImage(image);
  }

  @override
  Future<Either<Failure, Unit>> updateAuthPhotoUrl(String photoUrl) async {
    return _profileImageService.updateAuthPhotoUrl(photoUrl);
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
