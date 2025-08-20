// Controller para a lógica e estado do cálculo de gordura corporal

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/gordura_corporea_model.dart';

class GorduraCorporeaController extends ChangeNotifier {
  late GorduraCorporeaModel _model;
  bool _calculado = false;
  String? _erro;

  GorduraCorporeaController({
    required int generoId,
    required String genero,
    required int idade,
    required double altura,
    required double peso,
    required double cintura,
    required double pescoco,
    double? quadril,
  }) {
    _model = GorduraCorporeaModel(
      generoId: generoId,
      genero: genero,
      idade: idade,
      altura: altura,
      peso: peso,
      cintura: cintura,
      pescoco: pescoco,
      quadril: quadril,
    );
  }

  double? get resultado => _model.resultado;
  String get classificacao => _model.classificacao;
  bool get calculado => _calculado;
  String? get erro => _erro;
  Map<String, String> get classificacaoRanges => _model.classificacaoRanges;

  void calcular() {
    try {
      _model.calcular();
      _calculado = true;
      _erro = null;
    } catch (e) {
      _erro = e.toString();
      _calculado = false;
    }
    notifyListeners();
  }

  void limpar() {
    _calculado = false;
    _erro = null;
    notifyListeners();
  }
}
