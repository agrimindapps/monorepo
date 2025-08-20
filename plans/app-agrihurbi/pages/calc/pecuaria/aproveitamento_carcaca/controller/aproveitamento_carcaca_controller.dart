// Flutter imports:
// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/aproveitamento_carcaca_model.dart';

class AproveitamentoCarcacaController extends GetxController {
  final pesoVivo = TextEditingController();
  final pesoCarcaca = TextEditingController();

  final focus1 = FocusNode();
  final focus2 = FocusNode();

  final numberFormat = NumberFormat('#,###.00#', 'pt_BR');
  final numberFormatSimple = NumberFormat('###.0#', 'pt_BR');

  AproveitamentoCarcacaModel? _model;
  final RxBool calculado = false.obs;

  AproveitamentoCarcacaModel? get model => _model;

  @override
  void onClose() {
    pesoVivo.dispose();
    pesoCarcaca.dispose();
    focus1.dispose();
    focus2.dispose();
    super.onClose();
  }

  void init() {
    FirebaseAnalytics.instance
        .logScreenView(screenName: 'Aproveitamento de Carcaça');
  }

  bool validarCampos(BuildContext context) {
    if (pesoVivo.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, 'Informe o peso vivo');
      return false;
    }

    if (pesoCarcaca.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, 'Informe o peso da carcaça');
      return false;
    }

    final vl1 = num.parse(pesoVivo.text.replaceAll(',', '.'));
    final vl2 = num.parse(pesoCarcaca.text.replaceAll(',', '.'));

    if (vl2 > vl1) {
      _exibirMensagem(
          context, 'O peso da carcaça não pode ser maior que o peso vivo');
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    _model = AproveitamentoCarcacaModel(
      pesoVivo: num.parse(pesoVivo.text.replaceAll(',', '.')),
      pesoCarcaca: num.parse(pesoCarcaca.text.replaceAll(',', '.')),
    );

    calculado.value = true;
    
  }

  void limpar() {
    calculado.value = false;
    _model = null;
    pesoVivo.clear();
    pesoCarcaca.clear();
    
  }

  void compartilhar() {
    if (_model == null) return;

    final shareText = '''
    Aproveitamento de Carcaça
    
    Valores
    Peso Vivo: ${numberFormat.format(_model!.pesoVivo)} kg
    Peso da Carcaça: ${numberFormat.format(_model!.pesoCarcaca)} kg
    
    Resultado
    Rendimento de Carcaça: ${numberFormat.format(_model!.resultado)}%
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
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
}
