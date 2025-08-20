// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Project imports:
import '../constants.dart';
import '../models/adubacao_organica_model.dart';

class AdubacaoOrganicaController extends GetxController {
  final model = AdubacaoOrganicaModel();

  // Controllers para os campos de texto
  final quantidadeAduboController = TextEditingController();
  final teorNitrogenioController = TextEditingController();
  final teorFosforoController = TextEditingController();
  final teorPotassioController = TextEditingController();
  final areaTratadaController = TextEditingController();
  final materiaSecaAduboController = TextEditingController();

  // Focus nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();
  final focus6 = FocusNode();

  bool calculado = false;

  @override
  void onClose() {
    quantidadeAduboController.dispose();
    teorNitrogenioController.dispose();
    teorFosforoController.dispose();
    teorPotassioController.dispose();
    areaTratadaController.dispose();
    materiaSecaAduboController.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    focus5.dispose();
    focus6.dispose();
    super.onClose();
  }

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError
                  ? BalancoNutricionalIcons.errorOutline
                  : BalancoNutricionalIcons.checkCircleOutline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? BalancoNutricionalColors.red900
            : BalancoNutricionalColors.green700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  void calcular(BuildContext context) {
    if (quantidadeAduboController.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(
          context, BalancoNutricionalStrings.msgErroQuantidadeAdubo);
      return;
    }

    if (model.fonteOrganicaSelecionada == 0) {
      if (teorNitrogenioController.text.isEmpty) {
        focus2.requestFocus();
        _exibirMensagem(
            context, BalancoNutricionalStrings.msgErroTeorNitrogenio);
        return;
      }

      if (teorFosforoController.text.isEmpty) {
        focus3.requestFocus();
        _exibirMensagem(context, BalancoNutricionalStrings.msgErroTeorFosforo);
        return;
      }

      if (teorPotassioController.text.isEmpty) {
        focus4.requestFocus();
        _exibirMensagem(context, BalancoNutricionalStrings.msgErroTeorPotassio);
        return;
      }

      if (materiaSecaAduboController.text.isEmpty) {
        focus6.requestFocus();
        _exibirMensagem(context, BalancoNutricionalStrings.msgErroMateriaSeca);
        return;
      }
    }

    if (areaTratadaController.text.isEmpty) {
      focus5.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroAreaTratada);
      return;
    }

    model.quantidadeAdubo =
        double.parse(quantidadeAduboController.text.replaceAll(',', '.'));
    model.teorNitrogenio =
        double.parse(teorNitrogenioController.text.replaceAll(',', '.'));
    model.teorFosforo =
        double.parse(teorFosforoController.text.replaceAll(',', '.'));
    model.teorPotassio =
        double.parse(teorPotassioController.text.replaceAll(',', '.'));
    model.areaTratada =
        double.parse(areaTratadaController.text.replaceAll(',', '.'));
    model.materiaSecaAdubo =
        double.parse(materiaSecaAduboController.text.replaceAll(',', '.'));

    model.calcular();
    calculado = true;
    
    _exibirMensagem(context, BalancoNutricionalStrings.msgSucessoCalculo,
        isError: false);
  }

  void limpar() {
    quantidadeAduboController.clear();
    teorNitrogenioController.clear();
    teorFosforoController.clear();
    teorPotassioController.clear();
    areaTratadaController.clear();
    materiaSecaAduboController.clear();
    model.limpar();
    calculado = false;
    
  }

  void atualizarValoresReferencia() {
    if (model.fonteOrganicaSelecionada > 0) {
      final fonte =
          AdubacaoOrganicaModel.fontesOrganicas[model.fonteOrganicaSelecionada];
      teorNitrogenioController.text = fonte['N'].toString();
      teorFosforoController.text = fonte['P2O5'].toString();
      teorPotassioController.text = fonte['K2O'].toString();
      materiaSecaAduboController.text = fonte['MS'].toString();
      
    }
  }

  void setFonteOrganica(int index) {
    model.fonteOrganicaSelecionada = index;
    atualizarValoresReferencia();
  }

  void setUnidadeAdubo(String unidade) {
    model.unidadeAdubo = unidade;
    
  }

  String compartilhar() {
    return model.gerarTextoCompartilhamento();
  }
}
