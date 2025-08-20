// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../constants.dart';
import '../models/aplicacao_model.dart';

class AplicacaoController extends GetxController {
  final AplicacaoModel model = AplicacaoModel();

  final volumePulverizar = TextEditingController();
  final velocidadeAplicacao = TextEditingController();
  final espacamentoBicos = TextEditingController();

  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

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
              isError
                  ? AplicacaoIcons.errorOutline
                  : AplicacaoIcons.checkCircleOutline,
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

  String? validateVolumePulverizar(String? value) {
    if (value == null || value.isEmpty) {
      return AplicacaoStrings.msgErroCampoVazio;
    }
    final numValue = num.tryParse(value.replaceAll(',', '.'));
    if (numValue == null) {
      return AplicacaoStrings.msgErroValorInvalido;
    }
    if (numValue <= 0) {
      return AplicacaoStrings.msgErroValorMinimo;
    }
    return null;
  }

  String? validateVelocidadeAplicacao(String? value) {
    if (value == null || value.isEmpty) {
      return AplicacaoStrings.msgErroCampoVazio;
    }
    final numValue = num.tryParse(value.replaceAll(',', '.'));
    if (numValue == null) {
      return AplicacaoStrings.msgErroValorInvalido;
    }
    if (numValue <= 0) {
      return AplicacaoStrings.msgErroValorMinimo;
    }
    return null;
  }

  String? validateEspacamentoBicos(String? value) {
    if (value == null || value.isEmpty) {
      return AplicacaoStrings.msgErroCampoVazio;
    }
    final numValue = num.tryParse(value.replaceAll(',', '.'));
    if (numValue == null) {
      return AplicacaoStrings.msgErroValorInvalido;
    }
    if (numValue <= 0) {
      return AplicacaoStrings.msgErroValorMinimo;
    }
    return null;
  }

  void calcular(BuildContext context, String tipo) {
    model.volumePulverizar =
        num.parse(volumePulverizar.text.replaceAll(',', '.'));
    model.velocidadeAplicacao =
        num.parse(velocidadeAplicacao.text.replaceAll(',', '.'));
    model.espacamentoBicos =
        num.parse(espacamentoBicos.text.replaceAll(',', '.'));

    switch (tipo) {
      case 'volume':
        model.calcularVolume();
        break;
      case 'vazao':
        model.calcularVazao();
        break;
      case 'quantidade':
        model.calcularQuantidade();
        break;
    }

    exibirMensagem(context, AplicacaoStrings.msgSucessoCalculo, isError: false);
  }

  void limpar() {
    model.limpar();
    volumePulverizar.clear();
    velocidadeAplicacao.clear();
    espacamentoBicos.clear();
  }

  void compartilhar(String tipo) {
    Share.share(model.formatarCompartilhamento(tipo));
  }

  @override
  void onClose() {
    volumePulverizar.dispose();
    velocidadeAplicacao.dispose();
    espacamentoBicos.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    super.onClose();
  }
}
