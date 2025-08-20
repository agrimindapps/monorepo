// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../models/leguminosa_model.dart';

class LeguminosaController extends GetxController {
  LeguminosaModel _model = LeguminosaModel.empty();
  final RxBool _calculado = false.obs;

  LeguminosaModel get model => _model;
  bool get calculado => _calculado.value;

  Future<void> calcular({
    required double vagensPorPlanta,
    required double sementesPorVagem,
    required double pesoMilGraos,
    required double plantasM2,
  }) async {
    _model = LeguminosaModel(
      vagensPorPlanta: vagensPorPlanta,
      sementesPorVagem: sementesPorVagem,
      pesoMilGraos: pesoMilGraos,
      plantasM2: plantasM2,
    );
    _calculado.value = true;

    // Salvar no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('leguminosa_vagens_planta', vagensPorPlanta);
    await prefs.setDouble('leguminosa_sementes_vagem', sementesPorVagem);
    await prefs.setDouble('leguminosa_peso_mil_graos', pesoMilGraos);
    await prefs.setDouble('leguminosa_plantas_m2', plantasM2);

    
  }

  void limpar() {
    _model = LeguminosaModel.empty();
    _calculado.value = false;
    
  }

  Future<void> carregarUltimoCalculo() async {
    final prefs = await SharedPreferences.getInstance();
    final vagensPorPlanta = prefs.getDouble('leguminosa_vagens_planta') ?? 0;
    final sementesPorVagem = prefs.getDouble('leguminosa_sementes_vagem') ?? 0;
    final pesoMilGraos = prefs.getDouble('leguminosa_peso_mil_graos') ?? 0;
    final plantasM2 = prefs.getDouble('leguminosa_plantas_m2') ?? 0;

    if (vagensPorPlanta > 0) {
      await calcular(
        vagensPorPlanta: vagensPorPlanta,
        sementesPorVagem: sementesPorVagem,
        pesoMilGraos: pesoMilGraos,
        plantasM2: plantasM2,
      );
    }
  }
}
