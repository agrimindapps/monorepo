import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../database/petiveti_database.dart' show AnimalImage;
import '../../../../database/providers/sync_providers.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';

class AnimalCard extends ConsumerWidget {
  final Animal animal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String animalAge = animal.displayAge;
    final String speciesName = animal.species.displayName;
    final animalId = int.tryParse(animal.id);
    
    // Watch primary image stream
    final imageAsync = animalId != null 
        ? ref.watch(animalPrimaryImageStreamProvider(animalId))
        : const AsyncValue<AnimalImage?>.data(null);
    
    return Semantics(
      label: '${animal.name}, $speciesName, $animalAge, peso ${animal.currentWeight.toStringAsFixed(1)} quilogramas',
      hint: 'Toque para ver detalhes deste pet. Toque e segure para mais opções',
      button: true,
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Semantics(
                  label: 'Foto de ${animal.name}',
                  image: true,
                  child: _AnimalAvatar(
                    animal: animal,
                    imageBytes: imageAsync.value?.imageData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Semantics(
                    excludeSemantics: true, // Prevent duplicate reading since parent has full description
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${animal.species.displayName} • ${animal.displayAge}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Peso: ${animal.currentWeight.toStringAsFixed(1)} kg',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  label: 'Menu de ações para ${animal.name}',
                  hint: 'Toque para abrir menu com opções de edição e exclusão',
                  button: true,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Semantics(
                          label: 'Editar ${animal.name}',
                          hint: 'Toque para editar as informações deste pet',
                          button: true,
                          child: const Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Semantics(
                          label: 'Excluir ${animal.name}',
                          hint: 'Toque para excluir este pet permanentemente',
                          button: true,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalAvatar extends StatelessWidget {
  final Animal animal;
  final Uint8List? imageBytes;

  const _AnimalAvatar({
    required this.animal,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      radius: 24,
      child: imageBytes != null
          ? ClipOval(
              child: Image.memory(
                imageBytes!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    animal.species.icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                  );
                },
              ),
            )
          : Icon(
              animal.species.icon,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
    );
  }
}
