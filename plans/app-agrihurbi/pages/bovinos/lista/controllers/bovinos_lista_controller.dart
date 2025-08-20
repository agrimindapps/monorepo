import 'package:get/get.dart';

class BovinosListaController extends GetxController {
  final RxList<dynamic> bovinos = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchTerm = ''.obs;
  final RxString error = RxString('');

  @override
  void onInit() {
    super.onInit();
    loadBovinos();
  }

  Future<void> loadBovinos() async {
    try {
      clearError();
      isLoading.value = true;
      // TODO: Implementar lógica de carregamento de bovinos
      // Exemplo: 
      // bovinos.value = await bovinoRepository.fetchAll();
    } catch (e) {
      error.value = 'Erro ao carregar bovinos: $e';
      print(error.value);
    } finally {
      isLoading.value = false;
    }
  }

  void filterBovinos(String term) {
    searchTerm.value = term;
    // TODO: Implementar lógica de filtragem de bovinos baseada no termo de busca
    if (term.isNotEmpty) {
      bovinos.value = bovinos.where((bovino) => 
        bovino.nomeComum.toLowerCase().contains(term.toLowerCase())
      ).toList();
    } else {
      loadBovinos(); // Recarregar lista original
    }
  }

  void clearError() {
    error.value = '';
  }
}