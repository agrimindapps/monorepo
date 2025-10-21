// Controller para lógica de cálculo e manipulação de estado da densidade óssea

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/densidade_ossea_model.dart';

class DensidadeOsseaController {
  final DensidadeOsseaModel model;
  DensidadeOsseaController(this.model);

  void calcular(BuildContext context) {
    if (model.idadeController.text.isEmpty) {
      exibirMensagem(context, 'Necessário informar a idade.');
      model.focusIdade.requestFocus();
      return;
    }
    if (model.pesoController.text.isEmpty) {
      exibirMensagem(context, 'Necessário informar o peso.');
      model.focusPeso.requestFocus();
      return;
    }
    model.idade = int.parse(model.idadeController.text);
    model.peso = double.parse(model.pesoController.text.replaceAll(',', '.'));
    model.pontuacao = 0;
    if (model.idade > 50) {
      model.pontuacao += 2;
    } else if (model.idade > 40) {
      model.pontuacao += 1;
    }
    double imc = model.peso / (1.7 * 1.7);
    if (imc < 18.5) {
      model.pontuacao += 2;
    } else if (imc < 20) {
      model.pontuacao += 1;
    }
    if (model.historicoFamiliar) model.pontuacao += 3;
    if (model.atividadeFisicaBaixa) model.pontuacao += 2;
    if (model.fumante) model.pontuacao += 2;
    if (model.consumoAlcool) model.pontuacao += 1;
    if (model.dietaPobre) model.pontuacao += 1;
    if (model.generoSelecionado == 2 && model.menopausa) model.pontuacao += 3;
    if (model.corticosteroides) model.pontuacao += 2;
    if (model.doencasTiroide) model.pontuacao += 1;
    if (model.pontuacao <= 3) {
      model.resultado = 'Baixo risco para osteoporose';
      model.recomendacoes =
          'Mantenha um estilo de vida saudável com exercícios regulares e alimentação balanceada rica em cálcio e vitamina D.';
    } else if (model.pontuacao <= 6) {
      model.resultado = 'Risco moderado para osteoporose';
      model.recomendacoes =
          'Considere aumentar a ingestão de cálcio e vitamina D. Exercícios de resistência são recomendados. Consulte um médico para avaliar a necessidade de exames.';
    } else if (model.pontuacao <= 9) {
      model.resultado = 'Alto risco para osteoporose';
      model.recomendacoes =
          'Recomenda-se consultar um médico para avaliação e possível encaminhamento para exame de densitometria óssea. Suplementação de cálcio e vitamina D pode ser necessária.';
    } else {
      model.resultado = 'Risco muito alto para osteoporose';
      model.recomendacoes =
          'Consulte um médico com urgência para realizar exame de densitometria óssea. Medidas preventivas e tratamentos podem ser necessários imediatamente.';
    }
    model.calculado = true;
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void limpar() {
    model.limpar();
  }

  void exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }
}
