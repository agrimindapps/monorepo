import 'dart:io';

import 'package:core/core.dart';

/// Repository interface para operações de perfil de usuário
abstract class ProfileRepository {
  /// Upload de imagem de perfil
  Future<Result<ProfileImageResult>> uploadProfileImage(
    File imageFile, {
    void Function(double)? onProgress,
  });

  /// Deletar imagem de perfil atual
  Future<Result<void>> deleteProfileImage();

  /// Selecionar imagem da galeria
  Future<Result<File>> pickImageFromGallery();

  /// Capturar imagem da câmera
  Future<Result<File>> pickImageFromCamera();

  /// Obter URL da imagem de perfil atual
  String? getCurrentProfileImageUrl();

  /// Verificar se usuário tem imagem de perfil
  bool hasProfileImage();

  /// Obter iniciais do nome para fallback
  String getUserInitials();

  /// Validar imagem de perfil
  Result<void> validateProfileImage(File imageFile);

  /// Atualizar apenas photoURL no Firebase Auth
  Future<Result<void>> updateAuthPhotoUrl(String photoUrl);

  /// Obter configuração atual
  ProfileImageConfig get config;

  /// Obter usuário atual
  UserEntity? get currentUser;

  /// Verificar se está autenticado
  bool get isAuthenticated;
}
