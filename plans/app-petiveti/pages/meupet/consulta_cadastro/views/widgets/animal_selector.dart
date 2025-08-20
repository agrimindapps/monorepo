// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../animal_page/controllers/animal_page_controller.dart';
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class AnimalSelector extends StatelessWidget {
  final ConsultaFormController controller;

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
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final animals = animalController.animals;
          final selectedAnimalId = controller.model.animalId;
          final hasError = controller.getFieldError('animalId') != null;

          if (animals.isEmpty) {
            return Container(
              padding: ConsultaFormStyles.inputPadding,
              decoration: BoxDecoration(
                border: Border.all(color: ConsultaFormStyles.dividerColor),
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ConsultaFormStyles.warningColor,
                    size: ConsultaFormStyles.mediumIconSize,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nenhum animal cadastrado',
                      style: ConsultaFormStyles.hintStyle,
                    ),
                  ),
                ],
              ),
            );
          }

          return DropdownButtonFormField<String>(
            value: selectedAnimalId.isEmpty ? null : selectedAnimalId,
            decoration: ConsultaFormStyles.getDropdownDecoration(
              labelText: 'Selecione o animal',
              hasError: hasError,
            ),
            items: animals.map((animal) {
              return DropdownMenuItem<String>(
                value: animal.id,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ConsultaFormStyles.secondaryColor,
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
                            style: ConsultaFormStyles.inputStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (animal.raca.isNotEmpty)
                            Text(
                              animal.raca,
                              style: ConsultaFormStyles.captionStyle,
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
            iconSize: ConsultaFormStyles.mediumIconSize,
            style: ConsultaFormStyles.inputStyle,
            dropdownColor: Colors.white,
            menuMaxHeight: ConsultaFormStyles.maxDropdownHeight,
          );
        }),
        Obx(() {
          final error = controller.getFieldError('animalId');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: ConsultaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
