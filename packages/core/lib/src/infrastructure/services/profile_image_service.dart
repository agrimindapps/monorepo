import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/profile_image_result.dart';
import '../../shared/utils/failure.dart';
import 'image_service.dart';

/// Serviço especializado para manipulação de imagens de perfil
/// Cross-platform: funciona em Web, Mobile e Desktop
class ProfileImageService {
  final ImageService _imageService;
  final FirebaseAuth _auth;
  final ProfileImageConfig _config;

  /// Criar ProfileImageService com configurações opcionais
  ProfileImageService({
    ImageService? imageService,
    FirebaseAuth? auth,
    ProfileImageConfig config = ProfileImageConfig.defaultAvatar,
  }) : _imageService =
           imageService ??
           ImageService(config: _createImageServiceConfig(config)),
       _auth = auth ?? FirebaseAuth.instance,
       _config = config;

  /// Converte ProfileImageConfig para ImageServiceConfig
  static ImageServiceConfig _createImageServiceConfig(
    ProfileImageConfig config,
  ) {
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

  /// Selecionar imagem da galeria (Cross-platform)
  Future<Either<Failure, PickedImage>> pickImageFromGallery() async {
    return await _imageService.pickImageFromGallery();
  }

  /// Capturar imagem da câmera (Cross-platform)
  Future<Either<Failure, PickedImage>> pickImageFromCamera() async {
    return await _imageService.pickImageFromCamera();
  }

  /// Upload completo de imagem de perfil (Cross-platform)
  /// Faz upload para Firebase Storage e atualiza photoURL no Firebase Auth
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    PickedImage image, {
    String? userId,
    void Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final targetUserId = userId ?? currentUser.uid;
      final validationResult = _imageService.validatePickedImage(image);

      return validationResult.fold((failure) => Left(failure), (_) async {
        final storagePath = _config.getStoragePathForUser(targetUserId);
        const fileName = 'avatar.jpg';
        final uploadResult = await _imageService.uploadImage(
          image,
          folder: storagePath,
          fileName: fileName,
          uploadType: 'profile',
          onProgress: onProgress,
        );

        return uploadResult.fold((failure) => Left(failure), (
          imageUploadResult,
        ) async {
          if (targetUserId == currentUser.uid) {
            try {
              await currentUser.updatePhotoURL(imageUploadResult.downloadUrl);
              await currentUser.reload();
            } catch (e) {
              debugPrint(
                '⚠️ ProfileImageService: Erro ao atualizar photoURL no Auth: $e',
              );
            }
          }

          final profileResult = ProfileImageResult.fromUploadResult(
            downloadUrl: imageUploadResult.downloadUrl,
            fileName: imageUploadResult.fileName,
            userId: targetUserId,
            fileSizeInBytes: image.sizeInBytes,
            contentType: image.mimeType,
          );

          return Right(profileResult);
        });
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Erro ao processar imagem de perfil: ${e.toString()}',
        ),
      );
    }
  }

  /// Deletar imagem de perfil atual
  /// Remove do Firebase Storage e limpa photoURL do Firebase Auth
  Future<Either<Failure, Unit>> deleteProfileImage({String? userId}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final targetUserId = userId ?? currentUser.uid;
      String? currentPhotoUrl;
      if (targetUserId == currentUser.uid) {
        currentPhotoUrl = currentUser.photoURL;
      }

      if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
        final deleteResult = await _imageService.deleteImage(currentPhotoUrl);
        deleteResult.fold(
          (failure) => debugPrint(
            '⚠️ ProfileImageService: Erro ao deletar do Storage: $failure',
          ),
          (_) => null,
        );
      }

      if (targetUserId == currentUser.uid) {
        try {
          await currentUser.updatePhotoURL(null);
          await currentUser.reload();
        } catch (e) {
          return Left(
            ServerFailure(
              'Erro ao atualizar perfil do usuário',
              details: e.toString(),
            ),
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        UnexpectedFailure('Erro ao deletar imagem de perfil: ${e.toString()}'),
      );
    }
  }

  /// Atualizar apenas photoURL no Firebase Auth
  /// Útil quando a imagem já foi uploadada externamente
  Future<Either<Failure, Unit>> updateAuthPhotoUrl(String photoUrl) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await currentUser.updatePhotoURL(photoUrl);
      await currentUser.reload();

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao atualizar photoURL', details: e.toString()),
      );
    }
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

    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Comprimir imagem antes do upload
  Future<Either<Failure, PickedImage>> compressImage(PickedImage image) async {
    return await _imageService.compressImage(image);
  }

  /// Validar imagem de perfil
  Either<Failure, Unit> validateProfileImage(PickedImage image) {
    return _imageService
        .validatePickedImage(image)
        .fold((failure) => Left(failure), (_) => const Right(unit));
  }

  /// Obter configuração atual
  ProfileImageConfig get config => _config;

  /// Cleanup de imagens antigas (para casos especiais)
  /// Remove todas as imagens de perfil do usuário no Storage
  Future<Either<Failure, Unit>> cleanupOldProfileImages({
    String? userId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final targetUserId = userId ?? currentUser.uid;
      final storagePath = _config.getStoragePathForUser(targetUserId);

      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final listResult = await storageRef.listAll();

      for (final item in listResult.items) {
        try {
          await item.delete();
          debugPrint(
            '🗑️ ProfileImageService: Deleted old profile image: ${item.name}',
          );
        } catch (e) {
          debugPrint(
            '⚠️ ProfileImageService: Failed to delete ${item.name}: $e',
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao limpar imagens antigas', details: e.toString()),
      );
    }
  }
}

/// Factory para criar ProfileImageService com configurações predefinidas
abstract class ProfileImageServiceFactory {
  /// Criar serviço com configuração padrão
  static ProfileImageService createDefault() {
    return ProfileImageService(config: ProfileImageConfig.defaultAvatar);
  }

  /// Criar serviço otimizado para mobile
  static ProfileImageService createOptimized() {
    return ProfileImageService(config: ProfileImageConfig.optimized);
  }

  /// Criar serviço de alta qualidade
  static ProfileImageService createHighQuality() {
    return ProfileImageService(config: ProfileImageConfig.highQuality);
  }

  /// Criar serviço com configuração customizada
  static ProfileImageService createCustom(ProfileImageConfig config) {
    return ProfileImageService(config: config);
  }
}
