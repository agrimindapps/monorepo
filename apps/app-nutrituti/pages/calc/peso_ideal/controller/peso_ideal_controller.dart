// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/peso_ideal_model.dart';
import '../utils/peso_ideal_utils.dart';

class PesoIdealController extends ChangeNotifier {
  final PesoIdealModel model = PesoIdealModel();
  final unfocusNode = FocusNode();
  bool get isCalculated => model.calculado;

  void calcular(BuildContext context) {
    PesoIdealUtils.calcular(context, model);
    notifyListeners();
  }

  void limpar() {
    model.limpar();
    unfocusNode.requestFocus();
    notifyListeners();
  }

  void updateGenero(int valor) {
    model.generoDef = model.generos.firstWhere((item) => item['id'] == valor);
    notifyListeners();
  }

  void compartilhar() {
    PesoIdealUtils.compartilhar(model);
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    model.dispose();
    super.dispose();
  }
}
