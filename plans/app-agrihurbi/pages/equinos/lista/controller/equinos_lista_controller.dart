// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/equinos_repository.dart';
import '../../cadastro/index.dart';
import '../../detalhes/index.dart';

class EquinosListaController extends GetxController {
  final _repository = EquinoRepository();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  @override
  void onReady() {
    super.onReady();
    // Escutar mudanças no repository para atualizar automaticamente
    ever(_repository.listaEquinos, (_) {
      update(); // Força atualização dos getters
    });
  }

  Future<void> carregarDados() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repository.getAll();
    } catch (e) {
      errorMessage.value = 'Erro ao carregar dados: $e';
      _showErrorMessage('Erro ao carregar equinos');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToRegister() {
    Get.to(
      () => const EquinosCadastroPage(),
      arguments: {'idReg': ''},
    )?.then((result) {
      // Se retornou true, significa que foi salvo com sucesso
      if (result == true) {
        carregarDados(); // Recarregar lista
      }
    });
  }

  void navigateToDetails(String idReg) {
    Get.to(
      () => const EquinosDetalhesPage(),
      arguments: {'idReg': idReg},
    );
  }

  // Getters reativos para acessar dados do repository
  List<dynamic> get equinos => _repository.listaEquinos;
  bool get hasEquinos => equinos.isNotEmpty;
  int get equinosCount => equinos.length;

  // Método para refresh manual
  Future<void> refreshData() async {
    await carregarDados();
  }
}
