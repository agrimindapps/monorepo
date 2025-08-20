// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../model/previsao_simples_model.dart';

class PrevisaoSimplesController extends GetxController {
  PrevisaoSimplesModel _model = PrevisaoSimplesModel.empty();
  final RxBool _calculado = false.obs;

  PrevisaoSimplesModel get model => _model;
  bool get calculado => _calculado.value;

  Future<void> calcular({
    required double areaPlantada,
    required double custoPrevistoHectare,
    required double sacasPrevistas,
    required double valorSaca,
  }) async {
    _model = PrevisaoSimplesModel(
      areaPlantada: areaPlantada,
      custoPrevistoHectare: custoPrevistoHectare,
      sacasPrevistas: sacasPrevistas,
      valorSaca: valorSaca,
    );
    _calculado.value = true;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('previsao_area_plantada', areaPlantada);
    await prefs.setDouble('previsao_custo_hectare', custoPrevistoHectare);
    await prefs.setDouble('previsao_sacas_previstas', sacasPrevistas);
    await prefs.setDouble('previsao_valor_saca', valorSaca);

    
  }

  void limpar() {
    _model = PrevisaoSimplesModel.empty();
    _calculado.value = false;
    
  }

  Future<void> carregarUltimoCalculo() async {
    final prefs = await SharedPreferences.getInstance();
    final areaPlantada = prefs.getDouble('previsao_area_plantada') ?? 0;
    final custoPrevistoHectare = prefs.getDouble('previsao_custo_hectare') ?? 0;
    final sacasPrevistas = prefs.getDouble('previsao_sacas_previstas') ?? 0;
    final valorSaca = prefs.getDouble('previsao_valor_saca') ?? 0;

    if (areaPlantada > 0) {
      await calcular(
        areaPlantada: areaPlantada,
        custoPrevistoHectare: custoPrevistoHectare,
        sacasPrevistas: sacasPrevistas,
        valorSaca: valorSaca,
      );
    }
  }
}
