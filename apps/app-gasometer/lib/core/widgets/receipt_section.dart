import 'package:flutter/material.dart';

import '../../features/expenses/presentation/widgets/receipt_image_picker.dart';
import '../../features/image/domain/services/image_picker_service.dart';
import '../theme/design_tokens.dart';
import 'form_section_header.dart';

/// Seção unificada para upload de comprovantes/recibos
///
/// Centraliza toda a lógica de exibição e gerenciamento de comprovantes
/// que estava duplicada em múltiplos formulários (fuel, expenses, maintenance).
///
/// Características:
/// - Header padronizado com título e ícone
/// - Integração com ReceiptImagePicker existente
/// - Estados de loading, erro e sucesso
/// - Modal de seleção de imagem centralizado
/// - Indicadores visuais consistentes
///
/// Exemplo de uso:
/// ```dart
/// ReceiptSection(
///   imagePath: provider.receiptImagePath,
///   hasImage: provider.hasReceiptImage,
///   isUploading: provider.isUploadingImage,
///   uploadError: provider.imageUploadError,
///   onImageSelected: () => provider.captureReceiptImage(),
///   onImageRemoved: () => provider.removeReceiptImage(),
/// )
/// ```
class ReceiptSection extends StatelessWidget {

  const ReceiptSection({
    super.key,
    this.imagePath,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadError,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onImageRemoved,
    this.title = 'Comprovante',
    this.description,
    this.required = false,
    this.icon = Icons.receipt,
    this.showStatusIndicators = true,
    this.placeholderText,
  });
  /// Caminho da imagem atual (se houver)
  final String? imagePath;

  /// Se há uma imagem selecionada
  final bool hasImage;

  /// Se está fazendo upload da imagem
  final bool isUploading;

  /// Erro no upload da imagem (se houver)
  final String? uploadError;

  /// Callback quando imagem é selecionada via câmera
  final VoidCallback? onCameraSelected;

  /// Callback quando imagem é selecionada via galeria
  final VoidCallback? onGallerySelected;

  /// Callback quando imagem é removida
  final VoidCallback? onImageRemoved;

  /// Título da seção (padrão: "Comprovante")
  final String title;

  /// Descrição/instrução da seção
  final String? description;

  /// Se a seção é obrigatória
  final bool required;

  /// Ícone da seção (padrão: Icons.receipt)
  final IconData icon;

  /// Se deve mostrar indicadores de status
  final bool showStatusIndicators;

  /// Texto customizado para o placeholder
  final String? placeholderText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormSectionHeader(
      title: required ? '$title *' : title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null) ...[
            Text(
              description!,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeCaption,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: GasometerDesignTokens.spacingSm),
          ],
          ReceiptImagePicker(
            imagePath: imagePath,
            hasImage: hasImage,
            onImageSelected: () => _showImagePickerModal(context),
            onImageRemoved: onImageRemoved ?? () {},
          ),
          if (showStatusIndicators) ...[
            if (isUploading) _buildUploadingIndicator(context),
            if (uploadError != null) _buildErrorIndicator(uploadError!, context),
          ],
        ],
      ),
    );
  }

  /// Mostra modal de seleção de imagem
  void _showImagePickerModal(BuildContext context) {
    ImagePickerService.showReceiptPickerModal(
      context,
      onCameraSelected: () {
        onCameraSelected?.call();
      },
      onGallerySelected: () {
        onGallerySelected?.call();
      },
    );
  }

  /// Indicador de upload em progresso
  Widget _buildUploadingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: GasometerDesignTokens.spacingSm),
          Text(
            'Processando imagem...',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeSm,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de erro no upload
  Widget _buildErrorIndicator(String error, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: GasometerDesignTokens.spacingSm),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeSm,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Variação específica para comprovantes obrigatórios
class RequiredReceiptSection extends StatelessWidget {

  const RequiredReceiptSection({
    super.key,
    this.imagePath,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadError,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onImageRemoved,
    this.title,
  });
  final String? imagePath;
  final bool hasImage;
  final bool isUploading;
  final String? uploadError;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;
  final VoidCallback? onImageRemoved;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return ReceiptSection(
      imagePath: imagePath,
      hasImage: hasImage,
      isUploading: isUploading,
      uploadError: uploadError,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onImageRemoved: onImageRemoved,
      title: title ?? 'Comprovante',
      required: true,
      description: 'Anexe uma foto do comprovante (obrigatório)',
    );
  }
}

/// Variação específica para comprovantes opcionais
class OptionalReceiptSection extends StatelessWidget {

  const OptionalReceiptSection({
    super.key,
    this.imagePath,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadError,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onImageRemoved,
    this.title,
    this.description,
  });
  final String? imagePath;
  final bool hasImage;
  final bool isUploading;
  final String? uploadError;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;
  final VoidCallback? onImageRemoved;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return ReceiptSection(
      imagePath: imagePath,
      hasImage: hasImage,
      isUploading: isUploading,
      uploadError: uploadError,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onImageRemoved: onImageRemoved,
      title: title ?? 'Comprovante',
      required: false,
      description: description ?? 'Anexe uma foto do comprovante (opcional)',
    );
  }
}

/// Variação para documentos do veículo
class VehicleDocumentSection extends StatelessWidget {

  const VehicleDocumentSection({
    super.key,
    this.imagePath,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadError,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onImageRemoved,
  });
  final String? imagePath;
  final bool hasImage;
  final bool isUploading;
  final String? uploadError;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;
  final VoidCallback? onImageRemoved;

  @override
  Widget build(BuildContext context) {
    return ReceiptSection(
      imagePath: imagePath,
      hasImage: hasImage,
      isUploading: isUploading,
      uploadError: uploadError,
      onCameraSelected: onCameraSelected,
      onGallerySelected: onGallerySelected,
      onImageRemoved: onImageRemoved,
      title: 'Documentos',
      icon: Icons.description,
      required: false,
      description: 'Foto dos documentos do veículo (opcional)',
      placeholderText: 'Adicionar foto dos documentos',
    );
  }
}
