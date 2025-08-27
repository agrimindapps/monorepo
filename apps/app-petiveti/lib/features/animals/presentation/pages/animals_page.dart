import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/animals_provider.dart';
import '../widgets/animals_app_bar.dart';
import '../widgets/animals_body.dart';
import '../widgets/animals_list_controller.dart';

class AnimalsPage extends ConsumerStatefulWidget {
  const AnimalsPage({super.key});
  
  @override
  ConsumerState<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends ConsumerState<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize data loading and error listener with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsProvider.notifier).loadAnimals();
      _setupErrorListener();
    });
  }

  void _setupErrorListener() {
    ref.listen<AnimalsState>(animalsProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error!),
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
            // Clear error after showing snackbar
            ref.read(animalsProvider.notifier).clearError();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AnimalsListController(context: context, ref: ref);
    
    return Scaffold(
      appBar: const AnimalsAppBar(),
      body: AnimalsBody(
        onAddAnimal: controller.addAnimal,
        onViewAnimalDetails: controller.viewAnimalDetails,
        onEditAnimal: controller.editAnimal,
        onDeleteAnimal: controller.deleteAnimal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addAnimal,
        tooltip: 'Adicionar Pet',
        child: const Icon(Icons.pets),
      ),
    );
  }

}