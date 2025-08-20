// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_data_model.dart';
import '../../utils/dashboard_constants.dart';

class PetSelectorWidget extends StatelessWidget {
  final DashboardController controller;

  const PetSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.pets.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: DashboardConstants.petSelectorHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.pets.length,
        itemBuilder: (context, index) {
          final pet = controller.pets[index];
          final isSelected = controller.selectedPet?.id == pet.id;

          return GestureDetector(
            onTap: () => controller.selectPet(pet),
            child: Container(
              width: DashboardConstants.petImageSize,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  _buildPetImage(pet),
                  if (isSelected) _buildSelectionIndicator(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetImage(Pet pet) {
    return ClipOval(
      child: Image.network(
        pet.foto,
        width: DashboardConstants.petImageSize,
        height: DashboardConstants.petImageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: DashboardConstants.petImageSize,
            height: DashboardConstants.petImageSize,
            color: Colors.grey[300],
            child: Icon(
              DashboardConstants.getPetIcon(pet.especie),
              size: 40,
              color: Colors.grey[700],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}
