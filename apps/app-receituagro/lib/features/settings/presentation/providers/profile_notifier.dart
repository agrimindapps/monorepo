import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/repositories/profile_repository.dart';

part 'profile_notifier.g.dart';

/// Profile state
class ProfileState {
  final bool isUploading;
  final bool isPickingImage;
  final double uploadProgress;
  final String? errorMessage;
  final ProfileImageResult? lastUploadResult;
  final String? currentProfileImageUrl;
  final bool hasProfileImage;
  final String userInitials;
  final UserEntity? currentUser;
  final bool isAuthenticated;

  const ProfileState({
    required this.isUploading,
    required this.isPickingImage,
    required this.uploadProgress,
    this.errorMessage,
    this.lastUploadResult,
    this.currentProfileImageUrl,
    required this.hasProfileImage,
    required this.userInitials,
    this.currentUser,
    required this.isAuthenticated,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isUploading: false,
      isPickingImage: false,
      uploadProgress: 0.0,
      errorMessage: null,
      lastUploadResult: null,
      currentProfileImageUrl: null,
      hasProfileImage: false,
      userInitials: '',
      currentUser: null,
      isAuthenticated: false,
    );
  }

  ProfileState copyWith({
    bool? isUploading,
    bool? isPickingImage,
    double? uploadProgress,
    String? errorMessage,
    ProfileImageResult? lastUploadResult,
    String? currentProfileImageUrl,
    bool? hasProfileImage,
    String? userInitials,
    UserEntity? currentUser,
    bool? isAuthenticated,
  }) {
    return ProfileState(
      isUploading: isUploading ?? this.isUploading,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUploadResult: lastUploadResult ?? this.lastUploadResult,
      currentProfileImageUrl:
          currentProfileImageUrl ?? this.currentProfileImageUrl,
      hasProfileImage: hasProfileImage ?? this.hasProfileImage,
      userInitials: userInitials ?? this.userInitials,
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  ProfileState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get hasError => errorMessage != null;
  bool get isLoading => isUploading || isPickingImage;
  bool get canPerformOperations => isAuthenticated && !isLoading;

  /// Obter status de progresso em texto
  String get progressText {
    if (isPickingImage) return 'Selecionando imagem...';
    if (isUploading) {
      final percentage = (uploadProgress * 100).toInt();
      return 'Enviando... $percentage%';
    }
    return '';
  }

  /// Obter mensagem de status amigável
  String get statusMessage {
    if (hasError) return errorMessage!;
    if (isPickingImage) return 'Selecionando imagem...';
    if (isUploading) return progressText;
    if (lastUploadResult != null) return 'Upload concluído com sucesso!';
    return '';
  }

  /// Obter cor de status
  Color get statusColor {
    if (hasError) return const Color(0xFFD32F2F); // Red
    if (isLoading) return const Color(0xFF1976D2); // Blue
    if (lastUploadResult != null) return const Color(0xFF388E3C); // Green
    return const Color(0xFF757575); // Grey
  }
}

/// Profile notifier for user profile management
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  late final ProfileRepository _profileRepository;

  @override
  Future<ProfileState> build() async {
    _profileRepository = di.sl<ProfileRepository>();
    return ProfileState(
      isUploading: false,
      isPickingImage: false,
      uploadProgress: 0.0,
      errorMessage: null,
      lastUploadResult: null,
      currentProfileImageUrl: _profileRepository.getCurrentProfileImageUrl(),
      hasProfileImage: _profileRepository.hasProfileImage(),
      userInitials: _profileRepository.getUserInitials(),
      currentUser: _profileRepository.currentUser,
      isAuthenticated: _profileRepository.isAuthenticated,
    );
  }

  /// Get config
  ProfileImageConfig get config => _profileRepository.config;

  /// Limpar erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(currentState.clearError());
  }

  /// Selecionar e fazer upload de imagem da galeria
  Future<bool> pickAndUploadFromGallery() async {
    return await _pickAndUpload(
      () => _profileRepository.pickImageFromGallery(),
    );
  }

  /// Capturar e fazer upload de imagem da câmera
  Future<bool> pickAndUploadFromCamera() async {
    return await _pickAndUpload(() => _profileRepository.pickImageFromCamera());
  }

