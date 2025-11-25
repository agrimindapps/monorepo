import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    // Check if file exists only on mobile/desktop platforms
    // Web doesn't support dart:io File operations
    final currentImagePath = _getImagePath(formState.vehicleImage);

    return FormSectionHeader(
      title: 'Foto do Veículo',
      icon: Icons.camera_alt,
      child: EnhancedImagePicker(
        currentImagePath: currentImagePath,
        onImageChanged: (imagePath) {
          if (imagePath != null) {
            notifier.updateVehicleImage(io.File(imagePath));
          } else {
            notifier.removeVehicleImage();
          }
        },
        label: 'Foto do Veículo',
        hint: 'Adicione uma foto para identificar melhor seu veículo',
        required: false,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
        showPreview: true,
        emptyStateText: 'Adicionar foto do veículo',
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
