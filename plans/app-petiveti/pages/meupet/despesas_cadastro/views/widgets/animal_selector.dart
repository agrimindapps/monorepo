// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../animal_page/controllers/animal_page_controller.dart';
import '../../controllers/despesa_form_controller.dart';
import '../styles/despesa_form_styles.dart';

class AnimalSelector extends StatelessWidget {
  final DespesaFormController controller;

  const AnimalSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final animalController = Get.find<AnimalPageController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animal *',
          style: DespesaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final animals = animalController.animals;
          final selectedAnimalId = controller.formModel.value.animalId;
          final hasError =
              controller.formState.value.getFieldError('animalId') != null;

          if (animals.isEmpty) {
            return Container(
              padding: DespesaFormStyles.inputPadding,
              decoration: BoxDecoration(
                border: Border.all(color: DespesaFormStyles.dividerColor),
                borderRadius:
                    BorderRadius.circular(DespesaFormStyles.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DespesaFormStyles.warningColor,
                    size: DespesaFormStyles.mediumIconSize,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nenhum animal cadastrado',
                      style: DespesaFormStyles.hintStyle,
                    ),
                  ),
                ],
              ),
            );
          }

          return DropdownButtonFormField<String>(
            value: selectedAnimalId.isEmpty ? null : selectedAnimalId,
            decoration: DespesaFormStyles.getDropdownDecoration(
              labelText: 'Selecione o animal',
              prefixIcon: const Icon(Icons.pets),
              hasError: hasError,
            ),
            items: animals.map((animal) {
              return DropdownMenuItem<String>(
                value: animal.id,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: DespesaFormStyles.secondaryColor,
                      child: Text(
                        animal.nome.isNotEmpty
                            ? animal.nome[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            animal.nome,
                            style: DespesaFormStyles.inputStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (animal.raca.isNotEmpty)
                            Text(
                              animal.raca,
                              style: DespesaFormStyles.captionStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                controller.updateAnimalId(value);
              }
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Selecione um animal';
              }
              return null;
            },
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: DespesaFormStyles.mediumIconSize,
            style: DespesaFormStyles.inputStyle,
            dropdownColor: Colors.white,
            menuMaxHeight: DespesaFormStyles.maxDropdownHeight,
          );
        }),
        Obx(() {
          final error = controller.formState.value.getFieldError('animalId');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: DespesaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
