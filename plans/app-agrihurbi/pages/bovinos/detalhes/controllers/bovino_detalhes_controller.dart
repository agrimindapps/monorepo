import 'package:get/get.dart';

class BovinoDetalhesController extends GetxController {
  final Rx<Map<String, dynamic>> bovino = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = false.obs;
  final RxString error = RxString('');

  // Getters para nomeComum e id
  String get nomeComum => bovino.value['nomeComum'] ?? '';
  String get id => bovino.value['id'] ?? '';

  void loadBovinoDetails(dynamic bovinoId) async {
    try {
      clearError();
      isLoading.value = true;
      // TODO: Implementar lógica de carregamento de detalhes do bovino
      // Exemplo:
      // bovino.value = await bovinoRepository.findById(bovinoId) ?? {};
    } catch (e) {
      error.value = 'Erro ao carregar detalhes do bovino: $e';
      // Log de erro removido
    } finally {
      isLoading.value = false;
    }
  }

  void updateBovinoDetails(dynamic updatedBovino) {
    // TODO: Implementar lógica de atualização de bovino
    bovino.value = updatedBovino ?? {};
  }

  Future<bool> removerBovino(String idReg) async {
    try {
      clearError();
      // TODO: Implementar lógica de remoção do bovino
      // Por exemplo:
      // await bovinoRepository.delete(idReg);
      bovino.value = {};
      return true;
    } catch (e) {
      error.value = 'Erro ao remover bovino: $e';
      return false;
    }
  }

  void clearError() {
    error.value = '';
  }
}