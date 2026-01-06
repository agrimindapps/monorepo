import 'dart:io' as io;

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/enhanced_image_picker.dart';
import '../../../../../core/widgets/form_section_header.dart';
import '../../providers/vehicle_form_notifier.dart';

/// Vehicle photo upload section
class VehiclePhotoSection extends ConsumerWidget {
  const VehiclePhotoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(vehicleFormProvider);
    final notifier = ref.read(vehicleFormProvider.notifier);

    // Verificar se tem imagem nova selecionada (File)
    final currentImagePath = _getImagePath(formState.vehicleImage);
    
    // Se não tem File, verificar se tem Base64 salvo no veículo em edição
    final existingImageBase64 = formState.editingVehicle?.metadata['foto'] as String?;
    final hasExistingImage = existingImageBase64 != null && 
        existingImageBase64.isNotEmpty && 
        existingImageBase64.startsWith('data:');

    return FormSectionHeader(
      title: 'Foto do Veículo',
      icon: Icons.camera_alt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar imagem existente se não tiver nova selecionada
          if (hasExistingImage && currentImagePath == null) ...[
            _buildExistingImagePreview(context, existingImageBase64, notifier),
            const SizedBox(height: 12),
          ],
          
          // Picker para nova imagem
          EnhancedImagePicker(
            currentImagePath: currentImagePath,
            onImageChanged: (imagePath) {
              if (imagePath != null) {
                notifier.updateVehicleImage(io.File(imagePath));
              } else {
                notifier.removeVehicleImage();
              }
            },
            label: hasExistingImage && currentImagePath == null 
                ? 'Alterar foto' 
                : 'Foto do Veículo',
            hint: 'Adicione uma foto para identificar melhor seu veículo',
            required: false,
            maxWidth: 800,
            maxHeight: 600,
            imageQuality: 85,
            showPreview: true,
            emptyStateText: hasExistingImage 
                ? 'Substituir foto atual' 
                : 'Adicionar foto do veículo',
          ),
        ],
      ),
    );
  }

  /// Constrói preview da imagem existente (Base64)
  Widget _buildExistingImagePreview(
    BuildContext context, 
    String imageBase64,
    VehicleFormNotifier notifier,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: CoreImageWidget(
              imageBase64: imageBase64,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Label
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Foto atual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get image path, checking existence only on non-web platforms
  String? _getImagePath(io.File? file) {
    if (file == null) return null;

    // On web, just return the path without checking existence
    // (dart:io operations are not supported on web)
    if (kIsWeb) {
      return file.path;
    }

    // On mobile/desktop, check if file exists
    try {
      return file.existsSync() ? file.path : null;
    } catch (e) {
      // If any error occurs, return null to be safe
      debugPrint('Error checking file existence: $e');
      return null;
    }
  }
}
