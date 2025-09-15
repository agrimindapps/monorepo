import 'dart:io';

import 'package:flutter/material.dart';

import '../../infrastructure/services/profile_image_service.dart';
import '../../shared/utils/result.dart';

/// Callback para quando imagem é selecionada
typedef OnImageSelected = void Function(File imageFile);

/// Callback para progresso de upload
typedef OnUploadProgress = void Function(double progress);

/// Widget reutilizável para seleção de imagem de perfil
/// Oferece opções de câmera e galeria em um bottom sheet
class ProfileImagePicker extends StatelessWidget {
  final ProfileImageService _profileImageService;
  final OnImageSelected? onImageSelected;
  final OnUploadProgress? onUploadProgress;
  final VoidCallback? onCancel;
  final String title;
  final String cameraLabel;
  final String galleryLabel;
  final String cancelLabel;
  final IconData cameraIcon;
  final IconData galleryIcon;
  final Color? primaryColor;
  final BorderRadius? borderRadius;

  const ProfileImagePicker({
    super.key,
    required ProfileImageService profileImageService,
    this.onImageSelected,
    this.onUploadProgress,
    this.onCancel,
    this.title = 'Alterar Foto do Perfil',
    this.cameraLabel = 'Câmera',
    this.galleryLabel = 'Galeria',
    this.cancelLabel = 'Cancelar',
    this.cameraIcon = Icons.camera_alt,
    this.galleryIcon = Icons.photo_library,
    this.primaryColor,
    this.borderRadius,
  }) : _profileImageService = profileImageService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: effectiveBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options
          Row(
            children: [
              // Camera option
              Expanded(
                child: _buildOptionCard(
                  context: context,
                  icon: cameraIcon,
                  label: cameraLabel,
                  color: effectivePrimaryColor,
                  onTap: () => _selectFromCamera(context),
                ),
              ),
              const SizedBox(width: 16),
              
              // Gallery option
              Expanded(
                child: _buildOptionCard(
                  context: context,
                  icon: galleryIcon,
                  label: galleryLabel,
                  color: effectivePrimaryColor,
                  onTap: () => _selectFromGallery(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromCamera(BuildContext context) async {
    Navigator.of(context).pop();
    
    final result = await _profileImageService.pickImageFromCamera();
    
    result.fold(
      (error) => _showErrorSnackBar(context, error.message),
      (imageFile) => onImageSelected?.call(imageFile),
    );
  }

  Future<void> _selectFromGallery(BuildContext context) async {
    Navigator.of(context).pop();
    
    final result = await _profileImageService.pickImageFromGallery();
    
    result.fold(
      (error) => _showErrorSnackBar(context, error.message),
      (imageFile) => onImageSelected?.call(imageFile),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Factory method para mostrar o picker como bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ProfileImageService profileImageService,
    OnImageSelected? onImageSelected,
    OnUploadProgress? onUploadProgress,
    VoidCallback? onCancel,
    String title = 'Alterar Foto do Perfil',
    String cameraLabel = 'Câmera',
    String galleryLabel = 'Galeria',
    String cancelLabel = 'Cancelar',
    IconData cameraIcon = Icons.camera_alt,
    IconData galleryIcon = Icons.photo_library,
    Color? primaryColor,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileImagePicker(
        profileImageService: profileImageService,
        onImageSelected: onImageSelected,
        onUploadProgress: onUploadProgress,
        onCancel: onCancel,
        title: title,
        cameraLabel: cameraLabel,
        galleryLabel: galleryLabel,
        cancelLabel: cancelLabel,
        cameraIcon: cameraIcon,
        galleryIcon: galleryIcon,
        primaryColor: primaryColor,
      ),
    );
  }
}

/// Dialog alternativo para o picker (para casos onde bottom sheet não é ideal)
class ProfileImagePickerDialog extends StatelessWidget {
  final ProfileImageService _profileImageService;
  final OnImageSelected? onImageSelected;
  final OnUploadProgress? onUploadProgress;
  final VoidCallback? onCancel;
  final String title;
  final String cameraLabel;
  final String galleryLabel;
  final String cancelLabel;
  final IconData cameraIcon;
  final IconData galleryIcon;
  final Color? primaryColor;

  const ProfileImagePickerDialog({
    super.key,
    required ProfileImageService profileImageService,
    this.onImageSelected,
    this.onUploadProgress,
    this.onCancel,
    this.title = 'Alterar Foto do Perfil',
    this.cameraLabel = 'Câmera',
    this.galleryLabel = 'Galeria',
    this.cancelLabel = 'Cancelar',
    this.cameraIcon = Icons.camera_alt,
    this.galleryIcon = Icons.photo_library,
    this.primaryColor,
  }) : _profileImageService = profileImageService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.camera_alt,
            color: effectivePrimaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escolha uma opção para alterar sua foto de perfil:',
          ),
          const SizedBox(height: 20),
          
          // Camera button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _selectFromCamera(context),
              icon: Icon(cameraIcon),
              label: Text(cameraLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: effectivePrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Gallery button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _selectFromGallery(context),
              icon: Icon(galleryIcon),
              label: Text(galleryLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: effectivePrimaryColor,
                side: BorderSide(color: effectivePrimaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelLabel),
        ),
      ],
    );
  }

  Future<void> _selectFromCamera(BuildContext context) async {
    Navigator.of(context).pop();
    
    final result = await _profileImageService.pickImageFromCamera();
    
    result.fold(
      (error) => _showErrorSnackBar(context, error.message),
      (imageFile) => onImageSelected?.call(imageFile),
    );
  }

  Future<void> _selectFromGallery(BuildContext context) async {
    Navigator.of(context).pop();
    
    final result = await _profileImageService.pickImageFromGallery();
    
    result.fold(
      (error) => _showErrorSnackBar(context, error.message),
      (imageFile) => onImageSelected?.call(imageFile),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Factory method para mostrar o picker como dialog
  static Future<void> show({
    required BuildContext context,
    required ProfileImageService profileImageService,
    OnImageSelected? onImageSelected,
    OnUploadProgress? onUploadProgress,
    VoidCallback? onCancel,
    String title = 'Alterar Foto do Perfil',
    String cameraLabel = 'Câmera',
    String galleryLabel = 'Galeria',
    String cancelLabel = 'Cancelar',
    IconData cameraIcon = Icons.camera_alt,
    IconData galleryIcon = Icons.photo_library,
    Color? primaryColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ProfileImagePickerDialog(
        profileImageService: profileImageService,
        onImageSelected: onImageSelected,
        onUploadProgress: onUploadProgress,
        onCancel: onCancel,
        title: title,
        cameraLabel: cameraLabel,
        galleryLabel: galleryLabel,
        cancelLabel: cancelLabel,
        cameraIcon: cameraIcon,
        galleryIcon: galleryIcon,
        primaryColor: primaryColor,
      ),
    );
  }
}