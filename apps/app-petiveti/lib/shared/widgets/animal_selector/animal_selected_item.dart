import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/animals/domain/entities/animal.dart';
import '../../../features/animals/domain/entities/animal_enums.dart';

class AnimalSelectedItem extends StatelessWidget {
  const AnimalSelectedItem({
    super.key,
    required this.animal,
  });

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final color = _getAnimalColor(animal.species);
    
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // Nome do pet
                Flexible(
                  child: Text(
                    animal.name,
                    style: TextStyle(
                      fontWeight: AppFontWeights.semiBold,
                      fontSize: AppFontSizes.body,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Espécie badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAnimalIcon(animal.species),
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        animal.species.displayName,
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          fontWeight: AppFontWeights.medium,
                          color: color,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (animal.breed != null && animal.breed!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  // Raça
                  Text(
                    animal.breed!,
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: AppOpacity.medium),
                      fontWeight: AppFontWeights.medium,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
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
