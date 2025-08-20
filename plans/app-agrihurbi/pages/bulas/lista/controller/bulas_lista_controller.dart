// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/bulas_repository.dart';
import '../../cadastro/index.dart';
import '../../detalhes/index.dart';

class BulasListaController extends GetxController {
  final _repository = BulasRepository();
  final isLoading = false.obs;

  Future<void> carregarDados() async {
    isLoading.value = true;
    try {
      await _repository.getAll();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRegister() {
    Get.to(() => const BulasCadastroPage(idReg: ''));
  }

  void navigateToDetails(String idReg) {
    Get.to(() => BulasDetalhesPage(idReg: idReg));
  }

  List<dynamic> get bulas => _repository.listaBulas;
}
