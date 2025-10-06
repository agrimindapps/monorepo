import 'dart:io';

import 'package:core/core.dart';

import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementação do ProfileRepository para ReceitaAgro
/// Utiliza o ProfileImageService do core package
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileImageService _profileImageService;
  final ReceitaAgroAuthNotifier _authNotifier;

  ProfileRepositoryImpl({
    required ProfileImageService profileImageService,
    required ReceitaAgroAuthNotifier authNotifier,
  })  : _profileImageService = profileImageService,
        _authNotifier = authNotifier;

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
    final user = _authNotifier.state.value?.currentUser;
    return _profileImageService.getUserInitials(user?.displayName ?? user?.email);
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
  UserEntity? get currentUser => _authNotifier.state.value?.currentUser;

  @override
  bool get isAuthenticated => _authNotifier.state.value?.isAuthenticated ?? false;
}
