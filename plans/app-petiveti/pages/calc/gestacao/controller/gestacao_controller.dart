// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/gestacao_model.dart';
import '../utils/gestacao_utils.dart';

class GestacaoController extends ChangeNotifier {
  final GestacaoModel model;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GestacaoController() : model = GestacaoModel();

  void calcular(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final especie = model.especieController.text;
      final dias = GestacaoModel.periodosGestacao[especie];

      if (dias != null && model.dataInicio != null) {
        model.dataParto = model.dataInicio!.add(Duration(days: dias));
        model.diasGestacao = dias;

        model.resultado =
            'Previsão de parto: ${model.dataParto!.day}/${model.dataParto!.month}/${model.dataParto!.year}\n'
            'Período de gestação: $dias dias';

        model.calculado = true;
        GestacaoUtils.exibirMensagem(context, 'Cálculo realizado com sucesso!');
        notifyListeners();
      }
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

  void selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      model.dataInicio = data;
      model.dataInicioController.text =
          '${data.day}/${data.month}/${data.year}';
      notifyListeners();
    }
  }

  void compartilharResultado() {
    GestacaoUtils.compartilhar(model);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}
