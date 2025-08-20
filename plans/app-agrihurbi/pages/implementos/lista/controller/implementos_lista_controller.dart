// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/implementos_class.dart';
import '../../../../repository/implementos_repository.dart';
import '../../cadastro/index.dart';
import '../../detalhes/index.dart';

class ImplementosListaController extends GetxController {
  final _isLoading = false.obs;
  final _implementos = <ImplementosClass>[].obs;
  final _error = ''.obs;

  bool get isLoading => _isLoading.value;
  List<ImplementosClass> get implementos => _implementos;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    _isLoading.value = true;
    try {
      final implementos = await ImplementosRepository().getAll();
      _implementos.value = implementos;
      _error.value = '';
    } catch (e) {
      _error.value = 'Erro ao carregar dados';
    } finally {
      _isLoading.value = false;
    }
  }

  void navigateToRegister() {
    Get.to(() => const ImplementosCadastroPage(idReg: ''));
  }

  void navigateToDetails(String idReg) {
    Get.to(() => ImplementosAgDetalhesPage(idReg: idReg));
  }
}
