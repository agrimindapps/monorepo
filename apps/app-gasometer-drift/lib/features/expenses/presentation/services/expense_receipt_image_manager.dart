import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// Serviço responsável por gerenciar upload de imagens de recibos
///
/// Isola lógica de seleção, validação e upload de imagens,
/// seguindo o princípio Single Responsibility.
@injectable
class ExpenseReceiptImageManager {
  ExpenseReceiptImageManager(this._imagePicker);

  final ImagePicker _imagePicker;

  /// Tamanho máximo da imagem em bytes (5 MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Formatos de imagem suportados
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  /// Seleciona imagem da galeria
  Future<ImageSelectionResult> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return ImageSelectionResult.cancelled();
      }

      return await _validateAndProcessImage(image);
    } catch (e) {
      return ImageSelectionResult.error('Erro ao selecionar imagem: $e');
    }
  }

  /// Captura imagem da câmera
  Future<ImageSelectionResult> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return ImageSelectionResult.cancelled();
      }

      return await _validateAndProcessImage(image);
    } catch (e) {
      return ImageSelectionResult.error('Erro ao capturar imagem: $e');
    }
  }

  /// Valida e processa a imagem selecionada
  Future<ImageSelectionResult> _validateAndProcessImage(XFile image) async {
    try {
      // Valida formato
      final extension = image.path.split('.').last.toLowerCase();
      if (!supportedFormats.contains(extension)) {
        return ImageSelectionResult.error(
          'Formato não suportado. Use: ${supportedFormats.join(", ")}',
        );
      }

      // Valida tamanho
      final size = await image.length();
      if (size > maxImageSizeBytes) {
        final sizeMB = size / (1024 * 1024);
        return ImageSelectionResult.error(
          'Imagem muito grande (${sizeMB.toStringAsFixed(1)}MB). '
          'Tamanho máximo: 5MB',
        );
      }

      return ImageSelectionResult.success(
        path: image.path,
        sizeBytes: size,
        format: extension,
      );
    } catch (e) {
      return ImageSelectionResult.error('Erro ao processar imagem: $e');
    }
  }

  /// Mostra dialog para escolher fonte da imagem
  Future<ImageSelectionResult?> showImageSourceDialog({
    required Future<ImageSelectionResult> Function() onCamera,
    required Future<ImageSelectionResult> Function() onGallery,
  }) async {
    // Esta função deve ser chamada da UI, não diretamente do serviço
    // Mantida aqui para referência de API
    return null;
  }

  /// Valida se um caminho de arquivo é válido
  bool isValidImagePath(String? path) {
    if (path == null || path.isEmpty) return false;

    final extension = path.split('.').last.toLowerCase();
    return supportedFormats.contains(extension);
  }

  /// Obtém extensão do arquivo
  String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Formata tamanho de arquivo em string legível
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
  }

  /// Verifica se há permissão de câmera (implementar com permission_handler)
  Future<bool> hasCameraPermission() async {
    // TODO: Implementar verificação de permissão
    return true;
  }

  /// Verifica se há permissão de galeria
  Future<bool> hasGalleryPermission() async {
    // TODO: Implementar verificação de permissão
    return true;
  }

  /// Solicita permissão de câmera
  Future<bool> requestCameraPermission() async {
    // TODO: Implementar solicitação de permissão
    return true;
  }

  /// Solicita permissão de galeria
  Future<bool> requestGalleryPermission() async {
    // TODO: Implementar solicitação de permissão
    return true;
  }
}

/// Resultado da seleção de imagem
class ImageSelectionResult {
  final bool isSuccess;
  final String? path;
  final int? sizeBytes;
  final String? format;
  final String? errorMessage;
  final bool isCancelled;

  ImageSelectionResult._({
    // ignore: sort_constructors_first
    required this.isSuccess,
    this.path,
    this.sizeBytes,
    this.format,
    this.errorMessage,
    this.isCancelled = false,
  });

  /// Criação de resultado bem-sucedido
  factory ImageSelectionResult.success({
    // ignore: sort_constructors_first
    required String path,
    required int sizeBytes,
    required String format,
  }) {
    return ImageSelectionResult._(
      isSuccess: true,
      path: path,
      sizeBytes: sizeBytes,
      format: format,
    );
  }

  /// Criação de resultado com erro
  factory ImageSelectionResult.error(String message) {
    // ignore: sort_constructors_first
    return ImageSelectionResult._(isSuccess: false, errorMessage: message);
  }

  /// Criação de resultado cancelado
  factory ImageSelectionResult.cancelled() {
    // ignore: sort_constructors_first
    return ImageSelectionResult._(isSuccess: false, isCancelled: true);
  }

  @override
  String toString() {
    if (isCancelled) return 'ImageSelectionResult(cancelled)';
    if (!isSuccess) return 'ImageSelectionResult(error: $errorMessage)';
    return 'ImageSelectionResult(success: $path, size: $sizeBytes bytes)';
  }
}
