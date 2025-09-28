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

    return showModalBottomSheet<void>(
      context: context,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título (opcional)
                if (title != null) ...[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                ],

                // Opção Câmera
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(texts.cameraTitle),
                  subtitle: Text(texts.cameraSubtitle),
                  onTap: () {
                    Navigator.pop(context);
                    onCameraSelected();
                  },
                ),

                // Opção Galeria
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(texts.galleryTitle),
                  subtitle: Text(texts.gallerySubtitle),
                  onTap: () {
                    Navigator.pop(context);
                    onGallerySelected();
                  },
                ),

                // Opção Cancelar
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: Text(texts.cancelTitle),
                  onTap: () {
                    Navigator.pop(context);
                    onCancelled?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  onCameraSelected();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  onGallerySelected();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
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