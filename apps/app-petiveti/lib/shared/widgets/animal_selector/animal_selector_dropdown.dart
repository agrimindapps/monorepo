import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/animals/domain/entities/animal.dart';
import '../../../features/animals/domain/entities/animal_enums.dart';
import 'animal_dropdown_item.dart';
import 'animal_selected_item.dart';

class AnimalSelectorDropdown extends StatelessWidget {
  const AnimalSelectorDropdown({
    super.key,
    required this.animals,
    required this.currentSelectedAnimalId,
    this.hintText,
    required this.enabled,
    required this.fadeAnimation,
    required this.isExpanded,
    required this.onAnimalSelected,
    required this.onDropdownTap,
  });

  final List<Animal> animals;
  final String? currentSelectedAnimalId;
  final String? hintText;
  final bool enabled;
  final Animation<double> fadeAnimation;
  final bool isExpanded;
  final void Function(String?) onAnimalSelected;
  final VoidCallback onDropdownTap;

  @override
  Widget build(BuildContext context) {
    final selectedAnimal = currentSelectedAnimalId != null
        ? animals.firstWhere(
            (a) => a.id == currentSelectedAnimalId,
            orElse: () => animals.first,
          )
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animalColor = selectedAnimal != null 
        ? _getAnimalColor(selectedAnimal.species) 
        : null;

    return Semantics(
      label: selectedAnimal != null
          ? 'Pet selecionado: ${selectedAnimal.name}, ${selectedAnimal.species.displayName}'
          : 'Selecionar pet',
      button: true,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedAnimal != null
                  ? (animalColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: isDark ? 0.6 : 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: isDark ? 0.4 : 0.3),
              width: selectedAnimal != null ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(15),
            color: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Theme.of(context).colorScheme.surface,
          ),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: DropdownButtonFormField<String>(
                initialValue: currentSelectedAnimalId,
                isDense: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.medium,
                  ),
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: AppOpacity.medium),
                    fontSize: AppFontSizes.medium,
                    fontWeight: AppFontWeights.regular,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: AppSpacing.medium),
                    child: Icon(
                      selectedAnimal != null
                          ? _getAnimalIcon(selectedAnimal.species)
                          : Icons.pets,
                      color: selectedAnimal != null
                          ? animalColor
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: AppOpacity.subtle),
                      size: AppSizes.iconM,
                    ),
                  ),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return animals.map<Widget>((Animal animal) {
                    final isSelected = animal.id == currentSelectedAnimalId;
                    if (!isSelected) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: const SizedBox.shrink(),
                      );
                    }
                    return AnimalSelectedItem(animal: animal);
                  }).toList();
                },
                items: animals.map<DropdownMenuItem<String>>((Animal animal) {
                  final isCurrentlySelected =
                      animal.id == currentSelectedAnimalId;

                  return DropdownMenuItem<String>(
                    value: animal.id,
                    child: AnimalDropdownItem(
                      animal: animal,
                      isSelected: isCurrentlySelected,
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onAnimalSelected : null,
                onTap: onDropdownTap,
                isExpanded: true,
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: AppDurations.fast,
                  child: Icon(
                    Icons.expand_more,
                    color: enabled
                        ? (selectedAnimal != null
                            ? animalColor
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: AppOpacity.prominent))
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: AppOpacity.disabled),
                    size: AppSizes.iconM,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppFontSizes.medium,
                ),
                dropdownColor: isDark
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                elevation: isDark ? 4 : 8,
                itemHeight: 80,
                menuMaxHeight: 400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAnimalIcon(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return Icons.pets;
      case AnimalSpecies.cat:
        return Icons.cruelty_free;
      case AnimalSpecies.bird:
        return Icons.flutter_dash;
      case AnimalSpecies.rabbit:
        return Icons.pets_outlined;
      case AnimalSpecies.hamster:
      case AnimalSpecies.guineaPig:
        return Icons.pets_outlined;
      case AnimalSpecies.fish:
        return Icons.water;
      default:
        return Icons.pets;
    }
  }

  Color _getAnimalColor(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return Colors.brown;
      case AnimalSpecies.cat:
        return Colors.orange;
      case AnimalSpecies.bird:
        return Colors.blue;
      case AnimalSpecies.rabbit:
        return Colors.pink;
      case AnimalSpecies.hamster:
      case AnimalSpecies.guineaPig:
        return Colors.amber;
      case AnimalSpecies.fish:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
