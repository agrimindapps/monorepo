import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/profile_repository.dart';

/// Provider para gerenciamento de estado do perfil do usuário
/// Segue o padrão Provider usado no ReceitaAgro
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  // ===== STATE =====
  bool _isUploading = false;
  bool _isPickingImage = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  ProfileImageResult? _lastUploadResult;

  // ===== GETTERS =====
  bool get isUploading => _isUploading;
  bool get isPickingImage => _isPickingImage;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  ProfileImageResult? get lastUploadResult => _lastUploadResult;
  bool get hasError => _errorMessage != null;
  bool get isLoading => _isUploading || _isPickingImage;

  // Repository getters
  String? get currentProfileImageUrl => _profileRepository.getCurrentProfileImageUrl();
  bool get hasProfileImage => _profileRepository.hasProfileImage();
  String get userInitials => _profileRepository.getUserInitials();
  UserEntity? get currentUser => _profileRepository.currentUser;
  bool get isAuthenticated => _profileRepository.isAuthenticated;
  ProfileImageConfig get config => _profileRepository.config;

  // ===== METHODS =====

  /// Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Selecionar e fazer upload de imagem da galeria
  Future<bool> pickAndUploadFromGallery() async {
    return await _pickAndUpload(() => _profileRepository.pickImageFromGallery());
  }

  /// Capturar e fazer upload de imagem da câmera
  Future<bool> pickAndUploadFromCamera() async {
    return await _pickAndUpload(() => _profileRepository.pickImageFromCamera());
  }

  /// Método genérico para pick e upload
  Future<bool> _pickAndUpload(Future<Result<File>> Function() pickFunction) async {
    if (!isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    try {
      // Picking phase
      _isPickingImage = true;
      _errorMessage = null;
      notifyListeners();

      final pickResult = await pickFunction();
      
      if (pickResult.isError) {
        _setError(pickResult.error!.message);
        return false;
      }

      final imageFile = pickResult.data!;

      // Validation phase
      final validationResult = _profileRepository.validateProfileImage(imageFile);
      if (validationResult.isError) {
        _setError(validationResult.error!.message);
        return false;
      }

      // Upload phase
      _isPickingImage = false;
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      final uploadResult = await _profileRepository.uploadProfileImage(
        imageFile,
        onProgress: _updateProgress,
      );

      if (uploadResult.isError) {
        _setError(uploadResult.error!.message);
        return false;
      }

      // Success
      _lastUploadResult = uploadResult.data;
      _isUploading = false;
      _uploadProgress = 1.0;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('✅ ProfileProvider: Upload bem-sucedido - ${_lastUploadResult?.downloadUrl}');
      }

      return true;

    } catch (e) {
      _setError('Erro inesperado: $e');
      if (kDebugMode) {
        print('❌ ProfileProvider: Erro no upload - $e');
      }
      return false;
    } finally {
      _isPickingImage = false;
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Upload direto de arquivo (para casos especiais)
  Future<bool> uploadProfileImage(File imageFile) async {
    if (!isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();

      // Validation
      final validationResult = _profileRepository.validateProfileImage(imageFile);
      if (validationResult.isError) {
        _setError(validationResult.error!.message);
        return false;
      }

      // Upload
      final uploadResult = await _profileRepository.uploadProfileImage(
        imageFile,
        onProgress: _updateProgress,
      );

      if (uploadResult.isError) {
        _setError(uploadResult.error!.message);
        return false;
      }

      // Success
      _lastUploadResult = uploadResult.data;
      _uploadProgress = 1.0;
      _errorMessage = null;
      notifyListeners();

      return true;

    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Deletar imagem de perfil
  Future<bool> deleteProfileImage() async {
    if (!isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    if (!hasProfileImage) {
      _setError('Nenhuma imagem de perfil para deletar');
      return false;
    }

    try {
      _isUploading = true; // Reutilizamos loading state
      _errorMessage = null;
      notifyListeners();

      final result = await _profileRepository.deleteProfileImage();

      if (result.isError) {
        _setError(result.error!.message);
        return false;
      }

      // Success
      _lastUploadResult = null;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('✅ ProfileProvider: Imagem deletada com sucesso');
      }

      return true;

    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Atualizar apenas a URL da foto no Auth (para casos especiais)
  Future<bool> updateAuthPhotoUrl(String photoUrl) async {
    if (!isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    try {
      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _profileRepository.updateAuthPhotoUrl(photoUrl);

      if (result.isError) {
        _setError(result.error!.message);
        return false;
      }

      _errorMessage = null;
      notifyListeners();

      return true;

    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Validar imagem sem fazer upload
  Result<void> validateImage(File imageFile) {
    return _profileRepository.validateProfileImage(imageFile);
  }

  /// Reset do estado
  void reset() {
    _isUploading = false;
    _isPickingImage = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _lastUploadResult = null;
    notifyListeners();
  }

  // ===== PRIVATE METHODS =====

  void _updateProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isUploading = false;
    _isPickingImage = false;
    notifyListeners();
  }

  // ===== HELPER METHODS =====

  /// Obter status de progresso em texto
  String get progressText {
    if (_isPickingImage) return 'Selecionando imagem...';
    if (_isUploading) {
      final percentage = (_uploadProgress * 100).toInt();
      return 'Enviando... $percentage%';
    }
    return '';
  }

  /// Verificar se pode executar operações
  bool get canPerformOperations => isAuthenticated && !isLoading;

  /// Obter mensagem de status amigável
  String get statusMessage {
    if (hasError) return _errorMessage!;
    if (_isPickingImage) return 'Selecionando imagem...';
    if (_isUploading) return progressText;
    if (_lastUploadResult != null) return 'Upload concluído com sucesso!';
    return '';
  }

  /// Obter cor de status
  Color get statusColor {
    if (hasError) return const Color(0xFFD32F2F); // Red
    if (isLoading) return const Color(0xFF1976D2); // Blue
    if (_lastUploadResult != null) return const Color(0xFF388E3C); // Green
    return const Color(0xFF757575); // Grey
  }
}