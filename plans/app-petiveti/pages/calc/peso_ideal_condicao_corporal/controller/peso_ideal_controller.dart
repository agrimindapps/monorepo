// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/peso_ideal_model.dart';
import '../utils/peso_ideal_utils.dart';

class PesoIdealController extends ChangeNotifier {
  final _model = PesoIdealModel();
  final _pesoAtualController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Getters
  PesoIdealModel get model => _model;
  TextEditingController get pesoAtualController => _pesoAtualController;
  bool get showInfoCard => _model.showInfoCard;

  // Inicialização
  PesoIdealController() {
    _model.escalaECCSelecionada = 5.0;
  }

  void atualizarEspecie(String? especie) {
    _model.especieSelecionada = especie;
    _model.racaSelecionada = null;
    notifyListeners();
  }

  void atualizarRaca(String? raca) {
    _model.racaSelecionada = raca;
    notifyListeners();
  }

  void atualizarSexo(String? sexo) {
    _model.sexoSelecionado = sexo;
    notifyListeners();
  }

  void atualizarEsterilizado(bool? esterilizado) {
    _model.esterilizado = esterilizado ?? false;
    notifyListeners();
  }

  void atualizarIdade(String idade) {
    _model.idadeAnos = int.tryParse(idade);
    notifyListeners();
  }

  void atualizarEscalaECC(double valor) {
    _model.escalaECCSelecionada = valor;
    notifyListeners();
  }

  void calcular(BuildContext context) {
    PesoIdealUtils.calcular(
        context, _model, formKey, _pesoAtualController.text);
    notifyListeners();
  }

  void limpar() {
    _pesoAtualController.clear();
    _model.limpar();
    _model.escalaECCSelecionada = 5.0;
    notifyListeners();
  }

  void toggleInfoCard() {
    _model.showInfoCard = !_model.showInfoCard;
    notifyListeners();
  }

  @override
  void dispose() {
    _pesoAtualController.dispose();
    super.dispose();
  }
}
