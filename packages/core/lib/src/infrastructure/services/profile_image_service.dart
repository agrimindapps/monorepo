import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/profile_image_result.dart';
import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';
import 'image_service.dart';

/// Serviço especializado para manipulação de imagens de perfil
/// Utiliza o ImageService existente e Firebase Auth para atualizações completas
class ProfileImageService {
  final ImageService _imageService;
  final FirebaseAuth _auth;
  final ProfileImageConfig _config;

  /// Criar ProfileImageService com configurações opcionais
  ProfileImageService({
    ImageService? imageService,
    FirebaseAuth? auth,
    ProfileImageConfig config = ProfileImageConfig.defaultAvatar,
  })  : _imageService = imageService ?? ImageService(config: _createImageServiceConfig(config)),
        _auth = auth ?? FirebaseAuth.instance,
        _config = config;

  /// Converte ProfileImageConfig para ImageServiceConfig
  static ImageServiceConfig _createImageServiceConfig(ProfileImageConfig config) {
    return ImageServiceConfig(
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      imageQuality: config.imageQuality,
      maxFileSizeInMB: config.maxFileSizeInMB,
      allowedFormats: config.allowedFormats,
      defaultFolder: 'profile',
      folders: {'profile': 'profile'},
    );
  }

  /// Selecionar imagem da galeria
  Future<Result<File>> pickImageFromGallery() async {
    return await _imageService.pickImageFromGallery();
  }

  /// Capturar imagem da câmera
  Future<Result<File>> pickImageFromCamera() async {
    return await _imageService.pickImageFromCamera();
  }