  Future<bool> _pickAndUpload(
    Future<Result<File>> Function() pickFunction,
  ) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (!currentState.isAuthenticated) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Usuário não autenticado'),
      );
      return false;
    }

    try {
      state = AsyncValue.data(
        currentState.copyWith(isPickingImage: true).clearError(),
      );

      final pickResult = await pickFunction();

      if (pickResult.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isPickingImage: false,
            errorMessage: pickResult.error!.message,
          ),
        );
        return false;
      }

      final imageFile = pickResult.data!;
      final validationResult = _profileRepository.validateProfileImage(
        imageFile,
      );
      if (validationResult.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isPickingImage: false,
            errorMessage: validationResult.error!.message,
          ),
        );
        return false;
      }
      state = AsyncValue.data(
        currentState.copyWith(
          isPickingImage: false,
          isUploading: true,
          uploadProgress: 0.0,
        ),
      );

      final uploadResult = await _profileRepository.uploadProfileImage(
        imageFile,
        onProgress: _updateProgress,
      );

      if (uploadResult.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isUploading: false,
            errorMessage: uploadResult.error!.message,
          ),
        );
        return false;
      }
      final updatedState = await _refreshState();
      state = AsyncValue.data(
        updatedState
            .copyWith(
              isUploading: false,
              uploadProgress: 1.0,
              lastUploadResult: uploadResult.data,
            )
            .clearError(),
      );

      if (kDebugMode) {
        print(
          '✅ ProfileNotifier: Upload bem-sucedido - ${uploadResult.data?.downloadUrl}',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileNotifier: Erro no upload - $e');
      }
      state = AsyncValue.data(
        currentState.copyWith(
          isPickingImage: false,
          isUploading: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
      return false;
    }
  }

  /// Upload direto de arquivo (para casos especiais)
  Future<bool> uploadProfileImage(File imageFile) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (!currentState.isAuthenticated) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Usuário não autenticado'),
      );
      return false;
    }

    try {
      state = AsyncValue.data(
        currentState
            .copyWith(isUploading: true, uploadProgress: 0.0)
            .clearError(),
      );
      final validationResult = _profileRepository.validateProfileImage(
        imageFile,
      );
      if (validationResult.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isUploading: false,
            errorMessage: validationResult.error!.message,
          ),
        );
        return false;
      }
      final uploadResult = await _profileRepository.uploadProfileImage(
        imageFile,
        onProgress: _updateProgress,
      );

      if (uploadResult.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isUploading: false,
            errorMessage: uploadResult.error!.message,
          ),
        );
        return false;
      }
      final updatedState = await _refreshState();
      state = AsyncValue.data(
        updatedState
            .copyWith(
              isUploading: false,
              uploadProgress: 1.0,
              lastUploadResult: uploadResult.data,
            )
            .clearError(),
      );

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isUploading: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
      return false;
    }
  }

  /// Deletar imagem de perfil
  Future<bool> deleteProfileImage() async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (!currentState.isAuthenticated) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Usuário não autenticado'),
      );
      return false;
    }

    if (!currentState.hasProfileImage) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Nenhuma imagem de perfil para deletar',
        ),
      );
      return false;
    }

    try {
      state = AsyncValue.data(
        currentState.copyWith(isUploading: true).clearError(),
      );

      final result = await _profileRepository.deleteProfileImage();

      if (result.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isUploading: false,
            errorMessage: result.error!.message,
          ),
        );
        return false;
      }
      final updatedState = await _refreshState();
      state = AsyncValue.data(
        updatedState
            .copyWith(isUploading: false, lastUploadResult: null)
            .clearError(),
      );

      if (kDebugMode) {
        print('✅ ProfileNotifier: Imagem deletada com sucesso');
      }

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isUploading: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
      return false;
    }
  }

  /// Atualizar apenas a URL da foto no Auth (para casos especiais)
  Future<bool> updateAuthPhotoUrl(String photoUrl) async {
    final currentState = state.value;
    if (currentState == null) return false;

    if (!currentState.isAuthenticated) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Usuário não autenticado'),
      );
      return false;
    }

    try {
      state = AsyncValue.data(
        currentState.copyWith(isUploading: true).clearError(),
      );

      final result = await _profileRepository.updateAuthPhotoUrl(photoUrl);

      if (result.isError) {
        state = AsyncValue.data(
          currentState.copyWith(
            isUploading: false,
            errorMessage: result.error!.message,
          ),
        );
        return false;
      }
      final updatedState = await _refreshState();
      state = AsyncValue.data(
        updatedState.copyWith(isUploading: false).clearError(),
      );

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isUploading: false,
          errorMessage: 'Erro inesperado: $e',
        ),
      );
      return false;
    }
  }

  /// Validar imagem sem fazer upload
  Result<void> validateImage(File imageFile) {
    return _profileRepository.validateProfileImage(imageFile);
  }

  /// Reset do estado
  void reset() {
    state = AsyncValue.data(ProfileState.initial());
  }

  void _updateProgress(double progress) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(currentState.copyWith(uploadProgress: progress));
  }

  /// Refresh state from repository
  Future<ProfileState> _refreshState() async {
    return ProfileState(
      isUploading: false,
      isPickingImage: false,
      uploadProgress: 0.0,
      errorMessage: null,
      lastUploadResult: null,
      currentProfileImageUrl: _profileRepository.getCurrentProfileImageUrl(),
      hasProfileImage: _profileRepository.hasProfileImage(),
      userInitials: _profileRepository.getUserInitials(),
      currentUser: _profileRepository.currentUser,
      isAuthenticated: _profileRepository.isAuthenticated,
    );
  }
}
