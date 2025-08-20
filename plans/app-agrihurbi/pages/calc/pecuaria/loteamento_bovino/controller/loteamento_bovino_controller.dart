// Flutter imports:
// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/loteamento_bovino_model.dart';

class LoteamentoBovinoController extends GetxController {
  final quantidadeAnimais = TextEditingController();
  final pesoMedio = TextEditingController();
  final quantidadeHectares = TextEditingController();

  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  final numberFormat = NumberFormat('#,###.00#', 'pt_BR');
  final numberFormatSimple = NumberFormat('###.0#', 'pt_BR');

  LoteamentoBovinoModel? _model;
  final RxBool calculado = false.obs;
  final RxBool showInfoCard = false.obs;

  LoteamentoBovinoModel? get model => _model;

  @override
  void onClose() {
    quantidadeAnimais.dispose();
    pesoMedio.dispose();
    quantidadeHectares.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    super.onClose();
  }

  void init() {
    FirebaseAnalytics.instance.logScreenView(screenName: 'Loteamento Bovino');
  }

  bool validarCampos(BuildContext context) {
    if (quantidadeAnimais.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, 'Informe a quantidade de animais');
      return false;
    }

    if (pesoMedio.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, 'Informe o peso médio dos animais');
      return false;
    }

    if (quantidadeHectares.text.isEmpty) {
      focus3.requestFocus();
      _exibirMensagem(context, 'Informe a quantidade de hectares');
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    _model = LoteamentoBovinoModel(
      quantidadeAnimais: num.parse(quantidadeAnimais.text.replaceAll(',', '.')),
      pesoMedio: num.parse(pesoMedio.text.replaceAll(',', '.')),
      areaHectares: num.parse(quantidadeHectares.text.replaceAll(',', '.')),
    );

    calculado.value = true;
    
  }

  void limpar() {
    calculado.value = false;
    _model = null;
    quantidadeAnimais.clear();
    pesoMedio.clear();
    quantidadeHectares.clear();
    
  }

  void compartilhar() {
    if (_model == null) return;

    final shareText = '''
    Loteamento Bovino
    
    Valores
    Quantidade de Animais: ${numberFormat.format(_model!.quantidadeAnimais)}
    Peso Médio: ${numberFormat.format(_model!.pesoMedio)} kg
    Área: ${numberFormat.format(_model!.areaHectares)} ha
    
    Resultados
    Capacidade de Suporte: ${numberFormat.format(_model!.resultado)} UA/ha
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  Color getCorResultado(bool isDark) {
    if (_model == null) return Colors.grey;

    if (_model!.resultado < 1) {
      return isDark ? Colors.red.shade300 : Colors.red;
    } else if (_model!.resultado < 3) {
      return isDark ? Colors.amber.shade300 : Colors.amber;
    } else {
      return isDark ? Colors.green.shade300 : Colors.green;
    }
  }

  IconData getIconeResultado() {
    if (_model == null) return Icons.help_outline;

    if (_model!.resultado < 1) {
      return Icons.trending_down;
    } else if (_model!.resultado < 3) {
      return Icons.trending_flat;
    } else {
      return Icons.trending_up;
    }
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
