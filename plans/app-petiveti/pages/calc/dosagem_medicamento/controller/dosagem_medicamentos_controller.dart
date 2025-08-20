// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/dosagem_medicamentos_model.dart';

class DosagemMedicamentosController extends ChangeNotifier {
  final DosagemMedicamentosModel model;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DosagemMedicamentosController() : model = DosagemMedicamentosModel();

  // Getters para acesso aos estados
  bool get showAlertaCard => model.showAlertaCard;

  void calcular() {
    if (formKey.currentState!.validate()) {
      final peso = double.parse(model.pesoController.text);

      // Para o cálculo, usamos o valor médio se for um intervalo
      double dosagem;
      if (model.dosagemController.text.contains('-')) {
        final partes = model.dosagemController.text.split('-');
        final min = double.parse(partes[0].trim());
        final max = double.parse(partes[1].trim());
        dosagem = (min + max) / 2; // valor médio do intervalo
      } else {
        dosagem = double.parse(model.dosagemController.text);
      }

      final concentracao = double.parse(model.concentracaoController.text);

      // Cálculo da dosagem: (peso * dosagem) / concentração
      model.resultado = (peso * dosagem) / concentracao;
      notifyListeners();
    }
  }

  void limpar() {
    model.limpar();
    notifyListeners();
  }

  void toggleInfoCard() {
    model.showInfoCard = !model.showInfoCard;
    notifyListeners();
  }

  void toggleAlertaCard() {
    model.showAlertaCard = !model.showAlertaCard;
    notifyListeners();
  }

  void atualizarDosagemRecomendada(String medicamento) {
    if (model.medicamentos.containsKey(medicamento)) {
      final dosagens = model.medicamentos[medicamento]!;
      model.medicamentoSelecionado = medicamento;
      model.dosagemController.text = '${dosagens[0]} - ${dosagens[1]}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}
