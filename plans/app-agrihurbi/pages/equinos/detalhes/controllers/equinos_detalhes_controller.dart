// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/equinos_repository.dart';
import '../../cadastro/index.dart';

class EquinosDetalhesController extends GetxController {
  // Observable state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Parameters
  String idReg = '';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments['idReg'] != null) {
      idReg = arguments['idReg'];
    }
    carregarDados();
  }

  Future<void> carregarDados() async {
    if (idReg.isEmpty) {
      errorMessage.value = 'ID do registro não informado';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await EquinoRepository().get(idReg);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar dados: $e';
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados do equino',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToEdit() {
    Get.to(
      () => const EquinosCadastroPage(),
      arguments: {'idReg': idReg},
    )?.then((result) {
      // Se retornou true, significa que foi editado com sucesso
      if (result == true) {
        carregarDados(); // Recarregar dados atualizados
      }
    });
  }

  void showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Getters para acessar dados do repository de forma reativa
  get equino => EquinoRepository().mapEquinos.value;
}