  /// Upload completo de imagem de perfil
  /// Faz upload para Firebase Storage e atualiza photoURL no Firebase Auth
  Future<Result<ProfileImageResult>> uploadProfileImage(
    File imageFile, {
    String? userId,
    void Function(double)? onProgress,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Future.error(
          AuthenticationError(message: 'Usuário não autenticado'),
        );
      }

      final targetUserId = userId ?? currentUser.uid;
      final validationResult = _imageService.validateImage(imageFile);
      if (validationResult.isError) {
        return Future.error(validationResult.error!);
      }
      final storagePath = _config.getStoragePathForUser(targetUserId);
      const fileName = 'avatar.jpg'; // Nome fixo para facilitar cache e substituição
      final uploadResult = await _imageService.uploadImage(
        imageFile,
        folder: storagePath,
        fileName: fileName,
        uploadType: 'profile',
        onProgress: onProgress,
      );

      if (uploadResult.isError) {
        return Future.error(uploadResult.error!);
      }

      final imageUploadResult = uploadResult.data!;
      if (targetUserId == currentUser.uid) {
        try {
          await currentUser.updatePhotoURL(imageUploadResult.downloadUrl);
          await currentUser.reload();
        } catch (e) {
          print('⚠️ ProfileImageService: Erro ao atualizar photoURL no Auth: $e');
        }
      }
      final profileResult = ProfileImageResult.fromUploadResult(
        downloadUrl: imageUploadResult.downloadUrl,
        fileName: imageUploadResult.fileName,
        userId: targetUserId,
        fileSizeInBytes: imageFile.lengthSync(),
        contentType: _getContentType(imageFile.path),
      );

      return profileResult;
    });
  }

  /// Deletar imagem de perfil atual
  /// Remove do Firebase Storage e limpa photoURL do Firebase Auth
  Future<Result<void>> deleteProfileImage({String? userId}) async {
    return ResultUtils.tryExecuteAsync(() async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Future.error(
          AuthenticationError(message: 'Usuário não autenticado'),
        );
      }

      final targetUserId = userId ?? currentUser.uid;
      String? currentPhotoUrl;
      if (targetUserId == currentUser.uid) {
        currentPhotoUrl = currentUser.photoURL;
      }
      if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
        final deleteResult = await _imageService.deleteImage(currentPhotoUrl);
        if (deleteResult.isError) {
          print('⚠️ ProfileImageService: Erro ao deletar do Storage: ${deleteResult.error}');
        }
      }
      if (targetUserId == currentUser.uid) {
        try {
          await currentUser.updatePhotoURL(null);
          await currentUser.reload();
        } catch (e) {
          return Future.error(
            ExternalServiceError(
              message: 'Erro ao atualizar perfil do usuário',
              details: e.toString(),
              serviceName: 'Firebase Auth',
            ),
          );
        }
      }
    });
  }

  /// Atualizar apenas photoURL no Firebase Auth
  /// Útil quando a imagem já foi uploadada externamente
  Future<Result<void>> updateAuthPhotoUrl(String photoUrl) async {
    return ResultUtils.tryExecuteAsync(() async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Future.error(
          AuthenticationError(message: 'Usuário não autenticado'),
        );
      }

      try {
        await currentUser.updatePhotoURL(photoUrl);
        await currentUser.reload();
      } catch (e) {
        return Future.error(
          ExternalServiceError(
            message: 'Erro ao atualizar photoURL',
            details: e.toString(),
            serviceName: 'Firebase Auth',
          ),
        );
      }
    });
  }

  /// Obter URL da imagem de perfil atual
  String? getCurrentProfileImageUrl() {
    return _auth.currentUser?.photoURL;
  }

  /// Verificar se usuário tem imagem de perfil
  bool hasProfileImage() {
    final photoUrl = getCurrentProfileImageUrl();
    return photoUrl != null && photoUrl.isNotEmpty;
  }

  /// Obter iniciais do nome para fallback
  String getUserInitials([String? displayName]) {
    final user = _auth.currentUser;
    final name = displayName ?? user?.displayName ?? user?.email ?? '?';
    
    if (name.isEmpty || name == '?') return '?';
    
    final words = name.split(' ').where((word) => word.isNotEmpty).toList();
    
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Comprimir imagem antes do upload
  Future<Result<File>> compressImage(File imageFile) async {
    return await _imageService.compressImage(imageFile);
  }

  /// Validar imagem de perfil
  Result<void> validateProfileImage(File imageFile) {
    return _imageService.validateImage(imageFile);
  }

  /// Obter configuração atual
  ProfileImageConfig get config => _config;

  /// Determinar content type baseado na extensão
  String _getContentType(String filePath) {
    final extension = _getFileExtension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Extrair extensão do arquivo
  String _getFileExtension(String filePath) {
    final int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return filePath.substring(lastDotIndex);
  }

  /// Cleanup de imagens antigas (para casos especiais)
  /// Remove todas as imagens de perfil do usuário no Storage
  Future<Result<void>> cleanupOldProfileImages({String? userId}) async {
    return ResultUtils.tryExecuteAsync(() async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Future.error(
          AuthenticationError(message: 'Usuário não autenticado'),
        );
      }

      final targetUserId = userId ?? currentUser.uid;
      final storagePath = _config.getStoragePathForUser(targetUserId);

      try {
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        final listResult = await storageRef.listAll();
        for (final item in listResult.items) {
          try {
            await item.delete();
            print('🗑️ ProfileImageService: Deleted old profile image: ${item.name}');
          } catch (e) {
            print('⚠️ ProfileImageService: Failed to delete ${item.name}: $e');
          }
        }
      } catch (e) {
        return Future.error(
          ExternalServiceError(
            message: 'Erro ao limpar imagens antigas',
            details: e.toString(),
            serviceName: 'Firebase Storage',
          ),
        );
      }
    });
  }
}

/// Factory para criar ProfileImageService com configurações predefinidas
abstract class ProfileImageServiceFactory {
  /// Criar serviço com configuração padrão
  static ProfileImageService createDefault() {
    return ProfileImageService(
      config: ProfileImageConfig.defaultAvatar,
    );
  }

  /// Criar serviço otimizado para mobile
  static ProfileImageService createOptimized() {
    return ProfileImageService(
      config: ProfileImageConfig.optimized,
    );
  }

  /// Criar serviço de alta qualidade
  static ProfileImageService createHighQuality() {
    return ProfileImageService(
      config: ProfileImageConfig.highQuality,
    );
  }

  /// Criar serviço com configuração customizada
  static ProfileImageService createCustom(ProfileImageConfig config) {
    return ProfileImageService(config: config);
  }
}
