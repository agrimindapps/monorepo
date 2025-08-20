// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../models/grao_model.dart';

class GraoController extends GetxController {
  final GraoModel model;
  final RxBool _loaded = false.obs;

  GraoController() : model = GraoModel();

  bool get loaded => _loaded.value;
  double? get resultado => model.resultado;
  String get classificacao => model.classificarRendimento();
  double get sacasPorHa => (model.resultado ?? 0) / 60;

  void setEspigasPorPlanta(String value) {
    model.espigasPorPlanta = double.tryParse(value);
    _calcularENotificar();
  }

  void setFileirasPorEspiga(String value) {
    model.fileirasPorEspiga = double.tryParse(value);
    _calcularENotificar();
  }

  void setGraosPorFileira(String value) {
    model.graosPorFileira = double.tryParse(value);
    _calcularENotificar();
  }

  void setPesoMilSementes(String value) {
    model.pesoMilSementes = double.tryParse(value);
    _calcularENotificar();
  }

  void setPlantasM2(String value) {
    model.plantasM2 = double.tryParse(value);
    _calcularENotificar();
  }

  Future<void> _calcularENotificar() async {
    if (model.validarCampos()) {
      model.calcularRendimento();
      await model.salvar(await SharedPreferences.getInstance());
    }
    update();
  }

  Future<void> carregarDados() async {
    if (!_loaded.value) {
      await model.carregar(await SharedPreferences.getInstance());
      _loaded.value = true;
      update();
    
    }
  }

  void limpar() {
    model.limpar();
    
  }
}
