// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../database/planta_model.dart';
import '../pages/planta_detalhes_page/index.dart';
import '../pages/planta_form_page/index.dart';
import '../pages/premium_page/bindings/premium_binding.dart';
import '../pages/premium_page/views/premium_page.dart';

// import '../../tarefa_detalhes_page/index.dart'; // Removido - sistema antigo

class PlantasNavigator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  /// Navigate to create new plant page
  static Future<bool?> toNovaPlanta() async {
    return await _toPlantaForm(null);
  }

  /// Navigate to plant details page
  static Future<void> toPlantaDetalhes(PlantaModel planta) async {
    await Get.to(
      () => const PlantaDetalhesView(),
      arguments: planta,
      binding: PlantaDetalhesBinding(),
    );
  }

  /// Navigate to edit plant page
  static Future<bool?> toEditarPlanta(PlantaModel planta) async {
    return await _toPlantaForm(planta);
  }

  /// Private method to handle unified plant form navigation
  static Future<bool?> _toPlantaForm(PlantaModel? planta) async {
    final result = await Get.to(
      () => const PlantaFormView(),
      arguments: planta,
      binding: PlantaFormBinding(),
    );
    return result as bool?;
  }

  /// Navigate to task details page
  /// TODO: Implementar nova página de detalhes de tarefa
  static Future<void> toTarefaDetalhes(
    PlantaModel planta,
    Map<String, dynamic> tarefa,
  ) async {
    // await Get.to(
    //   () => const TarefaDetalhesView(),
    //   arguments: {
    //     'planta': planta,
    //     'tarefa': tarefa,
    //   },
    //   binding: TarefaDetalhesBinding(),
    // );
    Get.snackbar('Info', 'Página de detalhes de tarefa em atualização');
  }

  /// Navigate to tasks page
  static Future<void> toTarefas() async {
    await Get.toNamed('/tarefas');
  }

  /// Navigate to account page
  static Future<void> toMinhaConta() async {
    await Get.toNamed('/minha-conta');
  }

  /// Navigate to spaces page
  static Future<void> toEspacos() async {
    await Get.toNamed('/espacos');
  }

  /// Navigate to premium page
  static Future<void> toPremium() async {
    await Get.to(
      () => const PremiumPage(),
      binding: PremiumBinding(),
    );
  }

  /// Show confirmation dialog for plant removal
  static Future<bool> showRemoveConfirmation(String plantName) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Remover planta'),
            content: Text(
              'Tem certeza que deseja remover "$plantName"?\n\n'
              'Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
