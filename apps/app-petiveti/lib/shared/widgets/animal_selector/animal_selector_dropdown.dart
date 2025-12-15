import 'package:flutter/material.dart';
import '../../../features/animals/domain/entities/animal.dart';
import '../../../features/animals/domain/entities/animal_enums.dart';

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
    final selectedAnimal = animals.firstWhere(
      (a) => a.id == currentSelectedAnimalId,
      orElse: () => animals.first,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onDropdownTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildAnimalIcon(context, selectedAnimal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedAnimal.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selectedAnimal.breed != null && selectedAnimal.breed!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            selectedAnimal.breed!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalIcon(BuildContext context, Animal animal) {
    final color = _getAnimalColor(animal.species);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getAnimalIcon(animal.species),
        size: 20,
        color: color,
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
