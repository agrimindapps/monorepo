import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_provider.dart';
import 'animal_card.dart';
import 'empty_animals_state.dart';

class AnimalsBody extends ConsumerWidget {
  final VoidCallback onAddAnimal;
  final void Function(Animal) onViewAnimalDetails;
  final void Function(Animal) onEditAnimal;
  final void Function(Animal) onDeleteAnimal;

  const AnimalsBody({
    super.key,
    required this.onAddAnimal,
    required this.onViewAnimalDetails,
    required this.onEditAnimal,
    required this.onDeleteAnimal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsState = ref.watch(animalsProvider);
    
    if (animalsState.isLoading && animalsState.animals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (animalsState.animals.isEmpty) {
      return const EmptyAnimalsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(animalsProvider.notifier).loadAnimals();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: animalsState.animals.length,
        itemBuilder: (context, index) {
          final animal = animalsState.animals[index];
          return AnimalCard(
            animal: animal,
            onTap: () => onViewAnimalDetails(animal),
            onEdit: () => onEditAnimal(animal),
            onDelete: () => onDeleteAnimal(animal),
          );
        },
      ),
    );
  }
}