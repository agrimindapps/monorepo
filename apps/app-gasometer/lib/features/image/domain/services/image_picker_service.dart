import 'package:flutter/material.dart';

/// Serviço centralizado para seleção de imagens
///
/// Centraliza a lógica do modal de seleção de imagem que estava
/// duplicada em múltiplos formulários (fuel, expenses, maintenance).
///
/// Fornece interface consistente para:
/// - Seleção via câmera
/// - Seleção via galeria
/// - Cancelamento da operação
/// - Customização de textos e ícones
///
/// Exemplo de uso:
/// ```dart
/// await ImagePickerService.showSelectionModal(
///   context,
///   onCameraSelected: () => provider.captureImage(),
///   onGallerySelected: () => provider.selectFromGallery(),
/// );
/// ```
class ImagePickerService {
  /// Mostra modal de seleção de imagem com opções padrão
  static Future<void> showSelectionModal(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onCancelled,
    String? title,
    ImagePickerTexts? customTexts,
    bool isDismissible = true,
  }) async {
    final texts = customTexts ?? ImagePickerTexts.defaultTexts();

    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            title ?? 'Selecionar imagem',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(
                context,
                icon: Icons.camera_alt,
                title: texts.cameraTitle,
                subtitle: texts.cameraSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  onCameraSelected();
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                icon: Icons.photo_library,
                title: texts.galleryTitle,
                subtitle: texts.gallerySubtitle,
                onTap: () {
                  Navigator.pop(context);
                  onGallerySelected();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onCancelled?.call();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(texts.cancelTitle),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Variação específica para comprovantes/recibos
  static Future<void> showReceiptPickerModal(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onCancelled,
  }) async {
    return showSelectionModal(
      context,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onCancelled: onCancelled,
      title: 'Adicionar Comprovante',
      customTexts: ImagePickerTexts.receiptTexts(),
    );
  }

  /// Variação específica para fotos de veículos
  static Future<void> showVehiclePhotoModal(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onCancelled,
  }) async {
    return showSelectionModal(
      context,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onCancelled: onCancelled,
      title: 'Foto do Veículo',
      customTexts: ImagePickerTexts.vehicleTexts(),
    );
  }

  /// Mostra modal simplificado com apenas as opções principais
  static Future<void> showSimpleModal(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
  }) async {
    return showSelectionModal(
      context,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      title: 'Selecionar imagem',
      customTexts: const ImagePickerTexts(
        cameraTitle: 'Câmera',
        cameraSubtitle: 'Tirar nova foto',
        galleryTitle: 'Galeria',
        gallerySubtitle: 'Escolher da galeria',
        cancelTitle: 'Cancelar',
      ),
    );
  }
}

/// Classe para customização de textos do modal
class ImagePickerTexts {

  const ImagePickerTexts({
    required this.cameraTitle,
    required this.cameraSubtitle,
    required this.galleryTitle,
    required this.gallerySubtitle,
    required this.cancelTitle,
  });

  /// Textos padrão
  factory ImagePickerTexts.defaultTexts() {
    return const ImagePickerTexts(
      cameraTitle: 'Câmera',
      cameraSubtitle: 'Tirar uma nova foto',
      galleryTitle: 'Galeria',
      gallerySubtitle: 'Escolher da galeria',
      cancelTitle: 'Cancelar',
    );
  }

  /// Textos específicos para comprovantes
  factory ImagePickerTexts.receiptTexts() {
    return const ImagePickerTexts(
      cameraTitle: 'Fotografar Comprovante',
      cameraSubtitle: 'Tirar foto do recibo/nota',
      galleryTitle: 'Escolher da Galeria',
      gallerySubtitle: 'Selecionar imagem existente',
      cancelTitle: 'Cancelar',
    );
  }

  /// Textos específicos para fotos de veículos
  factory ImagePickerTexts.vehicleTexts() {
    return const ImagePickerTexts(
      cameraTitle: 'Fotografar Veículo',
      cameraSubtitle: 'Tirar nova foto',
      galleryTitle: 'Galeria de Fotos',
      gallerySubtitle: 'Escolher foto existente',
      cancelTitle: 'Cancelar',
    );
  }
  final String cameraTitle;
  final String cameraSubtitle;
  final String galleryTitle;
  final String gallerySubtitle;
  final String cancelTitle;
}

/// Resultado da seleção de imagem
enum ImagePickerResult {
  camera,
  gallery,
  cancelled,
}

/// Extensão para facilitar o uso do serviço
extension ImagePickerServiceExtensions on BuildContext {
  /// Atalho para mostrar modal de seleção de imagem
  Future<void> showImagePicker({
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onCancelled,
    String? title,
    ImagePickerTexts? customTexts,
  }) async {
    return ImagePickerService.showSelectionModal(
      this,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onCancelled: onCancelled,
      title: title,
      customTexts: customTexts,
    );
  }

  /// Atalho para modal de comprovante
  Future<void> showReceiptPicker({
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
    VoidCallback? onCancelled,
  }) async {
    return ImagePickerService.showReceiptPickerModal(
      this,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onCancelled: onCancelled,
    );
  }
}
