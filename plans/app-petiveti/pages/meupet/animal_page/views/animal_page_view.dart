// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../constants/design_tokens.dart';
import '../../../../models/11_animal_model.dart';
import '../../../../widgets/animal_card_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../animal_cadastro/index.dart';
import '../controllers/animal_page_controller.dart';

class AnimalPageView extends StatelessWidget {
  const AnimalPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnimalPageController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(child: _buildBody(controller)),
          ],
        ),
      ),
      bottomNavigationBar: const VetBottomBarWidget(),
      floatingActionButton: _buildFloatingActionButton(controller),
    );
  }

  Widget _buildHeader(AnimalPageController controller) {
    return PageHeaderWidget(
      title: 'Animais',
      subtitle: '${controller.totalAnimals} registros',
      icon: Icons.pets,
      showBackButton: true,
    );
  }

  Widget _buildBody(AnimalPageController controller) {
    return Center(
      child: SizedBox(
        width: DesignTokens.maxContentWidth,
        child: Padding(
          padding: DesignTokens.pageHorizontalPadding,
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.animals.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum animal cadastrado',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimalsList(controller.animals, controller),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnimalsList(
      List<Animal> animals, AnimalPageController controller) {
    return Column(
      key: const ValueKey('animals_list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: animals.map((animal) {
        return AnimalCardWidget(
          key: ValueKey(animal.id),
          animal: animal,
          onEdit: () => _editAnimal(animal, controller),
          onDelete: () => _deleteAnimal(animal, controller),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingActionButton(AnimalPageController controller) {
    return FloatingActionButton(
      onPressed: () => _addAnimal(controller),
      backgroundColor:
          Theme.of(Get.context!).floatingActionButtonTheme.backgroundColor,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _addAnimal(AnimalPageController controller) async {
    final result = await animalCadastro(Get.context!, null);
    if (result == true) {
      controller.loadAnimals();
    }
  }

  Future<void> _editAnimal(
      Animal animal, AnimalPageController controller) async {
    final result = await animalCadastro(Get.context!, animal);
    if (result == true) {
      controller.loadAnimals();
    }
  }

  Future<void> _deleteAnimal(
      Animal animal, AnimalPageController controller) async {
    final confirm = await _showDeleteConfirmationDialog(animal);

    if (confirm == true) {
      final success = await controller.deleteAnimal(animal);

      if (success) {
        Get.snackbar(
          'Sucesso',
          'Animal "${animal.nome}" excluído com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(Animal animal) {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o animal "${animal.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
