// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/bulas_repository.dart';
import '../../cadastro/index.dart';
import '../model/bula_detalhes_model.dart';

class BulasDetalhesController extends GetxController {
  final BulasRepository repository;
  final String idReg;

  final _isLoading = false.obs;
  final _error = RxString('');
  final _bula = Rx<BulaDetalhes?>(null);

  BulasDetalhesController({
    required this.repository,
    required this.idReg,
  });

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  BulaDetalhes? get bula => _bula.value;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    _isLoading.value = true;
    try {
      await repository.get(idReg);
      _error.value = '';
    } catch (e) {
      _error.value = 'Erro ao carregar dados';
    } finally {
      _isLoading.value = false;
    }
  }

  void navigateToEdit() {
    Get.to(() => BulasCadastroPage(idReg: idReg));
  }
}
