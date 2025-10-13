import 'dart:io';

import 'package:core/core.dart';

import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../../domain/repositories/profile_repository.dart';

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
  Future<Result<ProfileImageResult>> uploadProfileImage(
    File imageFile, {
    void Function(double)? onProgress,
  }) async {
    return await _profileImageService.uploadProfileImage(
      imageFile,
      onProgress: onProgress,
    );
  }

  @override
  Future<Result<void>> deleteProfileImage() async {
    return await _profileImageService.deleteProfileImage();
  }

  @override
  Future<Result<File>> pickImageFromGallery() async {
    return await _profileImageService.pickImageFromGallery();
  }

  @override
  Future<Result<File>> pickImageFromCamera() async {
    return await _profileImageService.pickImageFromCamera();
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
  Result<void> validateProfileImage(File imageFile) {
    return _profileImageService.validateProfileImage(imageFile);
  }

  @override
  Future<Result<void>> updateAuthPhotoUrl(String photoUrl) async {
    return await _profileImageService.updateAuthPhotoUrl(photoUrl);
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
