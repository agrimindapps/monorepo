import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/design_tokens.dart';

/// Widget modal elegante para seleção de imagem de perfil
/// Permite escolher entre câmera, galeria ou remover foto atual
class ProfileImagePickerWidget extends StatelessWidget {
  const ProfileImagePickerWidget({
    super.key,
    this.onCameraTap,
    this.onGalleryTap,
    this.onRemoveTap,
    this.hasCurrentImage = false,
    this.isLoading = false,
  });
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onRemoveTap;
  final bool hasCurrentImage;
  final bool isLoading;

  static Future<void> show({
    required BuildContext context,
    required void Function(File) onImageSelected,
    required VoidCallback? onRemoveImage,
    bool hasCurrentImage = false,
  }) async {
    if (kDebugMode) {
      debugPrint('📷 ProfileImagePicker: Showing image picker modal');
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _ProfileImagePickerModal(
            onImageSelected: onImageSelected,
            onRemoveImage: onRemoveImage,
            hasCurrentImage: hasCurrentImage,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Alterar Foto do Perfil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Escolha uma fonte para sua nova foto',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 32),
              Column(
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Câmera',
                    subtitle: 'Tirar uma nova foto',
                    onTap: isLoading ? null : onCameraTap,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 16),

                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    title: 'Galeria',
                    subtitle: 'Escolher da galeria',
                    onTap: isLoading ? null : onGalleryTap,
                    isLoading: isLoading,
                  ),

                  if (hasCurrentImage) ...[
                    const SizedBox(height: 16),
                    _buildOption(
                      context,
                      icon: Icons.delete,
                      title: 'Remover Foto',
                      subtitle: 'Remover foto atual',
                      onTap: isLoading ? null : onRemoveTap,
                      isDestructive: true,
                      isLoading: isLoading,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: GasometerDesignTokens.borderRadius(
                        GasometerDesignTokens.radiusButton,
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    final primaryColor =
        isDestructive
            ? Theme.of(context).colorScheme.error
            : GasometerDesignTokens.colorPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusButton,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.05)
                    : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusButton,
            ),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(
                    GasometerDesignTokens.radiusButton,
                  ),
                ),
                child:
                    isLoading
                        ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                        : Icon(
                          icon,
                          color: primaryColor,
                          size: GasometerDesignTokens.iconSizeButton,
                        ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isDestructive
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isLoading)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal interno para seleção de imagem
class _ProfileImagePickerModal extends StatefulWidget {
  const _ProfileImagePickerModal({
    required this.onImageSelected,
    this.onRemoveImage,
    this.hasCurrentImage = false,
  });
  final void Function(File) onImageSelected;
  final VoidCallback? onRemoveImage;
  final bool hasCurrentImage;

  @override
  State<_ProfileImagePickerModal> createState() =>
      __ProfileImagePickerModalState();
}

class __ProfileImagePickerModalState extends State<_ProfileImagePickerModal> {
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return ProfileImagePickerWidget(
      onCameraTap: _pickFromCamera,
      onGalleryTap: _pickFromGallery,
      onRemoveTap: widget.hasCurrentImage ? _removeImage : null,
      hasCurrentImage: widget.hasCurrentImage,
      isLoading: _isLoading,
    );
  }

  Future<void> _pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      if (kDebugMode) {
        debugPrint('📷 ProfileImagePicker: Picking image from ${source.name}');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        if (kDebugMode) {
          debugPrint('📷 ProfileImagePicker: Image selected: ${file.path}');
        }
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onImageSelected(file);
      } else {
        if (kDebugMode) {
          debugPrint('📷 ProfileImagePicker: No image selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProfileImagePicker: Error picking image: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeImage() async {
    try {
      setState(() => _isLoading = true);

      if (kDebugMode) {
        debugPrint('🗑️ ProfileImagePicker: Removing current image');
      }
      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.of(context).pop();
      }
      widget.onRemoveImage?.call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProfileImagePicker: Error removing image: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover imagem: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
