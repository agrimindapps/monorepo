import 'dart:io';

import 'package:core/core.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementação do ProfileRepository para ReceitaAgro
/// Utiliza o ProfileImageService do core package
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileImageService _profileImageService;
  final ReceitaAgroAuthProvider _authProvider;

  ProfileRepositoryImpl({
    required ProfileImageService profileImageService,
    required ReceitaAgroAuthProvider authProvider,
  })  : _profileImageService = profileImageService,
        _authProvider = authProvider;

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
    final user = _authProvider.currentUser;
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
  UserEntity? get currentUser => _authProvider.currentUser;

  @override
  bool get isAuthenticated => _authProvider.isAuthenticated;
}