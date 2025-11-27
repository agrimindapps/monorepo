import 'package:core/core.dart' hide Column;

/// Repository interface para operações de perfil de usuário
/// Cross-platform: funciona em Web, Mobile e Desktop
abstract class ProfileRepository {
  /// Upload de imagem de perfil
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    PickedImage image, {
    void Function(double)? onProgress,
  });

  /// Deletar imagem de perfil atual
  Future<Either<Failure, Unit>> deleteProfileImage();

  /// Selecionar imagem da galeria (Cross-platform)
  Future<Either<Failure, PickedImage>> pickImageFromGallery();

  /// Capturar imagem da câmera (Cross-platform)
  Future<Either<Failure, PickedImage>> pickImageFromCamera();

  /// Obter URL da imagem de perfil atual
  String? getCurrentProfileImageUrl();

  /// Verificar se usuário tem imagem de perfil
  bool hasProfileImage();

  /// Obter iniciais do nome para fallback
  String getUserInitials();

  /// Validar imagem de perfil
  Either<Failure, Unit> validateProfileImage(PickedImage image);

  /// Atualizar apenas photoURL no Firebase Auth
  Future<Either<Failure, Unit>> updateAuthPhotoUrl(String photoUrl);

  /// Obter configuração atual
  ProfileImageConfig get config;

  /// Obter usuário atual
  UserEntity? get currentUser;

  /// Verificar se está autenticado
  bool get isAuthenticated;
}
