// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Project imports:
import '../constants.dart';
import '../models/correcao_acidez_model.dart';

class CorrecaoAcidezController extends GetxController {
  final model = CorrecaoAcidezModel();

  // Controllers para os campos de texto
  final pHAtualController = TextEditingController();
  final pHDesejadoController = TextEditingController();
  final teorCTCController = TextEditingController();
  final profundidadeSoloController = TextEditingController();
  final areaCalagemController = TextEditingController();
  final prntCalcarioController = TextEditingController();

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
    pHAtualController.dispose();
    pHDesejadoController.dispose();
    teorCTCController.dispose();
    profundidadeSoloController.dispose();
    areaCalagemController.dispose();
    prntCalcarioController.dispose();
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
    if (pHAtualController.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroPHAtual);
      return;
    }

    if (pHDesejadoController.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroPHDesejado);
      return;
    }

    if (teorCTCController.text.isEmpty) {
      focus3.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroTeorCTC);
      return;
    }

    if (profundidadeSoloController.text.isEmpty) {
      focus4.requestFocus();
      _exibirMensagem(
          context, BalancoNutricionalStrings.msgErroProfundidadeSolo);
      return;
    }

    if (areaCalagemController.text.isEmpty) {
      focus5.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroAreaCalagem);
      return;
    }

    if (prntCalcarioController.text.isEmpty) {
      focus6.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroPRNTCalcario);
      return;
    }

    model.pHAtual = double.parse(pHAtualController.text.replaceAll(',', '.'));
    model.pHDesejado =
        double.parse(pHDesejadoController.text.replaceAll(',', '.'));
    model.teorCTC = double.parse(teorCTCController.text.replaceAll(',', '.'));
    model.profundidadeSolo =
        double.parse(profundidadeSoloController.text.replaceAll(',', '.'));
    model.areaCalagem =
        double.parse(areaCalagemController.text.replaceAll(',', '.'));
    model.prntCalcario =
        double.parse(prntCalcarioController.text.replaceAll(',', '.'));

    model.calcular();
    calculado = true;
    
    _exibirMensagem(context, BalancoNutricionalStrings.msgSucessoCalculo,
        isError: false);
  }

  void limpar() {
    pHAtualController.clear();
    pHDesejadoController.clear();
    teorCTCController.clear();
    profundidadeSoloController.clear();
    areaCalagemController.clear();
    prntCalcarioController.clear();
    model.limpar();
    calculado = false;
    
  }

  void setMetodo(String novoMetodo) {
    model.metodoSelecionado = novoMetodo;
    
  }

  String compartilhar() {
    return model.gerarTextoCompartilhamento();
  }
}
