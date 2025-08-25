import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal.dart';
import '../providers/animals_provider.dart';
import '../widgets/add_animal_form.dart';
import '../widgets/animal_card.dart';
import '../widgets/empty_animals_state.dart';

class AnimalsPage extends ConsumerStatefulWidget {
  const AnimalsPage({super.key});

  @override
  ConsumerState<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends ConsumerState<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    // Load animals when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsProvider.notifier).loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    
    // Show error message if there's an error
    if (animalsState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(animalsState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () {
                ref.read(animalsProvider.notifier).clearError();
                ref.read(animalsProvider.notifier).loadAnimals();
              },
            ),
          ),
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Busca - Em breve!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sync':
                  _syncAnimals();
                  break;
                case 'settings':
                  context.go('/settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Sincronizar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configurações'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAnimal(context),
        tooltip: 'Adicionar Pet',
        child: const Icon(Icons.pets),
      ),
    );
  }

  Widget _buildBody() {
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
            onTap: () => _viewAnimalDetails(animal),
            onEdit: () => _editAnimal(animal),
            onDelete: () => _deleteAnimal(animal),
          );
        },
      ),
    );
  }

  void _syncAnimals() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Sincronizando...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Trigger sync through repository
    await ref.read(animalsProvider.notifier).loadAnimals();
  }

  void _addAnimal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAnimalForm(
        onSave: (animal) async {
          Navigator.pop(context);
          await ref.read(animalsProvider.notifier).addAnimal(animal);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pet adicionado com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _viewAnimalDetails(Animal animal) {
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
              _editAnimal(animal);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  void _editAnimal(Animal animal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAnimalForm(
        animal: animal,
        onSave: (updatedAnimal) async {
          Navigator.pop(context);
          await ref.read(animalsProvider.notifier).updateAnimal(updatedAnimal);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pet atualizado com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _deleteAnimal(Animal animal) {
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
              
              if (mounted) {
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