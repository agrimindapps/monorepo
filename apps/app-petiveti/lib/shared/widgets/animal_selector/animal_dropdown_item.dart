import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/animals/domain/entities/animal.dart';
import '../../../features/animals/domain/entities/animal_enums.dart';

class AnimalDropdownItem extends StatelessWidget {
  const AnimalDropdownItem({
    super.key,
    required this.animal,
    required this.isSelected,
  });

  final Animal animal;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = _getAnimalColor(animal.species);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.medium,
        horizontal: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              _getAnimalIcon(animal.species),
              size: AppSizes.iconS,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        animal.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? AppFontWeights.semiBold
                              : AppFontWeights.medium,
                          fontSize: AppFontSizes.medium,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Espécie badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAnimalIcon(animal.species),
                            size: AppSizes.iconXS,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            animal.species.displayName,
                            style: TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: AppFontWeights.medium,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (animal.breed != null && animal.breed!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Text(
                          animal.breed!,
                          style: TextStyle(
                            fontSize: AppFontSizes.small,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: AppOpacity.medium),
                            fontWeight: AppFontWeights.medium,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: AppSizes.iconS,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
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
