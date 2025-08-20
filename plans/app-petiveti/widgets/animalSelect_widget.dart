// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/11_animal_model.dart';
import '../pages/meupet/animal_page/controllers/animal_page_controller.dart';

class AnimalDropdownWidget extends StatelessWidget {
  final Function(String?, Animal?) onAnimalSelected;
  final bool showRefreshButton;
  final String? hint;

  const AnimalDropdownWidget({
    super.key,
    required this.onAnimalSelected,
    this.showRefreshButton = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final animalController = Get.find<AnimalPageController>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? theme.dividerColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GetBuilder<AnimalPageController>(
                builder: (animalController) {
                  // Se está carregando, mostra indicador
                  if (animalController.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Carregando animais...'),
                          ],
                        ),
                      ),
                    );
                  }

                  // Se não há animais
                  if (animalController.animals.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Nenhum animal cadastrado',
                        style: TextStyle(
                          color: isDark
                              ? theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6)
                              : Colors.grey,
                        ),
                      ),
                    );
                  }

                  // Dropdown com animais
                  return DropdownButtonFormField<String>(
                    padding: EdgeInsets.zero,
                    itemHeight: 60,
                    menuMaxHeight: 400,
                    isDense: false,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    hint: Text(
                      hint ?? 'Selecione um animal',
                      style: TextStyle(
                        color: isDark
                            ? theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6)
                            : Colors.grey,
                      ),
                    ),
                    value: animalController.selectedAnimalId.isEmpty
                        ? null
                        : animalController.selectedAnimalId,
                    items: animalController.animals.map((animal) {
                      return DropdownMenuItem<String>(
                        value: animal.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isDark
                                  ? theme.colorScheme.surface
                                      .withValues(alpha: 0.5)
                                  : Colors.grey[200],
                              backgroundImage: animal.foto != null
                                  ? NetworkImage(animal.foto!)
                                  : null,
                              child: animal.foto == null
                                  ? Icon(Icons.pets,
                                      color: isDark
                                          ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6)
                                          : Colors.grey,
                                      size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    animal.nome,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? theme.colorScheme.onSurface
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    animal.raca,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6)
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final selectedAnimal = animalController.animals
                            .firstWhere((animal) => animal.id == value);
                        animalController.setSelectedAnimalId(value);
                        onAnimalSelected(value, selectedAnimal);
                      }
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    dropdownColor: isDark ? theme.cardColor : Colors.white,
                  );
                },
              ),
            ),
            if (showRefreshButton)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isDark ? theme.dividerColor : Colors.grey[300]!,
                    ),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => _refreshAnimals(),
                  tooltip: 'Atualizar lista de animais',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAnimals() async {
    final animalController = Get.find<AnimalPageController>();
    await animalController.refreshAnimals();
  }
}
