// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/fertilizante_model.dart';

class FertilizantesController extends GetxController {
  final model = FertilizanteModel();

  final nitrogenioController = TextEditingController();
  final fosforoController = TextEditingController();
  final potassioController = TextEditingController();
  final quantidadeController = TextEditingController();

  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();

  void calcular(BuildContext context) {
    if (!_validarCampos(context)) return;

    model.nitrogenio =
        num.parse(nitrogenioController.text.replaceAll(',', '.'));
    model.fosforo = num.parse(fosforoController.text.replaceAll(',', '.'));
    model.potassio = num.parse(potassioController.text.replaceAll(',', '.'));
    model.quantidade =
        num.parse(quantidadeController.text.replaceAll(',', '.'));

    model.calcular();
    

    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    nitrogenioController.clear();
    fosforoController.clear();
    potassioController.clear();
    quantidadeController.clear();
    model.limpar();
    
  }

  void compartilhar() {
    SharePlus.instance.share(ShareParams(text: model.gerarTextoCompartilhamento()));
  }

  bool _validarCampos(BuildContext context) {
    if (nitrogenioController.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, 'Informe o valor do Nitrogênio (N)');
      return false;
    }

    if (fosforoController.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, 'Informe o valor do Fósforo (P)');
      return false;
    }

    if (potassioController.text.isEmpty) {
      focus3.requestFocus();
      _exibirMensagem(context, 'Informe o valor do Potássio (K)');
      return false;
    }

    if (quantidadeController.text.isEmpty) {
      focus4.requestFocus();
      _exibirMensagem(context, 'Informe a quantidade em Kg');
      return false;
    }

    return true;
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

  @override
  void onClose() {
    nitrogenioController.dispose();
    fosforoController.dispose();
    potassioController.dispose();
    quantidadeController.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    super.onClose();
  }
}
