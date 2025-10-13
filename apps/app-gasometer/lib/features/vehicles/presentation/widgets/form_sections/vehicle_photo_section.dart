import 'dart:io';

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
    final formState = ref.watch(vehicleFormNotifierProvider);
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);

    final currentImagePath = formState.vehicleImage?.existsSync() == true
        ? formState.vehicleImage!.path
        : null;

    return FormSectionHeader(
      title: 'Foto do Veículo',
      icon: Icons.camera_alt,
      child: EnhancedImagePicker(
        currentImagePath: currentImagePath,
        onImageChanged: (imagePath) {
          if (imagePath != null) {
            notifier.updateVehicleImage(File(imagePath));
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
}
