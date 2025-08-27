import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_provider.dart';
import 'add_animal_form.dart';

class AnimalsListController {
  final BuildContext context;
  final WidgetRef ref;

  const AnimalsListController({
    required this.context,
    required this.ref,
  });

  void addAnimal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAnimalForm(
        onSave: (animal) async {
          Navigator.pop(context);
          await ref.read(animalsProvider.notifier).addAnimal(animal);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pet adicionado com sucesso!')),
            );
          }
        },
      ),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAnimalForm(
        animal: animal,
        onSave: (updatedAnimal) async {
          Navigator.pop(context);
          await ref.read(animalsProvider.notifier).updateAnimal(updatedAnimal);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pet atualizado com sucesso!')),
            );
          }
        },
      ),
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