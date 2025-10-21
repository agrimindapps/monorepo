// Controller para lógica de negócio e estado da densidade de nutrientes

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/densidade_nutrientes_model.dart';
import '../utils/densidade_nutrientes_utils.dart';

class DensidadeNutrientesController extends ChangeNotifier {
  int nutrienteSelecionado = 1;
  DensidadeNutrientesResultado? resultado;
  bool calculado = false;

  void calcular(double calorias, double nutriente) {
    final densidade = DensidadeNutrientesUtils.calcularDensidadeNutrientes(
        nutriente, calorias);
    final avaliacao = DensidadeNutrientesUtils.getAvaliacaoDensidade(
        densidade, nutrienteSelecionado);
    final nutrienteModel = DensidadeNutrientesUtils.nutrientes
        .firstWhere((n) => n.id == nutrienteSelecionado);
    final comentario = DensidadeNutrientesUtils.getComentarioDensidade(
        avaliacao, nutrienteModel);

    resultado = DensidadeNutrientesResultado(
      calorias: calorias,
      nutriente: nutriente,
      densidadeNutrientes: densidade,
      avaliacao: avaliacao,
      comentario: comentario,
      nutrienteSelecionado: nutrienteModel,
    );
    calculado = true;
    notifyListeners();
  }

  void limpar() {
    nutrienteSelecionado = 1;
    resultado = null;
    calculado = false;
    notifyListeners();
  }

  void onNutrienteChanged(int value) {
    nutrienteSelecionado = value;
    notifyListeners();
  }
}
