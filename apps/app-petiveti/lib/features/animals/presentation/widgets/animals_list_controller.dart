import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_provider.dart';
import 'add_pet_dialog.dart';

class AnimalsListController {
  final BuildContext context;
  final WidgetRef ref;

  const AnimalsListController({
    required this.context,
    required this.ref,
  });

  void addAnimal() {
    showDialog<void>(
      context: context,
      builder: (context) => const AddPetDialog(),
    );
  }

  void viewAnimalDetails(Animal animal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(animal.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Espécie: ${animal.species}'),
            const SizedBox(height: 8),
            Text('Raça: ${animal.breed}'),
            const SizedBox(height: 8),
            Text('Idade: ${animal.displayAge}'),
            const SizedBox(height: 8),
            Text('Peso: ${animal.currentWeight.toStringAsFixed(1)} kg'),
            const SizedBox(height: 8),
            Text('Gênero: ${animal.gender}'),
            const SizedBox(height: 8),
            Text('Cor: ${animal.color}'),
            if (animal.notes != null && animal.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Observações: ${animal.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              editAnimal(animal);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  void editAnimal(Animal animal) {
    showDialog<void>(
      context: context,
      builder: (context) => AddPetDialog(animal: animal),
    );
  }

  void deleteAnimal(Animal animal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pet'),
        content: Text('Tem certeza que deseja excluir ${animal.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(animalsProvider.notifier).deleteAnimal(animal.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pet excluído com sucesso')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}