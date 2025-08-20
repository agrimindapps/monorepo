// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/implementos_class.dart';
import '../../../../repository/implementos_repository.dart';
import '../../cadastro/index.dart';

class ImplementosDetalhesController extends GetxController {
  final String idReg;
  final _repository = ImplementosRepository();

  final isLoading = false.obs;
  final implemento = Rxn<ImplementosClass>();

  ImplementosDetalhesController({required this.idReg});

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    isLoading.value = true;
    try {
      final result = await _repository.get(idReg);
      implemento.value = result;
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

  void navigateToEdit() {
    Get.to(() => ImplementosCadastroPage(idReg: idReg));
  }
}
