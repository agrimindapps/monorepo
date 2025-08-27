import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_theme.dart';

/// Widget para seleção/visualização de imagem do comprovante
class ReceiptImagePicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onImageSelected;
  final VoidCallback onImageRemoved;
  final bool hasImage;

  const ReceiptImagePicker({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprovante',
          style: AppTheme.textStyles.labelLarge?.copyWith(
            color: AppTheme.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        
        if (hasImage && imagePath != null) 
          _buildImagePreview(context)
        else
          _buildImagePicker(context),
          
        const SizedBox(height: 8),
        
        Text(
          'Fotografe o comprovante para anexar à despesa (opcional)',
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return InkWell(
      onTap: onImageSelected,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.colors.surfaceVariant.withValues(alpha: 0.3),
          border: Border.all(
            color: AppTheme.colors.outline.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: AppTheme.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Tirar foto do comprovante',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toque para abrir a câmera',
              style: AppTheme.textStyles.labelSmall?.copyWith(
                color: AppTheme.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Imagem otimizada com cache de memória
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                // Otimizações de memória para reduzir uso de RAM
                cacheHeight: 200,
                cacheWidth: 300,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: AppTheme.colors.errorContainer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 32,
                          color: AppTheme.colors.onErrorContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erro ao carregar imagem',
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Overlay com ações
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            
            // Botões de ação
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  // Visualizar
                  _buildActionButton(
                    icon: Icons.zoom_in,
                    onPressed: () => _showImageDialog(context),
                    tooltip: 'Visualizar',
                  ),
                  const SizedBox(width: 8),
                  // Remover
                  _buildActionButton(
                    icon: Icons.delete,
                    onPressed: onImageRemoved,
                    tooltip: 'Remover',
                    backgroundColor: AppTheme.colors.error,
                  ),
                ],
              ),
            ),
            
            // Botão trocar imagem
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: ElevatedButton.icon(
                onPressed: onImageSelected,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Trocar foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            // Indicador de comprovante
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anexado',
                      style: AppTheme.textStyles.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? backgroundColor,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: backgroundColor != null ? Colors.white : Colors.black87,
        ),
        tooltip: tooltip,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Imagem em tela cheia otimizada
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.contain,
                    // Otimizações para visualização em tela cheia
                    cacheHeight: 600,
                    cacheWidth: 400,
                  ),
                ),
              ),
            ),
            
            // Botão fechar
            Positioned(
              top: 40,
              right: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}